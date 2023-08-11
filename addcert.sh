#!/bin/bash

echo "Please add the certificate. Press Ctrl+D to finish:"
userInput=$(cat)

if [ "$1" == "fullchain" ]; then
  echo "$userInput" | sudo -u docker tee /docker/wordpress-nginx-docker/ssl/fullchain.pem > /dev/null
  echo "Complete"
else
  echo "$userInput" | sudo -u docker tee /docker/wordpress-nginx-docker/ssl/privkey.pem > /dev/null
  echo "Complete"
fi