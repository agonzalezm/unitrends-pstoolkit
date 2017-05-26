Param()

$jobs = Get-UebJob -Recent

foreach($j in $jobs) {
    if($j.start_date -ne $null) {
        $start_s = $j.start_date
    } else {
        $start_s = $j.start_time
    }
    $j|add-member -membertype NoteProperty -Name "start_d" -Value $start_s

    if($j.duration -ne $null -and $j.duration -ne "n/a") {       
        $start = [DateTime]::Parse($start_s)
        $hour = $j.duration.Split(':')[0] 
        $min = $j.duration.Split(':')[1]
        $sec = $j.duration.Split(':')[2]
        $duration = New-TimeSpan -Hours $hour -Minutes $min -Seconds $sec
        $end = $start + $duration
        $j|add-member -membertype NoteProperty -Name "end_d" -Value $end
        
    }
}

$jobs|Select-Object -Property name,status,start_d,end_d



