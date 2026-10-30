# Vendor: any other certificate seller

Copy this file to `vendors/<vendor>.md` the first time you use a new vendor, and fill in the click-path as you go.

Every vendor's panel does the same five things. The names change; the order does not.

| What you need | Typical labels |
| --- | --- |
| Find the cert and start | "Reissue", "Rekey", "Re-key certificate", "Activate", "Generate certificate", "Set up" |
| Hand over the CSR | "Enter CSR", "Paste CSR", "Certificate Signing Request" |
| Pick how to prove ownership | "Domain Control Validation", "DCV", "Verify domain", "Validation method": DNS / CNAME / TXT, HTTP / File, Email |
| Read the proof details | "Get record", "View DNS record", "Validation details", "Download auth file" |
| Download the result | "Download certificate", "Download bundle", "Server type: Other / Apache / Nginx" (pick Other or Apache for a plain .crt + bundle) |

## Known vendors, rough paths

Unverified; confirm and update when you use one.

**GoDaddy SSL**: My Products → SSL Certificates → Manage → "Re-Key & Manage" → paste CSR → Save → "Change the way you verify" if needed → Download: choose server type "Other" to get a .crt + bundle.

**SSLs.com / Sectigo resellers**: Dashboard → the cert → Reissue → paste CSR → DCV method → Submit. Record details under the order's "Validation" tab.

**DigiCert / GeoTrust / RapidSSL (DigiCert CertCentral)**: Certificates → Orders → the order → Reissue → paste CSR → DCV. Download → "Other format" → .crt + intermediate.

**GlobalSign**: My Certificates → Reissue → paste CSR → approval → download .crt and the intermediate CA from their support page.

**Let's Encrypt via host (AutoSSL, EasyWP free SSL, Certbot)**: no vendor panel. Nothing here applies; see the host file.

## Fill in when you use it

- Vendor name:
- Login URL:
- Who holds the account:
- Reissue button path:
- Where the validation record appears:
- How to force a re-check:
- What the download zip contains:
- Gotchas:
