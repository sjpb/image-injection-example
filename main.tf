terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

resource "openstack_compute_instance_v2" "test" {
  
  name = "image-injection-test"
  image_name = "cloudinit-test.qcow2"
  flavor_name = "vm.alaska.cpu.general.small"
  key_pair = "slurm-app-ci"
  security_groups = ["default"]
  
  network {
    name = "WCDC-iLab-60"
    access_network = true
  }

  user_data = file("${path.module}/userdata.txt")

  metadata = {
    deployment = "/home/rocky/image-injection"
    server = "prod_server:6452"
  }

}

output "ip" {
    value = openstack_compute_instance_v2.test.access_ip_v4
}
