# Quickstart

Commands and clicks only. Read `README.md` the first time.

```
cd ~/projects/ssl-renewal-module
cat clients/example.com.md                      # who has which login, where DNS lives
./scripts/check-dns.sh example.com              # confirm DNS provider + current expiry
```

Vendor panel: find the cert → Reissue (or Activate) → manual route. See `vendors/<vendor>.md`.

```
./scripts/make-csr.sh example.com "Company" "City" "State"     # add --wildcard or --san a,b if needed
```

Vendor panel: paste CSR → validation = DNS (CNAME) → submit → copy the Host and Target.

Add the CNAME at the DNS provider from step 1 (Host = code only, no domain). Or send it to whoever has access.

```
./scripts/check-cname.sh example.com _CODE      # must answer from the authoritative server
```

Wait for status Active (15-60 min). Download the zip.

```
cd ~/ssl/example.com/$(date +%Y-%m) && unzip ~/Downloads/<file>.zip && cd -
./scripts/verify-cert.sh example.com            # hashes must MATCH
```

Host panel: paste key + cert + bundle. See `hosts/<host>.md`. Wait ~10 min.

```
./scripts/verify-cert.sh example.com            # live site shows new expiry
```

Close out: key → password manager · update `clients/example.com.md` · reminder at expiry minus 30 days · commit, push.
