<#
This script deploys two Windows VMs which both leverage a shared disk. 

Created: 11/3/20
Author: Matt Hansen 
https://github.com/matthansen0/azure-2vm-shared-disk 
#>

##Set Variables 
$resourceGroup = "rg-SharedStorageDemo"
$location = "WestCentralUS"
$diskName = "SharedDisk01"
$VirtualNetworkName = "SharedStoragevNet"

##Create Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location

##Set shared disk configuration
$dataDiskConfig = New-AzDiskConfig -Location $location -DiskSizeGB 1024 -AccountType Premium_LRS -CreateOption Empty -MaxSharesCount 2

##Add new managed, shared disk
New-AzDisk -ResourceGroupName $resourceGroup -DiskName $diskName -Disk $dataDiskConfig

##Create first VM
$vm = New-AzVm -ResourceGroupName $resourceGroup -Name "VM01" -Location $location -VirtualNetworkName $VirtualNetworkName -SubnetName "Subnet1" -SecurityGroupName "VM1-nsg" -PublicIpAddressName "VM1-pip"

##Add Shared Disk to VM01
$dataDisk = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $diskName
$vm = Add-AzVMDataDisk -VM $vm -Name $diskName -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun 0
update-AzVm -VM $vm -ResourceGroupName $resourceGroup


##Create second VM
$vm = New-AzVm -ResourceGroupName $resourceGroup -Name "VM02" -Location $location -VirtualNetworkName $VirtualNetworkName -SubnetName "Subnet1" -SecurityGroupName "VM2-nsg" -PublicIpAddressName "VM2-pip"

##Add Shared Disk to VM02
$dataDisk = Get-AzDisk -ResourceGroupName $resourceGroup -DiskName $diskName
$vm = Add-AzVMDataDisk -VM $vm -Name $diskName -CreateOption Attach -ManagedDiskId $dataDisk.Id -Lun 0
update-AzVm -VM $vm -ResourceGroupName $resourceGroup