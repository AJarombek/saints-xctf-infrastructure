### Overview

Python `unittest` test suites for SaintsXCTF AWS Infrastructure.

### Files

| Filename                   | Description                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------|
| `testACM.py`               | Test suite for the Amazon HTTPS certificates.                                                |
| `testBastion.py`           | Test suite for the Bastion host.                                                             |
| `testDatabase.py`          | Test suite for the applications MySQL databases.                                             |
| `testDatabaseBackup.py`    | Test suite for an S3 bucket that holds database backup files.                                |
| `testDatabaseDeployment.py`| Test suite for a lambda function which deploys scripts to RDS databases.                     |
| `testDatabaseSnapshot.py`  | Test suite for a lambda function which backs up the MySQL databases.                         |
| `testIAM.py`               | Test suite for IAM roles and policies.                                                       |
| `testRoute53.py`           | Test suite for the applications Route53 DNS service.                                         |
| `testSecretsManager.py`    | Test suite for the Secrets Manager service.                                                  |
| `testSXCTFAsset.py`        | Test suite for the `asset.saintsxctf.com` S3 bucket.                                         |
| `testSXCTFFn.py`           | Test suite for the `fn.saintsxctf.com` API Gateway REST API and Lambda functions.            |
| `testSXCTFUasset.py`       | Test suite for the `uasset.saintsxctf.com` S3 bucket.                                        |
| `testWebApp.py`            | Test suite for the web application module.                                                   |
| `testWebServer.py`         | Test suite for the web server and launch configuration.                                      |