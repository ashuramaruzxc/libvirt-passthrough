#!/bin/bash
set -x

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind EFI-Framebuffer
if [[ -e /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 ]]
then
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind
fi

#Loads amd drivers
modprobe vendor_reset
modprobe amdgpu

sleep 3

#bash /etc/libvirt/hooks/scripts/revertcpu.sh
rc-service display-manager start
