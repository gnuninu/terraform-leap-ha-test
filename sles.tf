# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "sles12sp3_volume" {
  name = "sles12sp3-${count.index + 1}"
  source = "http://download.suse.de/install/SLE-12-SP3-JeOS-GM/SLES12-SP3-JeOS-for-kvm-and-xen.x86_64-GM.qcow2"
  #count = "${var.use_shared_resources ? 0 : (contains(var.images, "sles12sp3") ? 1 : 0)}"
  count = 2
  pool = "KVM-images"
  #cc_username = "UC7"
  #cc_password = "61b9a042a2"
  format = "qcow2"
}
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit_sles" {
  name           = "commoninit_sles.iso"
  pool           = "KVM-images"
  user_data      = data.template_file.user_data.rendered
#network_config = data.template_file.network_config.rendered
}

# Define KVM domain to create
resource "libvirt_domain" "sles12sp3_test" {
  name   = "sles12sp3_test${count.index + 1}"
  memory = "512"
  vcpu   = 1
  count = 2
  cloudinit = libvirt_cloudinit_disk.commoninit_sles.id
  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.sles12sp3_volume[count.index].id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
#output "ip" {
#  value = "${libvirt_domain.sles12sp3_test.network_interface.0.addresses.0}"
#}
