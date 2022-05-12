source "openstack" "test" {
  flavor = "vm.alaska.cpu.general.small"
  networks = ["a262aabd-e6bf-4440-a155-13dbc1b5db0e"] # WCDC-iLab-60
  source_image_name = "Rocky-8-GenericCloud-8.5-20211114.2.x86_64"
  ssh_username = "rocky"
  ssh_private_key_file = "~/.ssh/id_rsa"
  ssh_keypair_name =  "slurm-app-ci"
  security_groups = ["default"]
  image_name = "cloudinit-${source.name}.qcow2"
}

build {
  source "source.openstack.test" {}

  provisioner "ansible" {
    playbook_file = "tasks.yml"
    groups = ["builder"]
    keep_inventory_file = true # for debugging
    use_proxy = false # see https://www.packer.io/docs/provisioners/ansible#troubleshooting
    extra_arguments = ["--limit", "builder", "-i", "./ansible-inventory.sh", "-v"]
  }

  post-processor "manifest" {
    custom_data  = {
      source = "${source.name}"
    }
  }
}
