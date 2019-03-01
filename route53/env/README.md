### Overview

Route53 configurations for each environment.  There are three environments - `dev`, `prod`, and a global environment 
(`all`).

### Directories

| Directory Name    | Description                                                                                     |
|-------------------|-------------------------------------------------------------------------------------------------|
| `dev`             | Code to build DNS records and HTTPS certificates for the SaintsXCTF web application in `dev`.   |
| `prod`            | Code to build DNS records and HTTPS certificates for the SaintsXCTF web application in `prod`.  |
| `all`             | Code to build a DNS zone for the SaintsXCTF application.                                        |