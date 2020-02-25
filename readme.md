# Docker Image Ghost

A docker-compose based image of ghost that uses only local data.

To run your local ghost as docker-compose network:

```shell
git clone git@bitbucket.org:tgartner/ghost.docker.image.git
cd ghost.docker.image
```

Then you need to set some variables (local secrets) as follows:

```shell
cp sample.env .env
```

Then edit your `.env` file. Then start your environment:

```shell
docker-compose up
```

Go to [http://localhost](http://localhost) and enjoy your local docker setup.

## Setting up member management

If you want to have content that is available only to certain readers, you need to set up members. These are the steps to take:

- Use a members enabled theme. Ghost offer the Open Source theme [Lyra](https://github.com/TryGhost/Lyra). It actually looks like Casper, but with members management.
- In the admin page go to Labs and switch members on
- Make sure your email is properly set up. For Gmail as email follow [this guide](https://www.qoncious.com/questions/how-setup-ghost-send-email-using-gmail)

## Reading / Sources

- [How to Install Ghost CMS with Docker Compose on Ubuntu 18.04](https://www.linode.com/docs/websites/cms/how-to-install-ghost-cms-with-docker-compose-on-ubuntu-18-04/)

## Solved problems

### Setting up email with gmail

This was a painful process... The final solution for me was the comment of John in [this thread](https://forum.ghost.org/t/gmail-email-problem-configuration/10421)

**Note**: It really has to be a App Password for Google Mail.
