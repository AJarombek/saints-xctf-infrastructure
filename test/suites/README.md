### Overview

Python `unittest` test suites for SaintsXCTF AWS Infrastructure.

### Files

| Filename                   | Description                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------|
| `testACM.py`               | Test suite for the Amazon HTTPS certificates.                                                |
| `testBastion.py`           | Test suite for the Bastion host.                                                             |
| `testDatabase.py`          | Test suite for the applications MySQL databases.                                             |
| `testDatabaseSnapshot.py`  | Test suite for a lambda function which backs up the MySQL databases.                         |
| `testIAM.py`               | Test suite for IAM roles and policies.                                                       |
| `testRoute53.py`           | Test suite for the applications Route53 DNS service.                                         |
| `testSecretsManager.py`    | Test suite for the Secrets Manager service.                                                  |
| `testWebApp.py`            | Test suite for the web application module.                                                   |
| `testWebServer.py`         | Test suite for the web server and launch configuration.                                      |