#!/usr/bin/env bash
# Step 4 (Option B): confirm an HTTP validation file is reachable where the authority will look.
# Usage: ./scripts/check-http-file.sh example.com A1B2C3D4E5F6.txt
set -euo pipefail

DOMAIN="${1:?Usage: $0 example.com FILENAME.txt}"
FILE="${2:?Missing filename (the .txt the vendor gave you)}"

for HOSTNAME in "$DOMAIN" "www.$DOMAIN"; do
  URL="http://$HOSTNAME/.well-known/pki-validation/$FILE"
  echo "== $URL =="
  # -L off on purpose: the authority does not always follow redirects.
  CODE=$(curl -s -o /tmp/pki-check.$$ -w '%{http_code}' --max-time 15 "$URL" || echo "000")
  case "$CODE" in
    200)
      echo "HTTP 200. Contents:"
      sed 's/^/  /' /tmp/pki-check.$$
      echo "-> Reachable. Compare the contents to the file the vendor gave you; they must match exactly."
      ;;
    301|302|307|308)
      LOC=$(curl -s -o /dev/null -w '%{redirect_url}' --max-time 15 "$URL" || true)
      echo "HTTP $CODE redirect to: $LOC"
      echo "-> The host is redirecting (usually to https or to www). Some authorities follow this, some do not."
      echo "   Safest: make the file reachable at the redirect target too, or switch to DNS validation."
      ;;
    404)
      echo "HTTP 404."
      echo "-> File not found. Check the folder path (.well-known/pki-validation/) and the exact filename."
      ;;
    000)
      echo "No response."
      echo "-> Could not connect. Check the domain resolves and the host is up."
      ;;
    *)
      echo "HTTP $CODE."
      echo "-> Unexpected. Open the URL in a browser to see what the host returns."
      ;;
  esac
  echo
done
rm -f /tmp/pki-check.$$
