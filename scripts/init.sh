#!/bin/bash

# Update package lists
apt-get update
apt-get install -y nginx

# Enable and start Nginx service
systemctl enable nginx
systemctl start nginx