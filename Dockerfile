# Docker image to use with Vagrant
# Aims to be as similar to normal Vagrant usage as possible

# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set the environment variable to indicate it's a Docker container
ENV container docker

# First, update the package repository and perform a system upgrade
RUN apt-get update && apt-get dist-upgrade -y

# Install necessary packages including SSH, sudo, libffi-dev, systemd, and openssh-client
RUN apt-get install -y --no-install-recommends ssh sudo libffi-dev systemd openssh-client

# The following instructions were in a separate block, so they are now correctly merged.
# Install the SSH server
RUN apt-get install -y openssh-server

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

# Enable SSH key-based authentication
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t ecdsa -N "" -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key

# Create privilege separation directory
RUN mkdir -p /run/sshd

# Expose SSH port
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D", "-E", "/var/log/ssh.log"]
