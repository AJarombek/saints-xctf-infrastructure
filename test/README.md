### Overview

This is the testing suite for the SaintsXCTF cloud infrastructure.  Tests are run in Python using Amazon's boto3 module.  
Each infrastructure grouping has its own test suite.  Each test suite contains many individual tests.  Test suites can 
be run independently or all at once.

To run the test suite, execute the following command from this directory:

```bash
# Test production
unset TEST_ENV
export AWS_DEFAULT_REGION=us-east-1
python3 runner.py

# Test development
export TEST_ENV=dev
export AWS_DEFAULT_REGION=us-east-1
python3 runner.py
```

Or if you want the test results to be placed in a log, execute the following command:

```bash
python3 runner.py test_results.log
```

### Jenkins Job

This test suite has a corresponding Jenkins job located on my 
[Jenkins server](http://jenkins.jarombek.io/job/saints-xctf-infrastructure/).  The source code is located in my 
[global-jenkins-jobs](https://github.com/AJarombek/global-jenkins-jobs/tree/master/saints-xctf-infrastructure) repository.

### Files

| Filename             | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `suites/`            | Test suites written in Python's `unittest` library.                                          |
| `utils/`             | Utility functions for working with the `boto3` AWS SDK.                                      |
| `runner.py`          | Invokes all the test suites.                                                                 |
| `setup.sh`           | Bash script to setup the environment for a test suite.                                       |
| `requirements.txt`   | Used to create a virtual environment with `pipenv`.                                          |
| `Pipfile`            | Used to create a virtual environment with `pip`.                                             |