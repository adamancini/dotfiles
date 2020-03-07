export TESTKIT_AWS_DEFAULT_REGION=us-east-2
export TESTKIT_AWS_KEYNAME=amancini-jane
export TESTKIT_AWS_PURCHASE_TYPE=spot
export TESTKIT_AWS_REGION=us-east-2
export TESTKIT_AWS_SECURITY_GROUP=sg-0c7c91058c0f77bdb
export TESTKIT_AWS_SUBNET=subnet-0021c861e0c8b3b9b
export TESTKIT_AWS_VPC_ID=vpc-0b41997b6efbc63fc
export TESTKIT_PROJECT_TAG=SUPPORT
export TESTKIT_ENGINE=master
export TESTKIT_DRIVER=aws
export TESTKIT_SSH_KEYPATH=/home/$USER/.ssh/amancini-jane.pem

function update_testkit {
docker pull mirantiseng/testkit:latest \
 && id=$(docker create mirantiseng/testkit:latest) \
 && sudo docker cp $id:/testkit-$(uname -s)-$(uname -m) /usr/local/bin/testkit \
 && (docker rm $id >/dev/null)
}
