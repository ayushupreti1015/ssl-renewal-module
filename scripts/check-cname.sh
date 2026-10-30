#!/usr/bin/env bash
# Step 4: confirm the validation CNAME is live, both at the authoritative server and publicly.
# Usage: ./scripts/check-cname.sh example.com _D301DB97D87A2294E19EFAA2D297C7AB
set -euo pipefail

DOMAIN="${1:?Usage: $0 example.com _HOSTCODE}"
CODE="${2:?Missing host code (the part Namecheap gave you, starting with an underscore)}"

# Strip a trailing .domain if someone pasted the full host.
CODE="${CODE%.$DOMAIN}"
CODE="${CODE%.$DOMAIN.}"
FQDN="$CODE.$DOMAIN"

echo "Checking: $FQDN"
echo

echo "== Authoritative nameserver (instant, no caching) =="
NS1=$(dig +short NS "$DOMAIN" | head -n 1)
if [[ -z "$NS1" ]]; then
  echo "Could not find nameservers for $DOMAIN."; exit 1
fi
echo "Asking $NS1"
AUTH=$(dig +short CNAME "$FQDN" "@$NS1" || true)
if [[ -n "$AUTH" ]]; then
  echo "$AUTH"
  echo "-> Record is live at the provider."
else
  echo "(empty)"
  echo "-> NOT FOUND at the provider. The record is missing, in the wrong panel, or the host is wrong."
  echo "   Check: single underscore, no '.$DOMAIN' appended, added at the provider that $NS1 belongs to."
fi
echo

echo "== Public resolver 1.1.1.1 (may lag 5-60 min) =="
PUB=$(dig +short CNAME "$FQDN" @1.1.1.1 || true)
if [[ -n "$PUB" ]]; then
  echo "$PUB"; echo "-> Visible publicly. Sectigo can see it."
else
  echo "(empty)"
  if [[ -n "$AUTH" ]]; then
    echo "-> Not propagated yet. Normal. Wait and re-run."
  fi
fi
