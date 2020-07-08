#!/usr/bin/bash
#

DOCKER_VOLUME="/var/lib/docker/volumes"

# This function check & install required dependencies
#
function installDependencies () {
  requiredPackages=(jq docker)

  for package in ${requiredPackages[@]}
  do
    rpm -qa | grep -i $package > /dev/null 2>&1
    if [[ $? -eq 1 ]]; then
        yum -y install $package
      if [[ $package == squid ]]; then
          yum install -y git lsof wget unzip mlocate htop net-tools traceroute iptables-services
          yum install -y yum-utils device-mapper-persistent-data lvm2

          yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
          yum install -y docker-ce docker-ce-cli containerd.io

      fi
    else
      printf "$package already installed\n"
    fi
  done
}

# Install docker & dependencies
installDependencies

# Initialize docker & project dir
sleep 5
systemctl restart docker
systemctl enable docker
mkdir -p $DOCKER_VOLUME/project/_data
cp -r main.sh src $DOCKER_VOLUME/project/_data/

# Python Container
docker run -dit --rm \
--name python \
-v project:/usr/src/code \
-w /usr/src/code python:3 \
bash -c 'hostname >> python.output | hostname -i >> python.output | python src/python.py'

# output
sleep 5
printf "\n> Python Container Info:\n"
cat $DOCKER_VOLUME/project/_data/python.output

