### Overview

Code to create an Ubuntu-based AMI for the SaintsXCTF web application.  The AMI is created with Packer and the help of 
Ansible.  To build the AMI, run the following commands:

```
packer validate image.json
packer build image.json
```

### Files

| Filename                      | Description                                                                                  |
|-------------------------------|----------------------------------------------------------------------------------------------|
| `files/`                      | Local files to place on the AMI.                                                             |
| `image.json`                  | Packer configuration for building the AMI.                                                   |
| `saints-xctf-setup-image.sh`  | Bash script used to install Ansible on the AMI.                                              |
| `saints-xctf-playbook.yml`    | Ansible Playbook used for installing software on the AMI.                                    |