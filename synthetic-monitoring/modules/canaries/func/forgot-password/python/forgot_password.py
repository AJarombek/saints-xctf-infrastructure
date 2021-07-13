"""
Selenium script representing a AWS Synthetic Canary function.  Tests that the forgot password functionality on
SaintsXCTF works as expected.
Author: Andrew Jarombek
Date: 7/12/2021
"""

from aws_synthetics.selenium import synthetics_webdriver as webdriver
from aws_synthetics.common import synthetics_logger as logger


def forgot_password():
    browser = webdriver.Chrome()
    browser.get('https://saintsxctf.com/')

    logger.info('Loaded SaintsXCTF')
    browser.save_screenshot('home_page.png')


def handler(event, context):
    return forgot_password()
