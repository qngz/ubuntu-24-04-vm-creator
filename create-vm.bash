#!/bin/bash

BACKING_FILE="ubuntu24.04-base.img"
VM_ROM="5G"
VM_RAM=2048 #Mb
VCPUS=2

VM_NAME=$1
#BASE_DIR="$(dirname $0)"
CONFIG_DIR="/tmp/${VM_NAME}-cloud-init"
LIBVIRT_IMAGES="/var/lib/libvirt/images"

if [ -z $VM_NAME ]; then
    echo "Error: name not found"
    exit 1
fi

if virsh dominfo ${VM_NAME} &> /dev/null; then
    echo "Error: VM ${VM_NAME} exist"
    exit 1
fi

mkdir -p "${CONFIG_DIR}"

cat > "${CONFIG_DIR}/user-data" << EOF
#cloud-config
hostname: ${VM_NAME}
users:
  - name: ops
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat ~/.ssh/vm.pub)
EOF

sudo mkdir -p "${LIBVIRT_IMAGES}/${VM_NAME}"

cat > "${CONFIG_DIR}/meta-data" << EOF
instance-id: ${VM_NAME}
local-hostname: ${VM_NAME}
EOF

sudo cloud-localds "${LIBVIRT_IMAGES}/${VM_NAME}/seed.img" \
  "${CONFIG_DIR}/user-data" \
  "${CONFIG_DIR}/meta-data"
sudo qemu-img create -f qcow2 -F qcow2 \
  -b "${LIBVIRT_IMAGES}/${BACKING_FILE}" \
  "${LIBVIRT_IMAGES}/${VM_NAME}/overlay.img"
qemu-img resize "${LIBVIRT_IMAGES}/${VM_NAME}/overlay.img" "${VM_ROM}"

sudo virt-install \
  --name ${VM_NAME} \
  --memory ${VM_RAM} \
  --vcpus ${VCPUS} \
  --disk "${LIBVIRT_IMAGES}/${VM_NAME}/overlay.img,format=qcow2,bus=virtio" \
  --disk "${LIBVIRT_IMAGES}/${VM_NAME}/seed.img,device=cdrom" \
  --network network=default \
  --import \
  --os-variant ubuntu24.04 \
  --graphics none \
  --noautoconsole
