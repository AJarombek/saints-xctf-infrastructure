"""
Runner which executes the test suite for the saintsxctf.com AWS infrastructure
Author: Andrew Jarombek
Date: 2/10/2020
"""

import unittest
import suites.acm as acm
import suites.bastion as bastion
import suites.database as database
import suites.databaseSnapshot as databaseSnapshot
import suites.iam as iam
import suites.route53 as route53
import suites.secretsManager as secretsManager
import suites.webApp as webApp
import suites.webServer as webServer

# Create the test suite
loader = unittest.TestLoader()
suite = unittest.TestSuite()

# Add test files to the test suite
suite.addTests(loader.loadTestsFromModule(acm))
suite.addTests(loader.loadTestsFromModule(bastion))
suite.addTests(loader.loadTestsFromModule(database))
suite.addTests(loader.loadTestsFromModule(databaseSnapshot))
suite.addTests(loader.loadTestsFromModule(iam))
suite.addTests(loader.loadTestsFromModule(route53))
suite.addTests(loader.loadTestsFromModule(secretsManager))
suite.addTests(loader.loadTestsFromModule(webApp))
suite.addTests(loader.loadTestsFromModule(webServer))

# Create a test runner an execute the test suite
runner = unittest.TextTestRunner(verbosity=3)
result = runner.run(suite)
