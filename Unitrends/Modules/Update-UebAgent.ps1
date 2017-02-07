<#
.Synopsis
   Updates agents on all clients enabled for push
.DESCRIPTION
    Update-UebAgent
.EXAMPLE
    Update-UebAgent
#>
function Update-UebAgent {
	param()

    $clients = (get-uebapi -uri "api/clients/agent-push").data|where-object {$_.supports_agent_push}
    [array] $client_list = $null

    foreach($c in $clients)
    {
        $client_list += @{
            client_id = $c.id
            system_id = 1            
            credential_id = $c.credentials.credential_id
        }
    }

    #$client_list

    $data = @{
        clients = $client_list
    }

    $result = UebPut "api/clients/agent-push" $data
    foreach($p in $result.psobject.properties) {
        $p.value
    }

}
