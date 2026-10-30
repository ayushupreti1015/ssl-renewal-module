# Host: cPanel (Namecheap Shared, Bluehost, HostGator, SiteGround legacy, most shared hosting)

Where the certificate gets installed (README Step 7). Unverified in this repo; update after first use.

## First: is manual install even needed?

cPanel hosts almost always offer **AutoSSL** (free Let's Encrypt or Sectigo DV, auto-renewing). Check cPanel → Security → **SSL/TLS Status**. If AutoSSL is on and the domain shows a green lock, there is nothing to do and no paid cert is needed.

Namecheap shared hosting also has a **Namecheap SSL plugin** in cPanel that activates and installs a PositiveSSL in two clicks, skipping this whole runbook. Look for it in cPanel → Security.

## Manual install

cPanel → **Security** → **SSL/TLS** → under "Install and Manage SSL for your site (HTTPS)" click **Manage SSL sites**.

| Field | File |
| --- | --- |
| Domain | pick the domain from the dropdown |
| Certificate (CRT) | paste `example_com.crt` |
| Private Key (KEY) | paste `example.com.key` |
| Certificate Authority Bundle (CABUNDLE) | paste `example_com.ca-bundle` |

Click **Install Certificate**. Live immediately.

Older cPanel: SSL/TLS → **Certificates (CRT)** → upload the .crt → back to Manage SSL sites.

## Generating the CSR in cPanel instead of Terminal

cPanel can make the key + CSR itself (SSL/TLS → Certificate Signing Requests). The key then lives on the server and never needs pasting. Fine for a single cPanel host; the Terminal method is better when the same team manages many hosts, because the key handling is the same everywhere.

## HTTP-file validation

cPanel → **File Manager** → `public_html` → create `.well-known/pki-validation/` → Upload the `.txt`. Make sure "Show Hidden Files" is on so `.well-known` is visible.

## Gotchas

- If the domain is an addon or subdomain, its document root may not be `public_html`. Check Domains in cPanel.
- Some hosts force HTTPS redirects via .htaccess, which can break HTTP-file validation. DNS validation avoids this.
