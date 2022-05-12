
Example of creating a config file with Ansible, with values overridden by cloud-init.

# Setup

```
python3 -m venv venv
. venv/bin/activate
pip install -U pip
pip install -r requirements.txt
terraform init
```

# Image build

```
. venv/bin/activate
export OS_CLOUD=openstack
PACKER_LOG=1 /usr/bin/packer build -on-error=ask openstack.pkr.hcl
```

Things to note:
- The ansible playbook `tasks.yml` is run by Packer and templates out a file `/etc/example.conf` containing the variable `server`.
- `ansible.cfg` and the Packer `extra_arguments` ensure `inventory/` is read during build.
- `group_vars/all` set `server` to `dev_server:1234`. So running ansible directly against an instance will result in this getting templated to `/etc/example.conf`.
- The Packer VM is added to group `builder`.
- `group_vars/builder` overrides `server` to a placeholder value `USERDATA_VALUE_server`, so the Packer-created image has this placeholder.

# Image deploy with changes

```
terraform apply
```
This outputs the IP. Use this to ssh into the instance and check the contents of the templated file:


```
ssh <ip> cat /etc/example.conf
server=prod_server:6452
```

This works by:
- Adding metadata to provide a replacement value for the `server` variable. This is available to cloud-init.
- Providing `user_data` to the instance as a jinja-formatted cloud-config file. This file uses the `runcmd` module to run `sed` to replace the placeholder with the metadata value in `/etc/example.conf`.


# Cleanup

```
terraform destroy
openstack image list | grep cloudinit-test.qcow2
openstack image delete ...
```

# Other thoughts
- Would have to check this runs early enough in the correct place for services etc.
- Want to see how user-data values can be provided (so only accessible to `root`).
- Some things can be done directly using cloud-config modules, e.g. templating systemd unit file fragments.
