# lwgf.us

| Field | Value |
| --- | --- |
| Client | The Lakewood Group |
| Domain(s) on the cert | lwgf.us, www.lwgf.us |
| Registrar (where the domain is renewed) | Namecheap (account: lakewoodgroup) |
| Nameservers (`dig +short NS domain`) | ns49.domaincontrol.com, ns50.domaincontrol.com |
| DNS provider (who runs the panel) | GoDaddy. Namecheap's Advanced DNS tab is NOT authoritative; records added there do nothing |
| Who has DNS access | Supervisor (added the 2026-10 validation record) |
| Host | EasyWP, Starter plan, yearly billing (see `hosts/easywp.md`) |
| Host panel and who has the login | Namecheap account "lakewoodgroup" → Apps → EasyWP |
| Where the 2FA code goes | Eleni's phone |
| Email provider (from MX / autodiscover records) | Microsoft 365 (`autodiscover` CNAME to outlook.com) |
| Certificate vendor | Namecheap (see `vendors/namecheap.md`) |
| Certificate product | PositiveSSL (Sectigo), Domain Validation, single domain |
| Vendor subscription / order ID | SSL 34101972 (original), 5-year subscription |
| Subscription paid through | ~April 2031 (estimate; confirm in Namecheap) |
| Current certificate ID | 36559507 |
| Current certificate expires | 2027-05-16 |
| Next reissue by | 2027-04-16 |
| Key location | `~/ssl/lwgf.us/2026-10/lwgf.us.key` on Ayush's Mac. TODO: copy to team password manager and update this line |
| CSR subject used | `/C=US/ST=New Jersey/L=Fairfield/O=The Lakewood Group/CN=lwgf.us` |
| Validation method that worked | DNS CNAME, added at GoDaddy |
| Notes | Website IPs 63.250.43.5 and 63.250.43.6 (EasyWP). EasyWP offers free Let's Encrypt; raise with client before next reissue to end the manual cycle. |

## History

| Date | What | By |
| --- | --- | --- |
| 2026-10-30 | Reissued cert 36559507 (200-day limit). First CNAME attempt in Namecheap DNS was ignored (nameservers are GoDaddy); supervisor added it at GoDaddy. Issued in ~40 min. Installed on EasyWP, verified live, expires 2027-05-16. Old cert 34101972 marked Replaced. | Ayush |
