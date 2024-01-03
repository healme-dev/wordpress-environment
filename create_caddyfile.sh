#!/bin/bash

echo "Enter your domain:"
read domain

sudo sed "s/{your_domain}/$domain/" /docker/wordpress-caddy-docker/caddy/Caddyfile.template | sudo tee /docker/wordpress-caddy-docker/caddy/Caddyfile > /dev/null

echo "Caddyfile has been created with the domain: $domain"
