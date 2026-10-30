# Host: EasyWP (Namecheap managed WordPress)

Where the certificate gets installed (README Step 7). Verified 2026-10-30.

## Login

Namecheap account → **Apps** → EasyWP, or a direct EasyWP SSO link. Dashboard: dashboard.easywp.com. 2FA code goes to whoever owns the Namecheap account; see `clients/<domain>.md`.

## Install

Dashboard → the site → **Manage** → scroll to the **Website** section → **SSL Certificate** row → **Change**.

Two radio options:

| Option | What it is |
| --- | --- |
| **Let's Encrypt SSL** (FREE) | Auto-renewing free cert. Choosing this ends the manual renewal chore permanently |
| **Custom SSL Certificate** | The paid cert. Three boxes appear |

Select **Custom SSL Certificate**. Three boxes, each with a **Browse** link and a drag-and-drop/paste area:

| Box | File | Accepts |
| --- | --- | --- |
| Private Key | `example.com.key` | `.txt`, `.key`, or pasted text |
| SSL Certificate | `example_com.crt` | `.crt`, or pasted text |
| CA Bundle (scroll down) | `example_com.ca-bundle` | `.ca-bundle`, or pasted text |

Browse tip on macOS: in the file picker press **Cmd+Shift+G**, paste `~/ssl/example.com/YYYY-MM`, Enter.

Paste tip: in Terminal `pbcopy < ~/ssl/example.com/YYYY-MM/example.com.key`, click in the box, Cmd+V. Repeat per file. Include the `-----BEGIN` and `-----END` lines.

Click **Change** (or Save) at the bottom.

## After

- Takes about 10 minutes to go live. The dashboard row looks identical before and after ("Custom SSL Cert"), so confirm with `verify-cert.sh` or sslshopper.com.
- If the site has EasyWP's CDN turned on, a **Sync** button appears after install. Click it so the CDN serves the same cert.
- The dashboard sometimes shows "Domain connection in progress" with a Check connection button after any change. Cosmetic; click Check connection or ignore. Do not click Change on the Domain row.

## HTTP-file validation on EasyWP

EasyWP has no file manager. To place a file at `/.well-known/pki-validation/`:
1. Dashboard → the site → **SFTP** (or Settings → SFTP) → create/enable SFTP access, note the host, port, user, password.
2. Connect with Cyberduck or FileZilla. Create the folders `.well-known/pki-validation/` under the site root if missing.
3. Upload the `.txt` exactly as given.
4. `./scripts/check-http-file.sh example.com FILENAME.txt`.

DNS validation is simpler when anyone has DNS access.

## WordPress side

If the site was already on HTTPS, nothing changes. If this is the first certificate ever: WordPress → Settings → General → set both URLs to `https://`, then fix mixed content (Really Simple SSL plugin or a search-replace).
