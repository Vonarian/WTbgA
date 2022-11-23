$p = Get-Process aces
$memoryList = ((Get-Counter "\GPU Process Memory(pid_$( $p.id )*)\Local Usage").CounterSamples | Where-Object CookedValue).CookedValue[-1]
$engine3DList = ((Get-Counter "\GPU Engine(pid_$( $p.id )*engtype_3D)\Utilization Percentage").CounterSamples | Where-Object CookedValue).CookedValue[-1]
$engineCopyList = ((Get-Counter "\GPU Engine(pid_$( $p.id )*engtype_Copy)\Utilization Percentage").CounterSamples | Where-Object CookedValue).CookedValue[-1]
if (($Null -ne $engine3DList) -and ($Null -ne $engineCopyList) -and ($Null -ne $memoryList))
{
    $qwMemorySize = (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -Name HardwareInformation.qwMemorySize -ErrorAction SilentlyContinue)."HardwareInformation.qwMemorySize"
    if ($Null -ne $qwMemorySize)
    {
        $VRAM = [math]::round($qwMemorySize/1MB)
        $memory = "$([math]::Round($memoryList/1MB, 2) )"
        $engine3D = $([math]::Round($engine3DList, 2) )
        $engineCopy = $([math]::Round($engineCopyList, 2) )
        $myObject = [PSCustomObject]@{
            memory = [math]::round($memory/$VRAM * 100)
            engine3D = $engine3D
            engineCopy = $engineCopy
        }

        Write-Output $myObject | ConvertTo-Json
    }
}

