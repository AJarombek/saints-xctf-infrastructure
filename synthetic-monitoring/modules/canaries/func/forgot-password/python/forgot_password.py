"""
Selenium script representing a AWS Synthetic Canary function.  Tests that the forgot password functionality on
SaintsXCTF works as expected.
Author: Andrew Jarombek
Date: 7/12/2021
"""

from aws_synthetics.selenium import synthetics_webdriver as webdriver
from aws_synthetics.common import synthetics_logger as logger
from selenium.webdriver.chrome.webdriver import WebDriver as ChromeWebDriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By


def forgot_password():
    # 1) Navigate to the SaintsXCTF website homepage.
    browser: ChromeWebDriver = webdriver.Chrome()
    browser.get('https://saintsxctf.com/')

    logger.info('Loaded SaintsXCTF')
    browser.save_screenshot('home_page.png')

    # 2) Click on the 'Sign In' button.
    button_condition = EC.element_to_be_clickable((By.CSS_SELECTOR, '.signInButton'))
    WebDriverWait(browser, 5).until(button_condition, message='Sign In Button Never Loaded').click()

    url_sign_in_condition = EC.url_to_be('https://saintsxctf.com/signin')
    WebDriverWait(browser, 5).until(url_sign_in_condition, message='Failed to Navigate to the Sign In Page')

    browser.save_screenshot('sign_in_page.png')

    # 3) Click on the 'Forgot Password' link.
    forgot_password_link_condition = EC.element_to_be_clickable((By.LINK_TEXT, 'Forgot Password?'))
    WebDriverWait(browser, 5).until(forgot_password_link_condition, message='Forgot Password Link Never Loaded').click()

    url_forgot_password_condition = EC.url_to_be('https://saintsxctf.com/forgotpassword')
    WebDriverWait(browser, 5).until(
        url_forgot_password_condition,
        message='Failed to Navigate to the Forgot Password Page'
    )

    browser.save_screenshot('forgot_password_page.png')

    # 4) Type an email address into the 'Forgot Password' input field.
    forgot_password_input = browser.find_element_by_css_selector('.sxctf-image-input input')
    forgot_password_input.clear()
    forgot_password_input.send_keys('andrew@jarombek.com')

    browser.save_screenshot('forgot_password_email_typed.png')

    # 5) Click on the 'Send' button.
    forgot_password_button_condition = EC.element_to_be_clickable(
        (By.CSS_SELECTOR, '.form-buttons > .aj-contained-button > button')
    )

    WebDriverWait(browser, 5) \
        .until(forgot_password_button_condition, message='Forgot Password Button Not Clickable') \
        .click()

    # 6) Confirm that the 'Forgot Password' email was sent.
    success_text_condition = EC.text_to_be_present_in_element(
        (By.CSS_SELECTOR, '.sxctf-forgot-password-body h5'),
        'An email was sent to your email address with a forgot password code.'
    )

    browser.save_screenshot('forgot_password_sending.png')

    WebDriverWait(browser, 15).until(success_text_condition, message='Forgot Password Not Successfully Sent')

    browser.save_screenshot('forgot_password_sent.png')


def handler(event, context):
    return forgot_password()
