FROM ubuntu:22.04
   # Install necessary packages
   RUN apt-get update && apt-get install -y openssh-server

   # Create the Vagrant user and set up SSH access
   RUN useradd -m -s /bin/bash vagrant && \
       echo 'vagrant:vagrant' | chpasswd && \
       mkdir -p /home/vagrant/.ssh && \
       chmod 700 /home/vagrant/.ssh && \
       wget --no-check-certificate \
       https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
       -O /home/vagrant/.ssh/authorized_keys && \
       chmod 600 /home/vagrant/.ssh/authorized_keys && \
       chown -R vagrant:vagrant /home/vagrant/.ssh

   # Enable password-based authentication for SSH
   RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create privilege separation directory
RUN mkdir -p /run/sshd

   # Expose SSH port
   EXPOSE 22

   # Start SSH service
   CMD ["/usr/sbin/sshd", "-D", "-E", "/var/log/ssh.log"]

