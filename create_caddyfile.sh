#!/bin/bash

echo "Enter your domain:"
read domain

sudo -u docker -i sed "s/{your_domain}/$domain/" /docker/wordpress-caddy-docker/caddy/Caddyfile.template | sudo -u docker -i tee /docker/wordpress-caddy-docker/caddy/Caddyfile > /dev/null

echo "Caddyfile has been created with the domain: $domain"
