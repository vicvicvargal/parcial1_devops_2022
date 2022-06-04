#Ejercicio Terraform

#Definicion de provider
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
#https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean
variable "do_token" {}
variable "pvt_key" {}
#https://www.digitalocean.com/community/tutorials/how-to-use-ansible-with-terraform-for-configuration-management
variable "pub_key" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

#Configuracion de SSH keys
data "digitalocean_ssh_key" "terraformvv3" {
  name = "terraformvv3"
}

#Configuracion de VPC
resource "digitalocean_vpc" "myvpc" {
  name     = "myvpc"
  region   = "nyc1"
  ip_range = "172.20.20.0/24"
}

#Configuracion droplet1
resource "digitalocean_droplet" "web1" {
  image = "ubuntu-20-04-x64"
  name = "web1"
  region = "nyc1"
  size = "s-1vcpu-1gb"
  #https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc
  vpc_uuid = digitalocean_vpc.myvpc.id

  ssh_keys = [
    data.digitalocean_ssh_key.terraformvv3.id
  ]
  
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt update",
      "sudo apt install -y nginx"
    ]

      connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }
  }

  #https://www.digitalocean.com/community/tutorials/how-to-use-ansible-with-terraform-for-configuration-management
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' ngnx.yml"
  }

}

#Configuracion droplet2
resource "digitalocean_droplet" "web2" {
  image = "ubuntu-20-04-x64"
  name = "web2"
  region = "nyc1"
  size = "s-1vcpu-1gb"
  #https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc
  vpc_uuid = digitalocean_vpc.myvpc.id

  ssh_keys = [
    data.digitalocean_ssh_key.terraformvv3.id
  ]
  
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt update",
      "sudo apt install -y nginx"
    ]

      connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }
  }

  #https://www.digitalocean.com/community/tutorials/how-to-use-ansible-with-terraform-for-configuration-management
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' ngnx.yml"
  }

}

## Cofiguracion del load balancer

#https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer
resource "digitalocean_loadbalancer" "lb1" {
  name = "lb1"
  region = "nyc1"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.web1.id, digitalocean_droplet.web2.id ]
}