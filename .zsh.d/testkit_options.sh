export TESTKIT_AWS_REGION=us-east-2
export TESTKIT_AWS_KEYNAME=amancini
export TESTKIT_AWS_PURCHASE_TYPE=spot
export TESTKIT_AWS_REGION=us-east-2
export TESTKIT_AWS_SECURITY_GROUP=sg-0f7804ddec61629c0
export TESTKIT_AWS_SUBNET=subnet-0e0b4d63243a17f0c
# export TESTKIT_AWS_VPC_ID=vpc-0b41997b6efbc63fc
export TESTKIT_PROJECT_TAG=SUPPORT
# export TESTKIT_ENGINE=master
export TESTKIT_DRIVER=aws
export TESTKIT_SSH_KEYPATH=/home/$USER/.ssh/amancini.pem
export TESTKIT_AWS_PURCHASE_TYPE=spot

function update_testkit {
docker pull mirantiseng/testkit:latest \
 && id=$(docker create mirantiseng/testkit:latest) \
 && sudo docker cp $id:/testkit-$(uname -s)-$(uname -m) /usr/local/bin/testkit \
 && (docker rm $id >/dev/null)
}
