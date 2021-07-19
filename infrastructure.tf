provider "libvirt" {
  uri   = "qemu+ssh://root@sr.sironi.local/system?socket=/var/run/libvirt/libvirt-sock"
}

variable "network" { default = "default" }
variable "bridge" { default = "br1" }

variable "vm_nifi_cluster" {
    description = "Create lists of machines."
    type = list(string)
    default = ["vm-nifi01","vm-nifi02","vm-nifi03"]
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    HOSTNAME = var.vm_nifi_cluster[count.index]
  }

  count = length(var.vm_nifi_cluster)
}  

# Create one init for each machine.
resource "libvirt_cloudinit_disk" "commoninit" {  
  name = "commoninit_${var.vm_nifi_cluster[count.index]}.iso"
  user_data      = data.template_file.user_data[count.index].rendered
  count = length(var.vm_nifi_cluster)
}      

resource "libvirt_volume" "storage" {
  pool= "storage"  
  name = "${var.vm_nifi_cluster[count.index]}.qcow2"
  count = length(var.vm_nifi_cluster)
  base_volume_name = "cts7.template.qcow2"
}


# Machine Creations
resource "libvirt_domain" "vm" {
  count = length(var.vm_nifi_cluster)
  name = var.vm_nifi_cluster[count.index]
  memory = "4096"
  vcpu = 2
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    bridge = "br1"
    hostname = var.vm_nifi_cluster[count.index]
    wait_for_lease = true
  }

    disk {
    volume_id = libvirt_volume.storage[count.index].id
    }

 
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    { 
      vms_adresss = libvirt_domain.vm.*.network_interface.0.addresses.0
    }
  )
  filename = "hosts.cfg"
}
