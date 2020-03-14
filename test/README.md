### Overview

This is the testing suite for the SaintsXCTF cloud infrastructure.  Tests are run in Python using Amazon's boto3 module.  
Each infrastructure grouping has its own test suite.  Each test suite contains many individual tests.  Test suites can 
be run independently or all at once.

To run the test suite, execute the following command from this directory:

```
python3 runner.py
```

### Jenkins Job

This test suite has a corresponding Jenkins job located on my 
[Jenkins server](http://jenkins.jarombek.io/job/saints-xctf-infrastructure/).  The source code is located in my 
[global-jenkins-jobs](https://github.com/AJarombek/global-jenkins-jobs/tree/master/saints-xctf-infrastructure) repository.

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `acm/`               | Test suite for the Amazon HTTPS certificates.                                                |
| `bastion/`           | Test suite for the Bastion host.                                                             |
| `databases/`         | Test suite for the applications MySQL databases.                                             |
| `databasesnapshot/`  | Test suite for a lambda function which backs up the MySQL databases.                         |
| `iam/`               | Test suite for IAM roles and policies.                                                       |
| `route53/`           | Test suite for the applications Route53 DNS service.                                         |
| `secretsmanager/`    | Test suite for the Secrets Manager service.                                                  |
| `webapp/`            | Test suite for the web application module.                                                   |
| `webserver/`         | Test suite for the web server and launch configuration.                                      |
| `runner.py`          | Invokes all the test suites.                                                                 |
| `setup.sh`           | Bash script to setup the environment for a test suite.                                       |
| `requirements.txt`   | Used to create a virtual environment with `pipenv`.                                          |
| `Pipfile`            | Used to create a virtual environment with `pip`.                                             |