# Test with Multipass

In order to test my Ansible scripts I use Multipass. 

## Launch & prep new instance

This is how I set up a fresh instance, create my test user and run my Ansible scripts against it.

**Note**: I use multipass on the Mac with the hyperkit virtualizer. 
First make sure my public SSH key is in my `cloud-config.yml`:

* Copy my public key in clipboard: `pbcopy < ~/.ssh/id_rsa.pub`
* The edit `cloud-config.yml` and replace the value behind `ssh_authorized_keys:`

Now we can launch fresh instances with one line:

```bash
# Launch a fresh mulitpass / Ubuntu VMwith my testuser pre-configured
multipass launch -c 2 -m 2G -d 20G --cloud-init cloud-config.yml

# See wether the new instance is running and what IP address it got
multipass list
# or create an extra terminal window and
watch multipass list
```

You should be able to login via ssh: `ssh testuser@<IP address>`.

## Execute Ansible

First you need to update your host file, so it contains the IP address of the newly created multipass VM. 

That's what my host file looks like currently:

```yml
[control]
controller ansible_connection=local  ansible_python_interpreter=/usr/bin/python3

[server]
home.server.docker-compose ansible_host=192.168.178.91 ansible_sudo_pass=secret ansible_connection=ssh ansible_user=testuser ansible_python_interpreter=/usr/bin/python3
```

Now everything is in place, and you can launch the Ansibel script:

```bash
ansible-playbook setup.yml
```

Now be patient and eventually you will have your system up & running 😜

In order to see the progress, I usually have 2 terminal windows open (besides the one running the ansible playbook): On both terminals I ssh into the VM, then execute the following commands:

* `htop`, this nicely shows you how busy your VM is
* `sudo watch docker ps`, this returns errors at first (as docker is not installed yet), but then shows the empty list of running dockers. Once you see the dockers running, you can see the Grafana dashboard in your browser: Simply point it to the IP of your VM.
