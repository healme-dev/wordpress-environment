#!/bin/bash

echo "Enter your domain:"
read domain

sudo -u docker -i sed "s/{your_domain}/$domain/" /docker/wordpress-caddy-docker/caddy/Caddyfile.template > /docker/wordpress-caddy-docker/caddy/Caddyfile

echo "Caddyfile has been created with the domain: $domain"
