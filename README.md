# Terraform Ansible Nifi
Repositorie to provide a nifi cluster with ldap auth.
## Requirements
- terraform 
- ansible 2.7 > 
- python3
## Setup Infrastructure
```
terraform apply
```
# Provision Nifi
```
cd ansible-apache-nifi
ansible-playbook nifi-cluster.yaml -i ../hosts.cfg
```