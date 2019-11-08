# terraform-leap-ha-test

Terraform project to run 2 leap15  nodes (ha nodes in future) with libvirt/KVM

## Install terraform:

download it from terraform website and copy it to:

` /usr/local/bin/terraform`

## Add repo and install libvirt provider:

https://software.opensuse.org/download/package?project=systemsmanagement:terraform&package=terraform-provider-libvirt

copy exacutable:

`cp /usr/bin/terraform-provider-libvirt /home/nicoladm/.terraform.d/plugins/linux_amd64/`


## Example tf files and structure:
 
https://github.com/dmacvicar/terraform-provider-libvirt/tree/master/examples/v0.12/leap15

## Make sure to change the kvm storage pool as needed in leap15.tf

`pool = "KVM-images"`

if you want to use the default for example:

`pool = "default"`

## Initialise terraform provider in the project dir

` nic-leap15:~/terraform_stuff/terraform-leap15-ha-test> terraform init`

## calculate and check terraform plan before apply

` terraform plan`

## apply

` nic-leap15:~/terraform_stuff/terraform-leap15-ha-test> terraform apply`

## check Ip nad mac given to guest

` virsh net-dhcp-leases default`

You can ssh into the guests using the root password defined in cloud_init.cfg

## once you are done destroy the VMs

`terraform destroy`
