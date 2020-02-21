# Docker Image Ghost

A docker-compose based image of ghost that uses only local data.

## Reading / Sources

* [How to Install Ghost CMS with Docker Compose on Ubuntu 18.04](https://www.linode.com/docs/websites/cms/how-to-install-ghost-cms-with-docker-compose-on-ubuntu-18-04/)


Erased entry about nginx from `docker-compose.yml`:

```yml
nginx:
    build:
      context: ./nginx
      dockerfile: Dockerfile
    restart: always
    depends_on:
      - ghost
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx_letsencrypt/:/etc/letsencrypt/
      - ./nginx_html:/usr/share/nginx/html
```