
#!/bin/bash

sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html><h1><p> Welcome to Utrains the place to learn DevOps!!.<br> This traffic is servered from:  ${HOSTNAME} </p></h1></html>" > /var/www/html/index.html
