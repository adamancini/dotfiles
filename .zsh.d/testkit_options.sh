export TESTKIT_AWS_REGION=us-east-2
export TESTKIT_AWS_KEYNAME=amancini
export TESTKIT_AWS_PURCHASE_TYPE=ondemand
export TESTKIT_PROJECT_TAG=SUPPORT
export TESTKIT_DRIVER=aws
export TESTKIT_SSH_KEYPATH=/home/$USER/.ssh/amancini.pem

function update_testkit {
docker pull mirantiseng/testkit:latest \
 && id=$(docker create mirantiseng/testkit:latest) \
 && sudo docker cp $id:/testkit-$(uname -s)-$(uname -m) /usr/local/bin/testkit \
 && (docker rm $id >/dev/null)
}
