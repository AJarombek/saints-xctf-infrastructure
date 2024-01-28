### Overview

Modules which create HTTPS certificates for `saintsxctf.com`, `asset.saintsxctf.com`, `uasset.saintsxctf.com`, and 
`dev.saintsxctf.com`.  Wildcard certificates are used for both the dev website and `www` prefixed domains.

### Directories

> NOTE: INACTIVE directories are used for development purposes and are not currently deployed to AWS.

| Directory Name        | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| `api-saints-xctf`     | ACM certificates for `*.api.saintsxctf.com`.                  |
| `auth-saints-xctf`    | *`INACTIVE`* ACM certificates for `*.auth.saintsxctf.com`.    |
| `dev-api-saints-xctf` | *`INACTIVE`* ACM certificates for `*.dev.api.saintsxctf.com`. |
| `dev-saints-xctf`     | *`INACTIVE`* ACM certificates for `*.dev.saintsxctf.com`.     |
| `fn-saints-xctf`      | *`INACTIVE`* ACM certificates for `*.fn.saintsxctf.com`.      |
| `saints-xctf`         | ACM certificates for `*.saintsxctf.com` and `saintsxctf.com`. |