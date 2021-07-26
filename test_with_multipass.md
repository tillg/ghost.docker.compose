# Test with Multipass

In order to test my Ansible scripts I use Multipass. 

## Launch & prep new instance

This is how I set up a fresh instance, create my test user and run my Ansible scripts against it.

**Merke**: Der Teil mit dem `network` geht auf Mac nur wenn VirtualBox als Treiber eingerichtet ist. Mit hyperkit geht das nicht, da kann man es einfach ignorieren. Hyperkit läuft bei mir deutlich stabiler.

```bash
# First check what networks we have
multipass networks

# Launch an instance that is attached to a network
multipass launch --network en0   # on my Mac that's the Wifi
# or
multipass launch --network en7   # on my Mac that's the cable
# On my Mac I give it more memory & CPUs:
multipass launch -c 2 -m 2G -d 20G --network en7

# See wether the new instance is running and what IP address it got
multipass list
# or create an extra terminal window and
watch multipass list

# Create my test user
multipass shell <name>

# then within the VM:
sudo adduser testuser
# ...click yourself thru the questions...

# Add the user to the sudo group
sudo usermod -aG sudo testuser

# Add the ssh key from my controlling machine (i.e. my Mac) so Ansible can access via ssh
su - testuser
mkdir ~/.ssh
nano ~/.ssh/authorized_keys   # If you are fluent in vi feel free to use it - I am not 😜
```

Now you have to copy your public ssh key over from your machine. An easy way to do this (on Mac) would be to copy the it to the clipboard and then paste it into the open nano editor:
```bash
pbcopy < ~/.ssh/id_rsa.pub
```

Close & save your nano editor and you should be able to login via ssh: `ssh testuser@<IP address>`.

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
