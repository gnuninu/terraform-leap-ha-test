# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "leap15_volume" {
  name = "leap15-${count.index + 1}"
  source = "https://download.opensuse.org/distribution/leap/15.1/jeos/openSUSE-Leap-15.1-JeOS.x86_64.qcow2"
  #count = "${var.use_shared_resources ? 0 : (contains(var.images, "leap15") ? 1 : 0)}"
  count = 2
  pool = "KVM-images"
  format = "qcow2"
}
data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add root password
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit_sles" {
  name           = "commoninit_sles.iso"
  pool           = "KVM-images"
  user_data      = data.template_file.user_data.rendered
#network_config = data.template_file.network_config.rendered
}

# Define KVM domain to create
resource "libvirt_domain" "leap15_test" {
  name   = "leap15_test${count.index + 1}"
  memory = "512"
  vcpu   = 1
  count = 2
  cloudinit = libvirt_cloudinit_disk.commoninit_sles.id
  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.leap15_volume[count.index].id}"
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
#  value = "${libvirt_domain.leap15_test.network_interface.0.addresses.0}"
#}
