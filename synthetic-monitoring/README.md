### Overview

Infrastructure for AWS Cloudwatch Synthetic Monitoring, which provide end to end tests of critical paths in the 
SaintsXCTF application.

### Commands

```bash
# Zip canary functions for use in Terraform scripts.
zip -r9 SaintsXCTFSignIn.zip .
```

### Directories

| Directory Name    | Description                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------|
| `env`             | Code to configure AWS Cloudwatch Synthetic Monitoring for *DEV* and *PROD* environments.    |
| `modules`         | Modules for AWS Cloudwatch Synthetic Monitoring.                                            |