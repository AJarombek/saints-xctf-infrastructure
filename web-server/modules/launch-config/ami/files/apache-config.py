"""
Configure Apache to work with SaintsXCTF in a given environment
Author: Andrew Jarombek
Date: 2/22/2019
"""

import sys

# The environment variable should be passed in as the first argument
env = sys.argv[0]

print('Setting Environment Variable for Apache')

# Set the environment variable in the default sites available config file
with open('/etc/apache2/sites-available/000-default.conf', 'r+') as fp:
    contents = fp.readlines()
    contents.insert(1, 'SetEnv ENV dev')
    fp.seek(0)
    fp.writelines(contents)
