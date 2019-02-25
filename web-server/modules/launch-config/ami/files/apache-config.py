#!/usr/bin/env python3

"""
Configure Apache to work with SaintsXCTF in a given environment
Author: Andrew Jarombek
Date: 2/22/2019
"""

import sys

# The environment variable should be passed in as the first argument
env = sys.argv[1]

print('Setting Environment Variable for Apache')

# Set the environment variable in the default sites available config file
with open('/etc/apache2/sites-available/saintsxctf.com.conf', 'r+') as fp:
    contents = fp.readlines()

    # Also alter the server URLs if the environment is dev
    if env == 'dev':
        contents[2] = "    ServerName saintsxctfdev.jarombek.com\n"
        contents[3] = "    ServerAlias www.saintsxctfdev.jarombek.com\n"

    contents.insert(1, "    SetEnv ENV " + env + "\n")
    fp.seek(0)
    fp.writelines(contents)
