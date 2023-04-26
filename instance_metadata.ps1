Import-Module AWSPowerShell
$url = "http://169.254.169.254/latest/meta-data/instance-id"
$InstanceId = (Invoke-WebRequest -UseBasicParsing -Uri $url).content
$InstanceId
# Register-EC2Address -Region ${cdk.Aws.REGION} -InstanceId $InstanceId -AllocationId ${props.eip.attrAllocationId}

$meta = Invoke-RestMethod -Uri "http://169.254.169.254/latest/dynamic/instance-identity/document" -Method GET | ConvertTo-Json
$meta
$json = Invoke-RestMethod -Uri "http://169.254.169.254/latest/dynamic/?recursive=true" | ConvertTo-Json
