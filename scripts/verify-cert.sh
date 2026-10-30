#!/usr/bin/env bash
# Steps 6 and 8: check the downloaded cert matches the key, show its dates, show what the live site serves.
# Usage: ./scripts/verify-cert.sh example.com [folder]
# Default folder: ~/ssl/example.com/<current YYYY-MM>
#
# Finds the certificate and bundle by looking in the folder, so vendor file naming does not matter:
#   Namecheap/Sectigo: example_com.crt + example_com.ca-bundle
#   Wildcard:          STAR_example_com.crt
#   Others:            certificate.crt, example.com.crt, fullchain.pem, chain.pem, intermediate.crt
set -euo pipefail

DOMAIN="${1:?Usage: $0 example.com [folder]}"
DIR="${2:-$HOME/ssl/$DOMAIN/$(date +%Y-%m)}"
KEY="$DIR/$DOMAIN.key"

echo "Folder: $DIR"
echo

# Find the certificate: a .crt/.pem/.cer file that is NOT a bundle/chain/intermediate and holds exactly one cert.
CRT=""
BUNDLE=""
if [[ -d "$DIR" ]]; then
  for f in "$DIR"/*.crt "$DIR"/*.pem "$DIR"/*.cer "$DIR"/*.ca-bundle; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f" | tr '[:upper:]' '[:lower:]')
    n=$(grep -c 'BEGIN CERTIFICATE' "$f" 2>/dev/null || echo 0)
    case "$base" in
      *bundle*|*chain*|*intermediate*|*ca.*|ca-*) [[ -z "$BUNDLE" ]] && BUNDLE="$f" ;;
      *) if [[ "$n" -eq 1 && -z "$CRT" ]]; then CRT="$f"; elif [[ "$n" -gt 1 && -z "$BUNDLE" ]]; then BUNDLE="$f"; fi ;;
    esac
  done
fi

if [[ ! -f "$KEY" ]]; then
  echo "No key at $KEY"
  echo "Expected the key from make-csr.sh. Pass the folder as the second argument if it is somewhere else."
  echo
elif [[ -z "$CRT" ]]; then
  echo "No certificate file found in $DIR"
  echo "Download the issued certificate from the vendor and unzip it into that folder first."
  echo
else
  echo "Certificate: $(basename "$CRT")"
  if [[ -n "$BUNDLE" ]]; then echo "Bundle:      $(basename "$BUNDLE")"; else echo "Bundle:      NOT FOUND"; fi
  echo

  echo "== Key / certificate match =="
  K=$(openssl rsa  -noout -modulus -in "$KEY" 2>/dev/null | openssl md5)
  C=$(openssl x509 -noout -modulus -in "$CRT" 2>/dev/null | openssl md5)
  echo "key : $K"
  echo "cert: $C"
  if [[ "$K" == "$C" ]]; then
    echo "-> MATCH. Safe to install."
  else
    echo "-> MISMATCH. Do not install. This certificate was issued for a different key."
  fi
  echo

  echo "== Certificate file =="
  openssl x509 -in "$CRT" -noout -subject -issuer -dates
  SAN=$(openssl x509 -in "$CRT" -noout -ext subjectAltName 2>/dev/null | tail -n 1 | sed 's/^ *//' || true)
  [[ -n "$SAN" ]] && echo "names: $SAN"
  echo

  if [[ -n "$BUNDLE" ]]; then
    echo "== Chain check (certificate against the bundle) =="
    if openssl verify -untrusted "$BUNDLE" "$CRT" >/dev/null 2>&1 || openssl verify -CAfile "$BUNDLE" "$CRT" >/dev/null 2>&1; then
      echo "-> Chain verifies."
    else
      echo "-> Could not verify the chain locally. Often a local trust-store quirk on macOS; the live-site check after install is the real test."
    fi
    echo
  else
    echo "No CA bundle found. Most hosts need it. Re-download from the vendor if the zip did not include one."
    echo
  fi
fi

echo "== What the live site is serving right now =="
if LIVE=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null); then
  echo "$LIVE"
  if [[ -n "${CRT:-}" && -f "$CRT" ]]; then
    LIVE_FP=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -fingerprint -sha256 2>/dev/null)
    FILE_FP=$(openssl x509 -in "$CRT" -noout -fingerprint -sha256 2>/dev/null)
    if [[ "$LIVE_FP" == "$FILE_FP" ]]; then
      echo "-> The live site is serving THIS certificate. Install confirmed."
    else
      echo "-> The live site is serving a different certificate (the old one, or not switched yet)."
    fi
  fi
else
  echo "Could not connect to $DOMAIN:443."
fi
