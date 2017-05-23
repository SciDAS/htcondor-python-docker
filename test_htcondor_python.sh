#!/bin/bash

# start in the docker directory
cd "$( dirname "$0" )"
HTCONDOR_CONFIG_DIR="$( pwd )"

DOCKER_NAME_MASTER="condor-master"
DOCKER_NAME_SUBMITTER="condor-submitter"
DOCKER_NAME_EXECUTOR="condor-executor"
DOCKER_NAME_PYTHON="htcondor-python"

DOCKER_NET_NAME="htcondor"
DOCKER_HTCONDOR_IMAGE="htcondor-python"
DOCKER_HTCONDOR_IMAGE_TAG="latest"

DOCKER_RUN_COMMAND="python /examples/htcondor_test.py"
DOCKER_RUN_INTERACTIVE="-d" # default to detached

# password file for HTCondor security
# the password file must be owned by root, with permission 600 (rw-------)
HOST_PASSWORD_FILE=${HTCONDOR_CONFIG_DIR}/pool_password
CONTAINER_PASSWORD_FILE=/var/lib/condor/pool_password
if [ ! -e ${HOST_PASSWORD_FILE} ]
then 
  echo "ERROR: password file ${HOST_PASSWORD_FILE} must be present"
  exit 1
fi
if [ $(stat -c %a ${HOST_PASSWORD_FILE} ) != "600" ]
then
  echo "ERROR: password file ${HOST_PASSWORD_FILE} must have permissions 600 (rw-------)"
  exit 1
fi
if [ $(stat -c %U ${HOST_PASSWORD_FILE} ) != "root" ]
then
  echo "ERROR: password file ${HOST_PASSWORD_FILE} must owned by root"
  exit 1
fi

# Check command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -t|--tag-name)
    DOCKER_HTCONDOR_IMAGE_TAG="$2"
    shift # past argument
    ;;
    *)
            # pass all options to docker run
            DOCKER_RUN_COMMAND=$@
            DOCKER_RUN_INTERACTIVE="-it" # interactive
            DOCKER_NAME_PYTHON="${DOCKER_NAME_PYTHON}-it"
    ;;
esac
shift # past argument or value
done

# remove stopped or running containers
f_rm_f_docker_container ()
{
  #container_name="$1"
  RUNNING=$(docker inspect --format="{{ .State.Running }}" $1 2> /dev/null)

  # if it's not there at all, we don't need to remove it
  if [ $? -ne 1 ]; then
    echo -n "Removing container: "
    docker rm -f $1

    # check exit status, and kill script if not successful
    if [ $? -ne 0 ]
    then
      exit $?
    fi
  fi
}

# Remove any previous docker containers of name
echo "Info: removing any previous HTCondor containers..."
f_rm_f_docker_container ${DOCKER_NAME_PYTHON}

# HTCondor must already be running, including the docker network
NET_INSPECT=$(docker network inspect ${DOCKER_NET_NAME} 2> /dev/null)
if [ $? -eq 1 ]; then
  echo -n "You must be running HTCondor in docker, including the docker network ${DOCKER_NET_NAME}: "
  exit 1
fi

# Docker-on-Mac is a bit slower
var_sleep=5
if [[ $OSTYPE == darwin* ]]
then
  let "var_sleep *= 15"
fi

# Start test of htcondor-python
echo -n "docker run ${DOCKER_NAME_PYTHON}:${DOCKER_HTCONDOR_IMAGE_TAG} "
           #python /examples/htcondor_test.py
docker run ${DOCKER_RUN_INTERACTIVE} \
           --net ${DOCKER_NET_NAME} \
           --name ${DOCKER_NAME_PYTHON} \
           --hostname ${DOCKER_NAME_PYTHON} \
           --volume ${HTCONDOR_CONFIG_DIR}/config.d/:/etc/condor/config.d \
           --volume ${HTCONDOR_CONFIG_DIR}/examples/:/examples \
           --volume ${HOST_PASSWORD_FILE}:${CONTAINER_PASSWORD_FILE} \
           ${DOCKER_HTCONDOR_IMAGE}:${DOCKER_HTCONDOR_IMAGE_TAG} \
           ${DOCKER_RUN_COMMAND}

# check exit status from docker run, and kill script if not successful
if [ $? -ne 0 ]
then
  exit $?
fi

