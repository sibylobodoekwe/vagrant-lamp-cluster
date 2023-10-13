#!/bin/bash

#Deploy two Ubuntu systems using Vagrant
vagrant init ubuntu/jammy64
vagrant up

#Create a user named 'altschool' with root privileges on the Master node
vagrant ssh master -c "sudo useradd -m -s /bin/bash altschool"
vagrant ssh master -c "sudo usermod -aG sudo altschool"

#Enable SSH key-based authentication from Master to Slave
vagrant ssh master -c "sudo mkdir -p /home/altschool/.ssh"
vagrant ssh master -c "sudo chown altschool:altschool /home/altschool/.ssh"
vagrant ssh master -c "sudo -u altschool ssh-keygen -t rsa -N '' -f /home/altschool/.ssh/id_rsa"
vagrant ssh slave -c "sudo mkdir -p /home/altschool/.ssh"
vagrant ssh slave -c "sudo touch /home/altschool/.ssh/authorized_keys"
vagrant ssh master -c "sudo -u altschool cat /home/altschool/.ssh/id_rsa.pub" > master_public_key
vagrant ssh slave -c "sudo -u altschool cat /vagrant/master_public_key >> /home/altschool/.ssh/authorized_keys"

#Copy data from Master to Slave
vagrant ssh master -c "sudo mkdir -p /mnt/altschool"
vagrant ssh master -c "sudo chown altschool:altschool /mnt/altschool"
vagrant ssh master -c "echo 'Hello from Master' > /mnt/altschool/data.txt"
vagrant ssh master -c "scp /mnt/altschool/data.txt altschool@slave:/mnt/altschool/slave_data.txt"

#Display process overview on Mastermysql -u altschool -p
vagrant ssh master -c "top"

#Install LAMP Stack on both nodes
vagrant ssh master -c "sudo apt update"
vagrant ssh master -c "sudo apt install -y apache2 mysql-server php libapache2-mod-php"

vagrant ssh slave -c "sudo apt update"
vagrant ssh slave -c "sudo apt install -y apache2 mysql-server php libapache2-mod-php"

#Configure Apache and MySQL on both nodes
vagrant ssh master -c "sudo systemctl enable apache2"
vagrant ssh master -c "sudo systemctl enable mysql"
vagrant ssh master -c "sudo mysql_secure_installation"

vagrant ssh slave -c "sudo systemctl enable apache2"
vagrant ssh slave -c "sudo systemctl enable mysql"
vagrant ssh slave -c "sudo mysql_secure_installation"

# Test LAMP setup on both nodes
vagrant ssh master -c "echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/info.php"
vagrant ssh slave -c "echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/info.php"


# Install Nginx on the Master node (for load balancing)
vagrant ssh master -c "sudo apt install -y nginx"

# Configure Nginx for load balancing
cat <<EOF > nginx-load-balancer.conf
http {
    upstream backend {
        server master;
        server slave;
    }
    
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}
EOF

vagrant ssh master -c "sudo mv /vagrant/nginx-load-balancer.conf /etc/nginx/nginx.conf"
vagrant ssh master -c "sudo systemctl restart nginx"

# Cleanup - Remove the master_public_key file
vagrant ssh master -c "rm /vagrant/master_public_key"

#copy the test.php file to the web directory:
rsync -avz test.php altschool@slave:/var/www/html/
 
# Enable SSH key-based authentication from 'Master' to 'Slave'
echo "Configuring SSH key-based authentication from 'Master' to 'Slave'..."
vagrant ssh master -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
MASTER_PUBLIC_KEY=$(vagrant ssh master -c 'cat ~/.ssh/id_rsa.pub')
vagrant ssh slave -c "mkdir -p ~/.ssh && echo '$MASTER_PUBLIC_KEY' >> ~/.ssh/authorized_keys"

# Copy data from 'Master' to 'Slave'
echo "Copying data from 'Master' to 'Slave'..."
vagrant ssh master -c 'rsync -avz /mnt/altschool/ altschool@slave:/mnt/altschool/slave/'

echo "Deployment completed successfully!"
