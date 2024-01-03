#!/bin/bash

echo "Enter your domain:"
read domain

sed "s/{your_domain}/$domain/" /docker/wordpress-caddy-docker/caddy/Caddyfile.template > /docker/wordpress-caddy-docker/caddy/Caddyfile

echo "Caddyfile has been created with the domain: $domain"
