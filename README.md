# Parcial 1 Victor Vargas

 Parcial 1 , Victor A. Vargas Contreras 22000898



## Ejecutando codigo de Vagrant

El presente codigo implementa 2 servidores de NGINX los cuales cuentan con roles distintos y reciben carga a traves de un balanceador de carga. 

Se utilizaron guias y pasos de Digital Ocean que se encuentran citados en el codigo y seccion correspondiente. 

Como prerequisitos, se asume un sistema Ubuntu 20.04 con los siguientes softwares instalados:

1. Terraform, [link](https://www.terraform.io/cli/install/apt "Terraform") de instalacion
2. Ansible, [link](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html "Ansible") de instalacion

Adicionalmente el usuario debe contar con los siguientes servicios:

1. Cuenta activa en Digital Ocean con un Token-API disponible 
2. Saldo suficiente en Digital Ocean (Menor a ~2$)

Descargar el presente repositorio y descomprimilo en una nueva carpeta

Abrir una nueva terminal en el directorio de la carpeta recien descomprimida y proceder a ejectuar el siguiente comando:

`terraform init`

Para visualizar como Digital Ocean implementara la definicion de los droplets, se debe ejecutar el siguiente comando: 

`terraform plan -var "do_token=token" -var "pvt_key=/keys/priv.ppk" -var "pub_key=pub.pub"`


- token = Token API generado para cada cuenta en Digital Ocean
- pvt_key = llave privada encontrada en la carpeta de keys
- pub_key = llave publica encontrada en la carpeta de keys 

El usuario debe unicamente modificar la variable *token* por su propio identificador. 

Una vez ejecutado este comando, se listara de que tipo de infrastuctura Digital Ocean aprovisionara para los servicios descritos. 

Al estar deacuerdo de la manera de implementarlos con el comando:
`terraform apply -var "do_token=token" -var "pvt_key=/keys/priv.ppk" -var "pub_key=pub.pub"`

Para verificar que los servicios esten provisionados, en DigitalOcean portal web al navegar a la seccion de "Droplets" se debe de observar los dos VMs en donde *web1* y *web2* deberan ser listados

En la seccion de Virtual Private Cloud tambien debe de listarse la red privada creada.

Al ingresar a cada uno de los droplets, podemos ingresar a su IP y corrobobar que en efecto el servicio NGINX se este ejecutando

Si se desean eliminar los droplets creados remotamente utilice el siguiente comando:

`terraform apply -destroy -var "do_token=token" -var "pvt_key=/keys/priv.ppk" -var "pub_key=pub.pub"`


## Ejecutando el codigo de Vagrant

Para la siguiente practica se asume que la maquina anfitrion cuenta con los siguientes programas/servicios:

1. Sistema operativo Windows 10
2. Vagrant [link](https://www.vagrantup.com/downloads "Terraform") de instalacion
3. VMware Workstation

Debera descargar el repositorio y descomprimirlo. En una terminal navegue hacia la carpeta llamada *vagrant* y ejecute el siguiente comando

`vagrant up`

No fue posible automatizar todo el flujo de aprovisionamiento. La maquina VM1 que fue creada como el *Manager* debe proveer un token el cual debe ser insertado en la linea 25 sustituyendo el campo SWMTKN-Token :

`docker swarm join --token SWMTKN-Token 192.168.0.1:2377`

Token que encontramos primero ingresando por ssh a la maquina 1

`ssh vagrant virtual1`

Ejecutamos el comando 

`docker swarm init --listen-addr 192.168.0.1:2377 --advertise-addr 192.168.0.1:2377` 

Nos brindara el token a reemplazar por SWMTKN-Token en la linea 25. 

Un ejemplo de esta implementacion del token se encuentra en la linea 27 del archivo Vagrantfile

Para visualizar a DockerSwarm ejecutandose, ingrese mediante ssh a la maquina virutal1 y ejecute el comando 

`docker node ls`

Debera de observar a *virtual1* y *virtual2* en estado activo siendo la *virtual1* en estado como ""Leader"" 

Para detener y destruir las VM's creadas ejecutamos los siguientes comandos

`vagrant halt`

y

`vagrant destroy` 


