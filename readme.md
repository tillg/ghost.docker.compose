# Docker Image Ghost

A docker-compose based setup of ghost that uses only local data - fully deployed via Ansible.

## Configuring - Deploying - Running 

**Prerequites:** On your machine you need git and Ansible (I use 4.4.0 in Aug 2021). And a server on which you can install & run the setup. The server just needs to have SSH and Python installed. 

Configure your setup by following these steps:

* Create an inventory file per environment. For example one called `TEST.yml`
* Enter the server contact details (like described [here](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-basics-formats-hosts-and-groups)). Make sure in the inventory you set your `env` variable, i.e. `env: TEST`
* Create a corresponding variable file, i.e. `vars/TEST.yml`
* Fill in the required variables in `TEST.yml`, i.e.
  
  ```yaml
  server_url: "test.myserver.com" 
  certbot_use_local_ca: 1
  db_database: test_ghost
  ```

Then execute ` ansible-playbook setup.yml`. Then be patient - and eventually your Ghost blog will be up & running 😜

For a list of all the configuration variables, have a look in `vars/all.yml` or for some configuration explkanations [here](##configuration).

If you are interested in running local tests, see [Test with Multipass](test_with_multipass.md).
## Directory structure

The basic idea of this setup is to have all the ghost data in one directory and it's sub-directories. The overall structure with relevant files is as follows:

```shell
.
├── docker-compose.yaml
├── certbot # Certificates for HTTPS - will be generated
├── ghost_content # Written and managed by ghost
│   ├── apps
│   ├── data
│   ├── images
│   ├── logs
│   ├── settings
│   └── themes
├── ghost_logs # All logs of the ghost app
├── ghost_mysql # The database used by ghost
├── nginx_conf.d # Nginx configuration files
│   ├── mime.types
│   ├── nginx.conf
│   └── proxy.conf
├── nginx_logs # All Nginx logs
├── nginx.secrets # The SSL secrets
```

This dierctory structure is underneath the `docker_ghost_dir` (as defined in `all.yml` or your environment variable file). By default it's `/opt/docker/ghost`.
## Configuration

All configuration is done via the environment variable files. To check what vareiables are available and what default values they are set to, check `vars/all.yml`. Make sure you do not change `all.yml`, but rather override them in your environment variable file, i.e. `vars/TEST.yml`.

Some variables and options that need explanation are described below.

### Ghost image

The version is set thru the docker image. Some possible values:

```yaml
ghost_image: ghost:latest
# or 
ghost_image: ghost:4.11-alpine
```

The `latest` option might make sense for a test and development environment, but when using in production you might want to _freeze_ it to a version you tested... At the time of writing I froze my versions to `4.11` or `4.11-alpine`. For available versions of the official docker ghost image see [here](https://hub.docker.com/_/ghost).

### Setting up email with gmail 

As I wanted to use Google Mail (aka gmail) for sending emails, it took me some time to get all the configurations right. This was a painful process... The final solution for me was the comment of John in [this thread](https://forum.ghost.org/t/gmail-email-problem-configuration/10421)

In short, these are the steps:

- Make sure your email account has two-step-verification switched on [as described here](https://support.google.com/accounts/answer/185839?hl=en&co=GENIE.Platform=Desktop)
- Create an _App Password_ for Ghost (as an unsecure application) [as described here](https://support.google.com/mail/answer/185833?hl=en)
- Set the Account data and App Password in your environment variables file.

### Setting up member management

**Note:** This is configuration that is set within ghost, so not in any variable files.

If you want to have content that is available only to certain readers, you need to set up members. These are the steps to take:

- Use a members enabled theme. Ghost offer the Open Source theme [Lyra](https://github.com/TryGhost/Lyra). It actually looks like Casper, but with members management.
- In the admin page go to Labs and switch members on
- Make sure your email is properly set up. For Gmail as email follow [this guide](https://www.qoncious.com/questions/how-setup-ghost-send-email-using-gmail)

#### Users and members

A finding while working with this setup: You need to be careful and make a distinction between _Users_ and _Members_:

- _Users_ are the ones that create content and administer the website.
- _Members_ are the ones that get access to non-public content.

For some time I was confused about this distinction, because I worked with email addresses that were in both roles. This is perfectly possible and works good, you just need to keep in mind for what reason a mail gets sent or a person can or cannot read non-public content.

To check, test and understand the differences:

- Setup a member-enabled ghost server, i.e. `http://myghost.com`
- Let's create a user, say user1@gmail.com
- Let's create a member, say member1@gmail.com

Now we can test the following scenarios:

- You can log in to http://myghost.com/ghost (the admin-side of the site) as user1@gmail.com. This login is done via a user/password dialog.
- Try to create a blog post when logged in as this user. Make sure the `Post access` field is set to `Members only`.
  **Question**: Is it really `Member only` or should it be `Paid-member only`.
- You **cannot** login to http://myghost.com/ghost as member1@gmail.com.
  **Note**: If you go thru the pasword-forgotten-process with the email address member1@gmail.com, Ghost will not tell you that the user email doesn't exist - this is for security reasons.
- When going on http://myghost.com without being logged in (i.e. in a private browser tab), you will not see the private post.
  Note: You might see a teaser of the non-private posts, even when not being logged in. In case your (test-) post is very short, the teaser might look the same as the entire post... 😀.
- If on the home page you click on `Log in` you **can** log in as user1@gmail.com, you **cannot** log in as member1@gmail.com

#### Hide non-public posts

The standard theme one would probably use when switching on the member feature in ghost is [Lyra](https://github.com/TryGhost/Lyra): It's the default, free theme that supports memberships. It looks pretty similar to the default Ghost theme [Casper](https://github.com/TryGhost/Casper).

I was a little bit surpised to see that non public posts are visible on the home page, even when not being a logged in member. After investigation I understood that the blogs were only visible on the home page as teaser. This means only the abstract was displayed. When testing this with very short sample blog entries, the entire blog might be rendered...

### Backup & Restore

The setup containes a backup tool wrapped in a docker container: We use the [backup container from Tim Bennet](https://github.com/bennetimo/ghost-backup). 

In order to perform a backup of an existing environment (docker-based, that is):

#### Run the backup container

* Check if the backup container is running or needs to be launched with `docker ps`
* To launch it: 

```bash
docker run --name backup -d \
    --volumes-from ghost \
    --network=ghost_grtnr \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD=your_database_root_password \
    -e MYSQL_DATABASE=grtnr-ghost \
    bennetimo/ghost-backup
```

* Make sure the backup container is running with `docker ps` again

* Execute the backup procedure: `docker exec -it backup backup -J`. The `-J` option switches off the JSON based backup as this doen't work with recent ghost versions anymore.

Copy

#### Backup to migrate

In order to migrate the data from the old setup (docker based but different, called PROD-OLD) to the new setup (called NEW) this is the way to go:

* SSH onto PROD-OLD
* Run the backup docker container like so:

```bash
# Launch the backup docker 
# - with access to the ghost docker file system
# - a mounted backup target 
docker run --name ghost-backup -d \
    --volumes-from <your-ghost-container> \
    -v </backup/folder/on/host>:/backups \
    --network=<your-network> \
    -e MYSQL_USER=<yourdbuser> \
    -e MYSQL_PASSWORD=<yourdbpassword> \
    -e MYSQL_DATABASE=<yourdatabase> \
    -e GHOST_SERVICE_USER_EMAIL=<my-email.%40emample.com> \
    -e GHOST_SERVICE_USER_PASSWORD=<mypassword> \
    bennetimo/ghost-backup
```

* log off ssh
* Copy the backup files to the NEW system

```bash
# Go o the tmp directory (in which I have write access!)
scp user@PROD-OLD:"/ghost_backup/*" .

# then 
scp * user@NEW:/ghost_backup
```

* SSH onto the new system
* Restore the data from backup file: Make sure the `backup` container is running, then execute the restore

```bash
# Check if backup container is running:
docker ps

# Start backup container
docker run --name ghost-backup -d \
    --volumes-from <your-ghost-container> \
    -v </backup/folder/on/host>:/backups \
    --network=<your-network> \
    -e MYSQL_USER=<yourdbuser> \
    -e MYSQL_PASSWORD=<yourdbpassword> \
    -e MYSQL_DATABASE=<yourdatabase> \
    -e GHOST_SERVICE_USER_EMAIL=<my-email.%40emample.com> \
    -e GHOST_SERVICE_USER_PASSWORD=<mypassword> \
    bennetimo/ghost-backup

# Run the restore 
docker exec -it ghost-backup restore -i
```

* Restart the ghost docker
## TO DO & DONE

Things on my to do list:

- Add monitoring, may be using ELK, Grafana or [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- Get rid of _Subscribe_ button on the top right corner / on the sandwich menu.
- Add Google tracking to understand visitors
- Add a discourse to the setup so we have comments like [here](https://ghost.org/integrations/discourse/)
- Add [mail2ghost2mail](https://github.com/tillg/mail2ghost2mail) so posts can be created by emails and emails can be sent when posts are published.

### DONE 

* 2021-11-14: Backups are no pulled from server into a local dir.
* 2021-11-03: Migrated to ghost V 4.21.0, since a vulnerability of the old version was published. And of course I testede the migration on my test-site first 
* 2021-10: Migrated the main blog to the new setup: https://grtnr.de 
* 2021-09: I added a backup, I deployed on AWS.
* 2021-08-16: Switched to environment based variable settings
* 2021-08-13: Make the setup use HTTPS, thus dealing with the certificates. Go thru startup logs and review all security warnings.
## Reading / Sources / Tech background

### Reading

- [Best way to backup ghost self hosted - Help - Ghost Forum](https://forum.ghost.org/t/best-way-to-backup-ghost-self-hosted/6246)
- [How to Install Ghost CMS with Docker Compose on Ubuntu 18.04](https://www.linode.com/docs/websites/cms/how-to-install-ghost-cms-with-docker-compose-on-ubuntu-18-04/)
- [Securing Your Nginx Site With Let’s Encrypt & Acme.sh](https://www.snel.com/support/securing-your-nginx-site-with-lets-encrypt-acme-sh/)
- [How to get HTTPS working on your local development environment in 5 minutes](https://medium.com/free-code-camp/how-to-get-https-working-on-your-local-development-environment-in-5-minutes-7af615770eec)
- [Nginx and Let’s Encrypt with Docker in Less Than 5 Minutes](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71)

### How does the HTTPS Certificate thingy work?

**27.2.2020** We are trying to use the following docker image that contains nginx and Certbot: https://github.com/staticfloat/docker-nginx-certbot

We are using certificates from [LetsEncrypt](https://letsencrypt.org/). To distribute them, they use a program called [ACME](https://www.wikiwand.com/en/Automated_Certificate_Management_Environment) that handles a lot for us: It's a command line tool to create, update etc. certificates. In order to prove that you are the legit owner of the certificate that you request, you have to serve a secret from a certain location on your server. Usually this is a file located under a URL like `example.com/.well-known/acme-challenge/`.

The setup we use is described [here](https://www.snel.com/support/securing-your-nginx-site-with-lets-encrypt-acme-sh/).
