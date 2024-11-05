#!/bin/sh

# List all managed disks in all subscriptions (whether the normal managed disks or VMSS attached)
subscriptions=$(az account list --query '[].id' -o tsv)

for sub in $subscriptions; do
    
    az account set --subscription $sub
    disk_list=$(az disk list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location}" -o tsv)
    if [[ ! -z $disk_list ]]; then
        while read disk; do
            echo $disk
            disk_name=$(echo $disk | cut -f 1-1 -d ' ')
            disk_rg=$(echo $disk | cut -f 2-2 -d ' ')
            echo "Managed disk: subscription $sub, name $disk_name, resource_group $disk_rg"
        done <<<$disk_list
    fi
    vmss_list=$(az vmss list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, capacity:sku.capacity OSDiskStorageAccountType: virtualMachineProfile.storageProfile.osDisk.managedDisk.storageAccountType, OSDiskSize: virtualMachineProfile.storageProfile.osDisk.diskSizeGB DataDisks: virtualMachineProfile.storageProfile.dataDisks[*].managedDisk}" -o tsv)
    if [[ ! -z $vmss_list ]]; then
        while read vmss; do
            vmss_name=$(echo $vmss | cut -f 1-1 -d ' ')
            vmss_rg=$(echo $vmss | cut -f 2-1-d ' ')
            vmss_location=$(echo $vmss | cut -f 3-3 -d ' ')
            capacity=$(echo $vmss | cut -f 4-4 -d ' ')
            vmss_os_disk_storage_profile=$(echo $vmss | cut -f 5-5 -d ' ')
            vmss_os_disk_size=$(echo $vmss | cut -f 6-6  -d ' ')
            vmss_data_disks=$(echo $vmss | cut -f 7-100  -d ' ')
            echo "VM Scale Set managed disk: subscription $sub, multiply_by_capacity $capacity name $vmss_name, resource_group $disk_rg location $location vmss_os_disk_storage_profile $vmss_os_disk_storage_profile vmss_os_disk_size $vmss_os_disk_size vmss_additional_data_disks_per_node: $vmss_data_disks"
        done <<<$vmss_list
    fi
done
