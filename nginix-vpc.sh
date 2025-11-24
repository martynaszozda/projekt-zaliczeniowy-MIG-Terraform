#!/bin/bash
#serwer www
sudo apt install -y nginx
sudo systemctl enable nginx
# HTML code of a new website
HOSTNAME=$(hostname) 
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(250, 210, 210);'> <h1>Super</h1> <p><strong>VM Hostname:</strong> $HOSTNAME</p> <p><strong>Pozdrawiam serdecznie Anie</p> </body></html>" | sudo tee /var/www/html/index.html
