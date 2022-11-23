$ProcessName = "wstunnel"
if ($Null -eq (get-process $ProcessName -ErrorAction SilentlyContinue))
{
    Write-Output "false"
}
else
{
    Write-Output "true"
}
