"""
Runner which executes the test suite for the saintsxctf.com AWS infrastructure
Author: Andrew Jarombek
Date: 2/10/2020
"""

import unittest
import sys

if __name__ == '__main__':

    # Create the test suite
    tests = unittest.TestLoader().discover('suites')

    if len(sys.argv) > 1:
        log_filename = sys.argv[1]
        with open(log_filename, 'w+') as log_file:

            # Create a test runner an execute the test suite
            runner = unittest.TextTestRunner(log_file, verbosity=3)
            runner.run(tests)
    else:
        runner = unittest.TextTestRunner(verbosity=3)
        runner.run(tests)
