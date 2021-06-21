/**
 * AWS Synthetic Monitoring Canary function for testing a sign in operation on SaintsXCTF.
 * @author Andrew Jarombek
 * @since 6/20/2021
 */

const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const signInUser = async () => {
    log.info('Starting saints-xctf-sign-in canary.');
    const page = await synthetics.getPage();
    const response = await page.goto('https://saintsxctf.com', {waitUntil: 'domcontentloaded', timeout: 30000});

    if (!response) {
        throw 'Failed to load SaintsXCTF, the website might be down.'
    }
}

exports.handler = async () => {
    return await signInUser();
}