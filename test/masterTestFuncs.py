"""
Testing Suite for my AWS infrastructure
Author: Andrew Jarombek
Date: 2/23/2019
"""

from typing import Callable, Any


def testsuite(tests: list, title: str) -> bool:
    """
    Wrapper function to execute any number of logically grouped tests
    :param tests: a list of tests to execute
    :param title: description of the test suite
    :return: True if the test suite succeeds, false otherwise
    """
    print(f"\u293F Executing Test Suite: {title}")

    success = 0
    failure = 0

    for test_func in tests:
        if test_func():
            success += 1
        else:
            failure += 1

    suitefailed = failure >= 1

    if suitefailed:
        print(f"\u274C Test Suite Success: {title} ({success} passed, {failure} failed)")
    else:
        print(f"\u274C Test Suite Failure: {title} ({success} passed, {failure} failed)")

    return suitefailed


def test(func: Callable[[], Any], title: str) -> bool:
    """
    Wrapper function for testing an AWS resource
    :param func: a function to execute, must return a boolean value
    :param title: describes the test
    :return: True if the test succeeds, false otherwise
    """

    result = func()

    if result:
        print(f"\u2713 Success: {title}")
        return True
    else:
        print(f"\u274C Failure: {title}")
        return False
