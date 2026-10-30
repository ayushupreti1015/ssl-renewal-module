#!/usr/bin/env bash
# Step 2: generate a private key and CSR, lock the key, copy the CSR to the clipboard.
#
# Usage:
#   ./scripts/make-csr.sh example.com "Company Name" "City" "State" [options]
#
# Options:
#   --wildcard            CN becomes *.example.com, with example.com added as a SAN
#   --san a.com,b.net     extra domains to include (comma-separated, no spaces)
#   --country XX          two-letter country code (default US)
#   --out DIR             output folder (default ~/ssl/example.com/YYYY-MM)
#
# Examples:
#   ./scripts/make-csr.sh lwgf.us "The Lakewood Group" "Fairfield" "New Jersey"
#   ./scripts/make-csr.sh example.com "Acme" "Austin" "Texas" --wildcard
#   ./scripts/make-csr.sh example.com "Acme" "Austin" "Texas" --san shop.example.com,example.net
set -euo pipefail

usage() { sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

[[ $# -lt 4 ]] && usage

DOMAIN="$1"; ORG="$2"; CITY="$3"; STATE="$4"; shift 4
COUNTRY="US"; WILDCARD=0; SANS=""; OUTDIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wildcard) WILDCARD=1; shift ;;
    --san)      SANS="${2:?--san needs a comma-separated list}"; shift 2 ;;
    --country)  COUNTRY="${2:?--country needs a code}"; shift 2 ;;
    --out)      OUTDIR="${2:?--out needs a folder}"; shift 2 ;;
    -h|--help)  usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# Sanity checks on the domain
if [[ "$DOMAIN" == www.* ]]; then
  echo "Use the bare domain (example.com), not www. Most DV certs cover www automatically."; exit 1
fi
if [[ "$DOMAIN" == \*.* ]]; then
  echo "Do not put the * in the domain. Use --wildcard instead."; exit 1
fi

CN="$DOMAIN"
ALT_NAMES=()
if [[ $WILDCARD -eq 1 ]]; then
  CN="*.$DOMAIN"
  ALT_NAMES+=("*.$DOMAIN" "$DOMAIN")
fi
if [[ -n "$SANS" ]]; then
  [[ $WILDCARD -eq 0 ]] && ALT_NAMES+=("$DOMAIN")
  IFS=',' read -r -a extra <<< "$SANS"
  for s in "${extra[@]}"; do ALT_NAMES+=("$s"); done
fi

DIR="${OUTDIR:-$HOME/ssl/$DOMAIN/$(date +%Y-%m)}"
KEY="$DIR/$DOMAIN.key"
CSR="$DIR/$DOMAIN.csr"

if [[ -f "$KEY" ]]; then
  echo "A key already exists at $KEY"
  echo "Move it aside first if you really want a new one. A new key means a new CSR and a fresh validation."
  exit 1
fi
mkdir -p "$DIR"

SUBJ="/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=$CN"

if [[ ${#ALT_NAMES[@]} -eq 0 ]]; then
  openssl req -new -newkey rsa:2048 -nodes -keyout "$KEY" -out "$CSR" -subj "$SUBJ" 2>/dev/null
else
  # SANs need a config file. Works on both OpenSSL and the LibreSSL that ships with macOS.
  CFG="$(mktemp)"
  {
    echo "[req]"
    echo "distinguished_name = dn"
    echo "req_extensions = ext"
    echo "prompt = no"
    echo "[dn]"
    echo "C  = $COUNTRY"
    echo "ST = $STATE"
    echo "L  = $CITY"
    echo "O  = $ORG"
    echo "CN = $CN"
    echo "[ext]"
    echo "subjectAltName = @alt"
    echo "[alt]"
    i=1
    for n in "${ALT_NAMES[@]}"; do echo "DNS.$i = $n"; i=$((i+1)); done
  } > "$CFG"
  openssl req -new -newkey rsa:2048 -nodes -keyout "$KEY" -out "$CSR" -config "$CFG" 2>/dev/null
  rm -f "$CFG"
fi

chmod 600 "$KEY"

echo "== CSR subject =="
openssl req -in "$CSR" -noout -subject
if [[ ${#ALT_NAMES[@]} -gt 0 ]]; then
  echo
  echo "== Names covered (SAN) =="
  openssl req -in "$CSR" -noout -text | grep -A1 'Subject Alternative Name' | tail -n 1 | sed 's/^ *//'
fi
echo

if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$CSR"; echo "CSR copied to clipboard."
elif command -v xclip >/dev/null 2>&1; then
  xclip -selection clipboard < "$CSR"; echo "CSR copied to clipboard."
else
  echo "No clipboard tool found. Copy it manually:"; echo; cat "$CSR"
fi

echo
echo "Files:"
echo "  $KEY   (SECRET: never commit, never send over chat)"
echo "  $CSR   (paste into the vendor's panel)"
echo
echo "Next: paste the CSR into the vendor panel, choose DNS validation, submit."
[[ $WILDCARD -eq 1 ]] && echo "Wildcard certs require DNS validation; HTTP file and email are not accepted."
echo "Do not copy anything else until you have pasted the CSR."
