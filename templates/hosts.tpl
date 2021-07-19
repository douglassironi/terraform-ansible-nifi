[all:vars]
ansible_become=yes
ansible_user=ansible

[nifi-cluster]
%{ for ip in vms_adresss ~}
${ip}
%{ endfor ~}