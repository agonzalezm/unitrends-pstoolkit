#--- user settings ------
#ueb from where to restore backups
$instance = 372
$ueb = "ueb02"
$user = "root"
$pass = "password"
#hyperv client to restore to replicas
$client_id=6
$replica_name_prefix="customer1"
$restore_path="C:/vmtest/replica/"
$switch_name="test-vswitch"
$replicas_n=1 		# number of replica VMs to keep, (default 1 will keep 1 VM copy only)
$max_vm_mem_gb=32    # max memory a vm can have, if vm has more than this it will be reconfigured to this value before importing.
#--- end of user settings ------