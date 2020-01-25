### Overview

Module which creates HTTPS certificates for `saintsxctf.com`, `asset.saintsxctf.com`, `uasset.saintsxctf.com`, and 
`dev.saintsxctf.com`.  Wildcard certificates are used for both the dev website and `www` prefixed domains.

### Files

| Filename     | Description                                                                                      |
|--------------|--------------------------------------------------------------------------------------------------|
| `main.tf`    | Generate HTTPS certificates and confirm that they are validated.                                 |