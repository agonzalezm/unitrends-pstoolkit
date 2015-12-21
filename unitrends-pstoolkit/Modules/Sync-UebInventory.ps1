function Sync-UebInventory {
	param (	)

		$id = $job.id
		$sid = $job.sid

		$response = UebPut "api/inventory" 
		$response
}

