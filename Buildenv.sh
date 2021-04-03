#!/bin/bash
setting_environemt() {
#Function for setting docker environment in vagrant
   echo "Started building environment"
   echo "Creating an VM with Ubuntu 16.04 in vagrant"
   vagrant init ubuntu/bionic64
   echo "Waiting the environment to become up"
   sleep 300
   echo "Install Docker in Vagrant"
   #Move to vagrant file directory
   cd /home/Vagrantfile
   #To make docker env up
   vagrant up
   echo "Waiting the environment to become up"
   sleep 300
   value=$(vagrant global-status)
   echo "$value"
}

containers_image_build() {
#Function for buliding docker images for containers
   echo "Building docker image for frontend"
   docker build --file DockerFile1 -t frontendimage .
   sleep 60
   echo "Waiting for docker image list"
   if [[ $(docker image list | grep frontend) == *"frontend"* ]];then
       echo " Docker Image is build"
   fi
   echo "Building docker image for backend"
   docker build --file DockerFile2 -t backendimage .
   sleep 60
   echo "Waiting for docker image list"
   if [[ $(docker image list | grep backend) == *"backend"* ]];then
       echo " Docker Image is build"
   fi
   echo "Building the controller container"
   docker build --file DockerFile3 -t controllerimage .
   sleep 60
   echo "Waiting for docker image list"
   if [[ $(docker image list | grep controller) == *"controller"* ]];then
       echo " Docker Image is build"
   fi
}
containers_building() {
#Function for spinning up the containers 
   echo "Creating the frontend containers"
   docker run --name frontend-1 -d frontendimage
   sleep 5
   docker run --name frontend-2 -d frontendimage
   sleep 5
   if [[ $(docker ps | awk '{print $6'} ) != *"error"* || $(docker ps | awk '{print $6'} ) != *"failed"* ]];then
       echo " Front end containers  are build"
   else
       echo "Got an error exit function called"
       exit 1
   fi
   echo "Creating the frontend containers"
   docker run --name backend-1 -d backendimage
   sleep 5
   docker run --name backend-2 -d backendimage
   sleep 5
   if [[ $(docker ps | awk '{print $6'} ) != *"error"* || $(docker ps | awk '{print $6'} ) != *"failed"* ]];then
       echo " Back end containers  are build"
   else
       echo "Got an error exit function called"
       exit 1
   fi
   echo "Creating the Controller container"
   docker run --name controller -d controllerimage
   sleep 5
}
call_ssh_check() {
#Function for checking the ssh 
   cat "$1  $2" >> /etc/hosts
   echo "Logging in into Container"
   docker exec -it $2 /bin/bash
   sleep 5
   echo "root:root123" | chpasswd
}
add_ssh_keys() {
#Function for adding ssh keys
   echo " ssh to containers"
   spawn ssh -o  StrictHostKeyChecking=no root@$1
   expect -exact ": "
   send "rootme\r"
   hosts_file=$2
   container_array=$1
   for items in "${hosts_file[*]}";
      do
        echo "Copying ssh keys of all Containers connected"
        cat "${hosts_file[items]}" >> /etc/hosts
        spawn ssh-copy-id -o  StrictHostKeyChecking=no ${container_array[items]}
        expect -exact ": "
        send "root123\r"
        interact
        send "exit\r"
      done
   

}
containers_ssh_check() {
#Function for checking port 22 is enabled or not
   echo "Checking the ssh chceck for containers"
   declare -a hosts=()
   containers_array=('frontend-1' 'frontend-2' 'backend-1' 'backend-2' 'controller')
   for items in "${containers_array[*]}";
   do 
      ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' "${containers_array[items]}")
      hosts[$items]=("${containers_array[items]}  $ip")
      call_ssh_check "$ip" "${containers_array[items]}"
   done
   add_ssh_keys "$containers_array" "$hosts"
}
checking_front_end_containers() {
    echo "Sending request to frontend-1 container
    value=$(curl -X GET https://frontend-1:8080/index.html)
    echo $value
    echo "Sending request to frontend-2 container
    value=$(curl -X GET https://frontend-2:8080/index.html)
    echo $value
}
checking_bank_end_containers() {
    echo "Creating an user and changing the root password of maria db backend"
    spawn ssh -o  StrictHostKeyChecking=no root@$1
    expect -exact "*"
    echo "Logging into Maria db"
    mysql -u root -p
    expect -exact "*"
    interact
    echo "Creating an user in maria db"
    `CREATE USER 'foo'@localhost IDENTIFIED BY 'far';`
    sleep 5
    expect -exact "OK"
    echo "Changing the root password"
    `SET PASSWORD FOR 'root'@'localhost' = PASSWORD('fred');`
    FLUSH PRIVILEGES;
    expect -exact "Query OK"
    send "exit\r"
    sleep 3
    send "exit\r"
    echo "Restarting mariabd service"
    sudo systemctl restart mariadb
}
checking_for_vim() {
#Function for checking the vim module in containers
    echo "Checking whether vim is installed or not and removing from frontend-1"
    ansible-playbook vim_check_ansible.yaml  -i /etc/ansible/inventory/hosts
}
collecting_inventory() {
#Function for collecting the w -i -f command ouput
    echo "Collecting w -i -f from all containers and copy the logs into controller node"
    ansible-playbook connected_users.yml  -i /etc/ansible/inventory/hosts
}

setting_environemt
containers_image_build
containers_building
containers_ssh_check
checking_front_end_containers
checking_bank_end_containers "backend-1"
checking_bank_end_containers "backend-2"
checking_for_vim
collecting_inventory
