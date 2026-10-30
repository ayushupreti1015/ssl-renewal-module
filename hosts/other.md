# Host: anything else

Copy this file to `hosts/<host>.md` the first time you install on a new host, and record the click-path.

Every host needs the same three files from `~/ssl/<domain>/<YYYY-MM>/`. Only the labels and the number of boxes change.

| You have | Host labels you may see |
| --- | --- |
| `example.com.key` | Private Key, Key, KEY, Certificate Key, RSA Key |
| `example_com.crt` | Certificate, SSL Certificate, CRT, Server Certificate, Leaf Certificate |
| `example_com.ca-bundle` | CA Bundle, CABUNDLE, Chain, Intermediate Certificate(s), Certificate Chain |

## When the panel has only two boxes

Some panels (Nginx configs, some cloud load balancers, Cloudflare Origin Rules, Vercel, Netlify) want a single "full chain" file: your certificate followed by the bundle, in one block, certificate first.

```bash
cd ~/ssl/example.com/YYYY-MM
cat example_com.crt example_com.ca-bundle > example.com.fullchain.pem
```

Paste `fullchain.pem` as the certificate and the `.key` as the key.

## When the panel wants a different format

| Asked for | Make it with |
| --- | --- |
| PEM | you already have it; `.crt`, `.key`, `.ca-bundle` are PEM |
| PFX / P12 (Windows, IIS, some load balancers) | `openssl pkcs12 -export -out example.com.pfx -inkey example.com.key -in example_com.crt -certfile example_com.ca-bundle` (sets a password; record it with the key) |
| P7B | Namecheap's zip includes one; otherwise `openssl crl2pkcs7 -nocrl -certfile example_com.crt -certfile example_com.ca-bundle -out example.com.p7b` |
| DER | `openssl x509 -in example_com.crt -outform der -out example.com.der` |

## Known hosts, rough paths

Unverified; confirm and update when you use one.

**WP Engine**: User Portal → the site → SSL → Add certificate → "3rd party certificate" → paste key, cert, chain.

**Kinsta**: MyKinsta → the site → Domains → SSL → Custom SSL → paste key + cert (chain goes in the same box after the cert). Kinsta also offers free Cloudflare SSL.

**SiteGround (Site Tools)**: Security → SSL Manager → Import → paste key, cert, CA chain.

**Plesk**: Websites & Domains → SSL/TLS Certificates → Add → upload .key, .crt, CA bundle → then Hosting Settings → pick the cert.

**Nginx / Apache on a VPS**: copy `.key` and `fullchain.pem` to `/etc/ssl/`, point `ssl_certificate` / `SSLCertificateFile` at them, reload the service.

**Cloudflare in front of the site**: the browser sees Cloudflare's edge certificate, which Cloudflare renews on its own. Your certificate only matters on the origin server (host → Cloudflare). Install it on the host as above, and set Cloudflare SSL mode to Full (strict).

**Squarespace, Wix, Shopify, Webflow**: these manage SSL themselves. Custom certificates are usually not accepted. Nothing to install.

## Fill in when you use it

- Host name:
- Panel URL and who has the login:
- Path to the SSL screen:
- Boxes and what goes in each:
- Time to go live:
- SFTP access for HTTP-file validation:
- Gotchas:
