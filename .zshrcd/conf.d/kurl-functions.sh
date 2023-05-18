### kURL development helpers:
KURL_VM_DEFAULT_NAME="${USER}-kurl"
KURL_VM_IMAGE_FAMILY="ubuntu-2004-lts"
KURL_VM_IMAGE_PROJECT="ubuntu-os-cloud"
KURL_VM_INSTANCE_TYPE="n1-standard-8"
#DATE=$(date '+%Y-%m-%d' -d "+30 days")
DATE=never
export GOOS=linux # for watchrsync on MacOS

# Creates an instance with a disk device attached.
# For additional instances pass a prefix, example: kurl-dev-make user-kurl2
function kurl-dev-make() {
    local VMNAME="${1:-$KURL_VM_DEFAULT_NAME}"
    local VMDISK="$VMNAME-disk1"

    echo "Creating instance $VMNAME..."
    gcloud compute instances create $VMNAME \
      --image-project=$KURL_VM_IMAGE_PROJECT \
      --image-family=$KURL_VM_IMAGE_FAMILY \
      --machine-type=$KURL_VM_INSTANCE_TYPE \
      --boot-disk-size=200G \
      --labels expires-on=$DATE,owner=$USER

    local ZONE=$(gcloud compute instances describe $VMNAME --format='value(zone)' | awk -F/ '{print $NF}')
    gcloud compute disks create $VMDISK --size=200GB --zone=$ZONE --labels expires-on=$DATE,owner=$USER
    gcloud compute instances attach-disk $VMNAME --disk=$VMDISK

    local VM_IP=$(gcloud compute instances describe $VMNAME --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

    cat <<MAKE_INFO

external IP: $VM_IP
to ssh run: gcloud beta compute ssh $VMNAME
MAKE_INFO
}

function kurl-dev-list() {
    local VMNAME="${1:-$KURL_VM_DEFAULT_NAME}"
    echo "Found instances:"
    gcloud compute instances list --filter="name:($VMNAME)"
    echo "Found disks:"
    # TODO: find disks that are attached to an instance
    gcloud compute disks list --filter="name ~ .*$VMNAME.*"
}

function kurl-dev-clean() {
    local VMNAME="${1:-$KURL_VM_DEFAULT_NAME}"
    gcloud compute instances delete --delete-disks=all $VMNAME
}
