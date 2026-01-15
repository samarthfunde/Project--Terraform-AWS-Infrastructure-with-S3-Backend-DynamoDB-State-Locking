#!/bin/bash

sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1> I Created Infrastructure using Terraform</h1>" | sudo tee /var/www/html/index.html