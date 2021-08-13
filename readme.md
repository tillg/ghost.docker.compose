# Docker Image Ghost

A docker-compose based setup of ghost that uses only local data - fully deployed via Ansible.

## Deploying & running 

**Prerequites:** On your machine git and Ansible. And a server on which you can install & run the setup. The server just needs to have SSH and Python installed. 

Configure your setup by editing `vars/all.yml`. Then edit your inventory in the `hosts` file.

Then execute ` ansible-playbook setup.yml`. Then be patient - and eventually your Ghost blog will be up & running 😜

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

This dierctory structure is underneath the `docker_ghost_dir` (as defined in `all.yml`). By default it's `/opt/docker/ghost`.
## Configuration

All configuration is done via the `all.yml` - or should be done there.

**Ghost image**: The version is set thru the image:

```yaml
ghost:
  image: ghost:latest
```

or 

```yaml
ghost:
  image: ghost:4.11-alpine
```

The `latest` option might make sense for a test and development environment, but when using in production you might want to _freeze_ it to a version you tested... At the time of writing I froze my versions to `4.11` or `4.11-alpine`. For available versions of the official docker ghost image see [here](https://hub.docker.com/_/ghost).

**Email configuration** As I wanted to use Google Mail (aka gmail) for sending emails, it took me some time to get all the configurations right. Besides the correct entries in the configuration and their naming, the critical part was how to make it work with Google's current security setup. The crucial part was that you need a special _App Password_:

- you need to set your Gmail acount to [2-Step Verification](https://www.google.com/landing/2step/).
- And since the ghost app connects just with email & password (which is considered insecure), you need to use an [_App Password_](https://support.google.com/accounts/answer/185833?hl=en).

### Setting up email with gmail

This was a painful process... The final solution for me was the comment of John in [this thread](https://forum.ghost.org/t/gmail-email-problem-configuration/10421)

In short, these are the steps:

- Make sure your email account has two-step-verification switched on [as described here](https://support.google.com/accounts/answer/185839?hl=en&co=GENIE.Platform=Desktop)
- Create an _App Password_ for Ghost (as an unsecure application) [as described here](https://support.google.com/mail/answer/185833?hl=en)
- Set the Account data and App Password in your `.env` file and reference to it from within the `docker-compose.yaml` file.

### Setting up member management

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

## TO DO & DONE

Things on my to do list:

- Go thru startup logs and review all security warnings.
- Have a backup
- Migrate grtnr.de to the new setup
- Add a discourse to the setup so we have comments like [here](https://ghost.org/integrations/discourse/)
- Add [mail2ghost2mail](https://github.com/tillg/mail2ghost2mail) so posts can be created by emails and emails can be sent when posts are published.

### DONE 

* 2021-08-13: Make the setup use HTTPS, thus dealing with the certificates...
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
