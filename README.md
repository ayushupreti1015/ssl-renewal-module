# SSL Renewal Module

A reusable runbook and scripts for issuing or reissuing an SSL/TLS certificate on any website: any certificate vendor, any DNS provider, any host. The core steps never change. The vendor-specific and host-specific clicks live in their own files so new ones can be added without touching the core.

Built from The Lakewood Group (lwgf.us) renewal on 2026-10-30: Namecheap PositiveSSL, GoDaddy DNS, EasyWP host.

## Why this exists

Since March 15, 2026, no public certificate can be valid for more than 200 days. A paid multi-year subscription stays paid, but the certificate itself has to be reissued about every 6 months. For every client on a manually managed certificate, someone has to do the eight steps below twice a year. This repo makes each run about 30 minutes and removes the guesswork.

## Layout

| Path | What it is |
| --- | --- |
| `README.md` | The universal runbook (this file) |
| `QUICKSTART.md` | Commands and clicks only, no explanation, for the second time through |
| `scripts/check-dns.sh` | Finds the DNS provider, website IP, and current cert expiry |
| `scripts/make-csr.sh` | Generates private key + CSR (single, wildcard, or multi-domain), copies CSR to clipboard |
| `scripts/check-cname.sh` | Confirms a DNS validation CNAME is live |
| `scripts/check-http-file.sh` | Confirms an HTTP validation file is reachable |
| `scripts/verify-cert.sh` | Key/cert match, file dates, chain check, and what the live site serves |
| `vendors/` | One file per certificate vendor: where the buttons are. `namecheap.md`, `other.md` |
| `hosts/` | One file per hosting panel: where the cert gets pasted. `easywp.md`, `cpanel.md`, `other.md` |
| `clients/` | One record per client domain. `TEMPLATE.md` plus the filled-in files |
| `.gitignore` | Keeps keys and certificate files out of the repo |

## What never goes in this repo

- `*.key` files. A private key in git, even in a private repo, is a leaked key and the certificate must be reissued.
- Passwords, one-time codes, API tokens, session links.
- `.csr`, `.crt`, `.ca-bundle`, `.p7b`, `.pfx`. Not secret, but per-client and they expire.

Working files live in `~/ssl/<domain>/<YYYY-MM>/` on the machine that did the work. The `.key` also goes in the team password manager or a locked shared drive, and `clients/<domain>.md` records where.

## Requirements

- macOS or Linux with `openssl`, `dig`, `curl`, and `pbcopy` (macOS) or `xclip` (Linux). All present on a stock Mac.
- Logins for: the certificate vendor account, the host's control panel, and either the DNS provider or a person who has it.

## Before you start: which kind of certificate is this?

| Situation | What to do |
| --- | --- |
| Host offers free Let's Encrypt / AutoSSL and the client agrees | Turn it on in the host panel. Done. It renews itself. This runbook is not needed |
| Paid certificate, managed manually (PositiveSSL, RapidSSL, DigiCert, etc.) | This runbook |
| Site behind Cloudflare proxy (orange cloud) with Cloudflare's own edge cert | Cloudflare renews the edge cert itself. The origin cert, if any, follows this runbook |
| Wildcard (`*.example.com`) or several domains on one cert | This runbook, with `make-csr.sh --wildcard` or `--san`. DNS validation is required for wildcards |

## The procedure

### Step 0. Check what you have

```bash
./scripts/check-dns.sh example.com
```

Prints:
- The **nameservers**, and which company that means. This is where the validation record will go in Step 4. Nowhere else works.
- The website's **IP address**. Tells you roughly who the host is.
- The **current certificate** on the live site: who issued it and when it expires.

Common nameserver patterns:

| Nameserver ends in | DNS is managed at |
| --- | --- |
| `registrar-servers.com` | Namecheap |
| `domaincontrol.com` | GoDaddy |
| `cloudflare.com` | Cloudflare |
| `awsdns-xx.com` | Amazon Route 53 |
| `googledomains.com` | Google / Squarespace |
| `wixdns.net` | Wix |
| `ui-dns.com` | IONOS |

If there is a `clients/example.com.md`, read it now. It records who holds the DNS and host logins.

### Step 1. Open the certificate in the vendor's panel

Go to the vendor's account and find the certificate. Open `vendors/<vendor>.md` for the exact buttons. In general:

- **Reissue** (on an active cert): a subscription exists, you are renewing. Use this.
- **Activate**: a certificate was bought but never set up.
- Only **Renew** or **Buy**: nothing is paid for. Stop. Get purchase approval, or raise the free Let's Encrypt option.

Choose the manual route when offered. Vendor automation only works when the vendor also controls the host (cPanel, their own CDN).

### Step 2. Generate the private key and CSR

```bash
./scripts/make-csr.sh example.com "Company Name" "City" "State"
```

Options:

| Case | Command |
| --- | --- |
| Single domain (covers `www` too on most DV certs) | `./scripts/make-csr.sh example.com "Co" "City" "State"` |
| Wildcard | `./scripts/make-csr.sh example.com "Co" "City" "State" --wildcard` |
| Several domains on one cert | `./scripts/make-csr.sh example.com "Co" "City" "State" --san shop.example.com,example.net` |
| Country other than US | add `--country GB` |

The script creates `~/ssl/example.com/YYYY-MM/example.com.key` and `.csr`, locks the key to owner-only, prints the subject and any extra names for you to check, and copies the CSR to the clipboard.

Do not copy anything else before pasting. If you lose it: `pbcopy < ~/ssl/example.com/YYYY-MM/example.com.csr`.

### Step 3. Submit the CSR and choose a validation method

Paste the CSR into the vendor's box. The primary domain fills itself from the CSR. Pick a validation method:

| Method | You need | Use when |
| --- | --- | --- |
| **DNS (CNAME or TXT)** | Access to the DNS provider from Step 0, or a person who has it | Default. Nothing touches the live site. Required for wildcards |
| **HTTP file** | SFTP/file access to the host | You have host access but nobody can reach DNS |
| **Email** | A mailbox like `admin@example.com` | Rarely practical |

Submit. Status becomes Pending. The vendor now shows the validation details.

### Step 4. Prove you control the domain

#### Option A: DNS record

The vendor gives you a **Host** (a code starting with `_`) and a **Target**. Add it at the DNS provider from Step 0:

| Field | Enter |
| --- | --- |
| Type | CNAME (or TXT if that is what the vendor gave you) |
| Name / Host | The code only, without `.example.com`. Panels append the domain themselves |
| Value / Target | The full target |
| TTL | Default |
| Cloudflare only | Proxy status DNS only (grey cloud) |

If someone else holds DNS access, send them this:

> The SSL renewal for example.com needs one DNS record added at [provider]. It is the certificate authority's ownership check and does not affect the website or email.
> Type: CNAME
> Name: `_CODE`
> Value: `TARGET`
> Enter the Name without ".example.com" at the end; the panel adds it.

Then confirm:

```bash
./scripts/check-cname.sh example.com _CODE
```

The authoritative server must answer with the target. Empty from the authoritative server means wrong panel, doubled domain in the Host field, or a typo. Empty only from the public resolver means wait.

#### Option B: HTTP file

The vendor gives you a small `.txt` file (name like `A1B2C3....txt`) and tells you to place it at:

```
http://example.com/.well-known/pki-validation/<filename>.txt
```

Upload it there with the host's file manager or SFTP (see `hosts/<host>.md` for how to get SFTP access). Do not rename it or edit its contents. Then confirm:

```bash
./scripts/check-http-file.sh example.com <filename>.txt
```

It must return HTTP 200 and the file's exact contents. A redirect to `https://` or to `www` can break this; the host file tells you how to handle that.

### Step 5. Wait for issuance

The authority checks automatically. Refresh the vendor's certificate list until the status is **Active** / **Issued**. Usually 15 to 60 minutes after the proof is live.

Still pending after 2 hours with the proof confirmed: re-save the validation method in the vendor panel without changes to force a re-check. Still nothing: vendor support chat.

### Step 6. Download and verify

Download the issued certificate from the vendor. Unzip into the same folder as the key:

```bash
cd ~/ssl/example.com/YYYY-MM
unzip ~/Downloads/<download>.zip
```

You get the **certificate** (`.crt`), the **CA bundle** (`.ca-bundle` or `chain.pem`), and sometimes a `.p7b` (Windows format, ignore).

```bash
./scripts/verify-cert.sh example.com
```

The two hashes must be identical. If they are not, the certificate was issued for a different key. Do not install; reissue from Step 2.

### Step 7. Install on the host

Open `hosts/<host>.md` for the exact panel. Every host needs the same three things:

| Box | File |
| --- | --- |
| Private key | `example.com.key` (from Step 2) |
| Certificate | the `.crt` |
| CA bundle / chain / intermediate | the `.ca-bundle` |

Some panels have no separate bundle box and want the certificate and bundle concatenated into one block, certificate first. The host file says if so.

The old certificate keeps serving until the new one is live, so there is no downtime.

### Step 8. Confirm and close out

```bash
./scripts/verify-cert.sh example.com
```

The last section should now show the new expiry on the live site. Check `https://example.com` and `https://www.example.com` in a private browser window. Optionally run sslshopper.com/ssl-checker.html for a screenshot to send the client.

Then:

1. Copy the `.key` to the team password manager or locked shared drive. Record where in `clients/example.com.md`.
2. Update `clients/example.com.md`: new certificate ID, new expiry, history line.
3. Set a calendar reminder 30 days before the new expiry.
4. Commit and push the client file.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `check-cname.sh` empty from the authoritative server | Record in the wrong panel, doubled domain in Host, extra or missing underscore | Re-run `check-dns.sh`; fix the Host field; add it at the provider the nameservers name |
| `check-http-file.sh` gets a redirect or 404 | Host forces https or www, or the folder path is wrong | Put the file where the redirected URL lands too, or use DNS validation instead |
| Pending for hours, proof confirmed | Authority has not re-polled | Re-save the validation method without changes |
| "Private key does not match" on install | Wrong key, or key from a different CSR | Use the key made with this CSR; if lost, reissue from Step 2 |
| Chain / intermediate error in the browser after install | Bundle missing or partial | Re-download and paste the full bundle |
| Host accepted the files but the site still serves the old cert | Host has not switched yet | Wait 10 to 15 minutes, re-run `verify-cert.sh` |
| Vendor's own DNS check is green but the authority never issues | The vendor's DNS panel is not the authoritative DNS | Nameservers point elsewhere; add the record there |
| Mixed-content warning after HTTPS works | Pages load `http://` images or scripts | WordPress: Really Simple SSL plugin or a search-replace of `http://example.com` to `https://` |

## Alternative: stop doing this

Most managed hosts (EasyWP, cPanel with AutoSSL, WP Engine, Kinsta, Cloudflare) offer Let's Encrypt for free. It renews itself every 90 days with no CSR, no validation record, and no 200-day chore. The encryption and padlock are identical to a paid DV certificate. For a client who does not need the paid certificate's warranty, switching ends this process permanently. Raise it before each renewal.

## Adding a new vendor or host

Copy `vendors/other.md` or `hosts/other.md`, name it after the panel, and write down the click-path while you are doing it the first time. That is the whole point of the repo: the second person never rediscovers the first person's afternoon.

## Why each piece exists

- **Private key**: the server's secret. The certificate is only valid when paired with it. Made once per CSR, never leaves your machines.
- **CSR**: the request form. Contains the domain(s) and the public half of the key. Not secret.
- **Validation (CNAME / TXT / HTTP file)**: proof you control the domain. Only someone who can edit the domain's DNS or files could place what the authority asked for.
- **Certificate + CA bundle**: the authority's signed statement that this key belongs to this domain, plus the chain tying that signature back to a root every browser trusts.
