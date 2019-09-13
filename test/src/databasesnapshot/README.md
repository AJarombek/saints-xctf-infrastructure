### Overview

Test code for the lambda function which backs up RDS MySQL databases.  The database backup test suite can 
be run individually or inside the master test suite.

### Files

| Filename                       | Description                                                                           |
|--------------------------------|---------------------------------------------------------------------------------------|
| `databaseSnapshotTestFuncs.py` | Functions to test the database backup AWS Lambda function.                            |
| `databaseSnapshotTestSuite.py` | Test suite for database backups.                                                      |