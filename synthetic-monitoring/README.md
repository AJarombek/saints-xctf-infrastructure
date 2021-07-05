### Overview

Infrastructure for AWS Cloudwatch Synthetic Monitoring, which provide end to end tests of critical paths in the 
SaintsXCTF application.

### Commands

```bash
# Zip canary functions for use in Terraform scripts.
cd modules/canaries/func/up
zip -r9 SaintsXCTFUp.zip .
mv SaintsXCTFUp.zip ../../SaintsXCTFUp.zip

cd modules/canaries/func/sign-in
zip -r9 SaintsXCTFSignIn.zip .
mv SaintsXCTFSignIn.zip ../../SaintsXCTFSignIn.zip
```

### Directories

| Directory Name    | Description                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------|
| `env`             | Code to configure AWS Cloudwatch Synthetic Monitoring for *DEV* and *PROD* environments.    |
| `modules`         | Modules for AWS Cloudwatch Synthetic Monitoring.                                            |