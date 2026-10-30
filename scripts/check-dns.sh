#!/usr/bin/env bash
# Step 0: find out who runs DNS, where the site lives, and when the current cert expires.
# Usage: ./scripts/check-dns.sh example.com
set -euo pipefail

DOMAIN="${1:?Usage: $0 example.com}"

echo "== Nameservers (who manages DNS) =="
NS=$(dig +short NS "$DOMAIN" | sort)
echo "$NS"
case "$NS" in
  *registrar-servers.com*) echo "-> Namecheap DNS. Add records in Namecheap > Domain List > Advanced DNS." ;;
  *domaincontrol.com*)     echo "-> GoDaddy DNS. Add records in GoDaddy > My Products > DNS." ;;
  *cloudflare.com*)        echo "-> Cloudflare DNS. Add records in Cloudflare > DNS. Set validation CNAME to DNS only (grey cloud)." ;;
  *awsdns*)                echo "-> Amazon Route 53." ;;
  *)                       echo "-> Unknown provider. Look up the nameserver hostname to find the company." ;;
esac
echo

echo "== Website IP (A records) =="
dig +short A "$DOMAIN"
echo

echo "== Current certificate on the live site =="
if CERT=$(echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null); then
  echo "$CERT"
  EXP=$(echo "$CERT" | awk -F= '/notAfter/{print $2}')
  if [[ "$(uname)" == "Darwin" ]]; then
    EXP_S=$(date -j -f "%b %d %T %Y %Z" "$EXP" +%s 2>/dev/null || echo 0)
  else
    EXP_S=$(date -d "$EXP" +%s 2>/dev/null || echo 0)
  fi
  if [[ "$EXP_S" -gt 0 ]]; then
    DAYS=$(( (EXP_S - $(date +%s)) / 86400 ))
    echo "-> Expires in $DAYS days."
  fi
else
  echo "Could not read a certificate from $DOMAIN:443."
fi
