# Docker Image Ghost

A docker-compose based image of ghost that uses only local data.

- [Running locally](#running-locally)
- [Directory structure](#directory-structure)
- [Configuration](#configuration)
  - [Configuration in `docker-compose.yaml`](#configuration-in--docker-composeyaml-)
  - [Configuring nginx](#configuring-nginx)
  - [Setting the URL](#setting-the-url)
  - [Creating certificates](#creating-certificates)
  - [Setting up member management](#setting-up-member-management)
- [Reading / Sources](#reading---sources)
- [Solved problems](#solved-problems)
  - [Setting up email with gmail](#setting-up-email-with-gmail)

## Running locally

To run your local ghost as docker-compose network:

```shell
git clone git@bitbucket.org:tgartner/ghost.docker.image.git
cd ghost.docker.image
```

Then you need to set some variables (local secrets) as follows:

```shell
cp sample.env .env
```

Then edit your `.env` file (it's self explaining). Then start your environment:

```shell
docker-compose up
```

Go to [http://localhost](http://localhost) and enjoy your local docker setup.

## Directory structure

The basic idfea of this setup is to have all the ghost data in one directory and it's sub-directories. The overall structure with relevant files is as follows:

```shell
.
├── docker-compose.yaml
├── ghost_content # Written and managed by ghost
│   ├── apps
│   ├── data
│   ├── images
│   ├── logs
│   ├── settings
│   └── themes
├── ghost_logs # All logs of the ghost app
├── ghost_mysql # The database used by ghost
├── nginx_conf # Nginx configuration files
│   ├── mime.types
│   ├── nginx.conf
│   └── proxy.conf
├── nginx_logs # All Nginx logs
├── readme.md
└── sample.env
└── .env # The secrets of yours, like gmail password
```

## Configuration

Besides the secrets you entered in the `.env` file, there are a couple of further configuration options you have:

### Configuration in `docker-compose.yaml`

The first place you should check for configuration options is the `docker-compose.yaml` file. Most of the options are self-explaining. Some notes about those options:

**Ghost image**: The version is set thru the image:

```yaml
ghost:
  image: ghost:latest
```

The `latest` option might make sense for a test and development environment, but when using in production you might want to _freeze_ it to a version you tested... At the time of writing I froze my versions to `3.8` or `3.8-alpine`.

**`environment` variables**: The variable set within this section are passed on as configuration to the standard ghost docker iumage. For example the variable `database__connection__user` will be set in the ghost configuration JSON file. Find details about the configuration options in the [ghost documentation](https://ghost.org/docs/concepts/config/).

**Email configuration** As I wanted to use Google Mail (aka gmail) for sending emails, it took me some time to get all the coinfigurations right. Besides the correct entries in the configuration and their naming, the critical part was how to make it work with Google's current security setup. The curcial parts were

- you need to set your Gmail acount to [2-Step Verification](https://www.google.com/landing/2step/).
- And since the ghost app connects just with email & password (which is considered insecure), you need to use a so called [_app password_](https://support.google.com/accounts/answer/185833?hl=en).

### Configuring nginx

Nginx is the reverse proxy sitting in front of the ghost container. It is configured by files that are located within `./nginx_conf/`. Have a look at them, most is easy to understand. `nginx.conf` is the main config file, it _includes_ the mime types and the `proxy.conf`.

### Setting the URL

The URL of your site is kind of important 😀. In the original setup it is set to `localhost`. To set it to a _real_ website name, you need to change it both, in the `docker-compose.yaml` as ghost variable **and** in the `nginx.conf` file.

### Setting up email with gmail

This was a painful process... The final solution for me was the comment of John in [this thread](https://forum.ghost.org/t/gmail-email-problem-configuration/10421)

In short, these are the steps:

- Make sure your email account has two-step-verification switched on [as described here](https://support.google.com/accounts/answer/185839?hl=en&co=GENIE.Platform=Desktop)
- Create an _App Password_ for Ghost (as an unsecure application) [as described here](https://support.google.com/mail/answer/185833?hl=en)
- Set the Account data and App Password in your `.env` file and reference to it from within the `docker-compose.yaml` file.

### Creating certificates

To do...

### Setting up member management

If you want to have content that is available only to certain readers, you need to set up members. These are the steps to take:

- Use a members enabled theme. Ghost offer the Open Source theme [Lyra](https://github.com/TryGhost/Lyra). It actually looks like Casper, but with members management.
- In the admin page go to Labs and switch members on
- Make sure your email is properly set up. For Gmail as email follow [this guide](https://www.qoncious.com/questions/how-setup-ghost-send-email-using-gmail)

## Reading / Sources / Tech background

### Reading

- [How to Install Ghost CMS with Docker Compose on Ubuntu 18.04](https://www.linode.com/docs/websites/cms/how-to-install-ghost-cms-with-docker-compose-on-ubuntu-18-04/)

### Why the URL is in the `.env` file

You might wonder why the URL of our blog is stored in the `.env` file, as this isn't really a secret... 😀

The reason is a more comfortable way of working with different environments: As the `.env` file is local and specific to every environment, we can have a different URL in different environments. The typical setup would be to have the `SERVER_URL` set to the _real_ URL on the server and to `localhost` on your dev machine. So you can use the same configurations, except the URL...
