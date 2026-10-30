# Vendor: Namecheap (PositiveSSL, EssentialSSL, Sectigo products)

Where the buttons are for Steps 1, 3, 4, 5 and 6 of the README. Verified 2026-10-30.

## Login

namecheap.com → Sign In. The account may be the client's; see `clients/<domain>.md` for who holds it and where the 2FA code goes.

## Step 1: find the certificate

Hover the username (top left) → **Dashboard** → **SSL Certificates** in the left sidebar.

| Button on the row | Meaning | Do |
| --- | --- | --- |
| **REISSUE** on an Active cert, with "Reissue your SSL certificate due to SSL lifetime limit" | Subscription is paid, cert needs re-cutting | Click REISSUE (the left half of the button, not the dropdown) |
| **ACTIVATE** | A cert was bought and never set up | Click ACTIVATE |
| **RENEW** only | Subscription itself is ending; nothing is paid | Stop and get approval |
| **DOWNLOAD** | Already issued | Skip to Step 6 |

Popup "SSL LIFETIME LIMIT" → **Continue manually**. (Choose automation only fits cPanel hosting or Namecheap's CDN.)

Screen "Choose how to issue and install" → tab **Manage SSL manually**.

## Step 3: submit the CSR

Paste the CSR into the CSR box. "Primary domain" fills itself. **Next**.

Validation method dropdown: **Add CNAME record** (default), or **Upload a validation file**, or **Receive an email**.

Review & submit screen shows "Installation files will be sent to <email>". This is the admin email from the original order and cannot be changed here. It does not matter; download from the account instead. **Submit**.

A new row appears with a new SSL ID, status **PENDING**. The old row stays Active until the new one is issued, then flips to **REPLACED**.

## Step 4: get the validation details

SSL Certificates → the Pending row → **DETAILS** → scroll to "DCV Methods in Use" → the dropdown arrow next to **EDIT METHODS** → **Get Record**.

A popup shows:
- **Host**: `_HEXCODE.example.com`
- **Target**: `HEX.HEX.HEX.comodoca.com` (or `.sectigo.com`)

For HTTP validation the same popup gives a filename and file contents instead.

The "Add CNAME at Namecheap" convenience only works when the domain's nameservers are Namecheap's (`registrar-servers.com`). If `check-dns.sh` shows another provider, add the record there. The Namecheap Advanced DNS tab is ignored in that case.

## Step 5: force a re-check

If Pending for more than 2 hours with the record confirmed live: DETAILS → EDIT METHODS → choose the same method again → save. Sectigo re-polls within minutes.

## Step 6: download

Status **ACTIVE** → **DOWNLOAD**. The zip is named `example_com.zip` and contains:

| File | Use |
| --- | --- |
| `example_com.crt` | The certificate |
| `example_com.ca-bundle` | The CA bundle (intermediates + root) |
| `example_com.p7b` | Windows/IIS format. Ignore |

Wildcard certs are named `STAR_example_com.*`.

The same files are emailed to the admin contact on the order.

## Gotchas

- Namecheap is three separate products: registrar (Domain List), host (EasyWP, under Apps), and SSL reseller (SSL Certificates). Logging into one does not mean the domain's DNS is there.
- "Pauses on <date>" in the Purchased-for column is the current cert's expiry, not the subscription's.
- The 200-day limit means a 5-year subscription produces about nine reissues. Namecheap emails a reminder 30 days before each one.
