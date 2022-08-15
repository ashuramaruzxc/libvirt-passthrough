#!/bin/bash
DATE=$(date +"%m/%d/%Y %R:%S :")

echo "$DATE Beginning startup"

rc-service display-manager stop

# Unbind EFI-Framebuffer

if [[ -e /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 ]]
then
	echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
fi

# Avoid a race condition
sleep 3
rtcwake --verbose --utc --mode mem --seconds 7
modprobe vendor_reset
echo "$DATE vendor reset"
sleep 5

# Unload all AMD drivers
modprobe -r amdgpu
echo "$DATE amdgpu drivers unloaded"

# Load VFIO kernel module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

echo "$DATE vfio drivers loaded"

#bash /etc/libvirt/hooks/scripts/isolcpu.sh
echo "$DATE end of startup"
