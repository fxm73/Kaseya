param (
    [string]$AccessKey = $env:AWS_ACCESS_KEY,  # AWS access key from environment variables
    [string]$SecretKey = $env:AWS_SECRET_KEY,  # AWS secret key from environment variables
    [string]$BucketName,                       # S3 bucket name where files will be uploaded
    [string]$S3Endpoint,                       # Endpoint URL for the S3 service
    [string]$BaseUrl,                          # Base URL for IT Glue API
    [string]$ApiKey = $env:ITG_API_KEY,        # IT Glue API key from environment variables
    [string]$DownloadPath                      # Local directory path to download files
)

# Import the AWS PowerShell module to use AWS-specific cmdlets
Import-Module AWSPowerShell

# Set AWS credentials using environment variables and store them under the profile name 'WasabiCreds'
Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs WasabiCreds

# Prepare headers for the IT Glue API call, using the API key from environment variables
$headers = @{
    "x-api-key" = $ApiKey
}

# Define the endpoint URL for getting export data from IT Glue
$endpoint = "$BaseUrl/exports"

# Make the API request to get the file information
try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Get -Headers $headers
} catch {
    Write-Host "Error in API request: $_"  # Output any errors during the API request
    return
}

# Evaluate the number of files available for download
$fileCount = $response.data.Count
$currentFileNumber = 0

if ($fileCount -gt 0) {
    foreach ($item in $response.data) {
        if ($item.attributes.'download-url') {
            $currentFileNumber++
            $downloadUrl = $item.attributes.'download-url'
            $orgName = $item.attributes.'organization-name'

            # Use a default name if the organization name is missing
            if (-not $orgName) {
                $orgName = "AllOrganisations"
            } else {
                $orgName = $orgName -replace " ", ""  # Remove spaces from organization name
            }

            $updatedDate = [datetime]::Parse($item.attributes.'updated-at').ToString("yyyyMMdd-HHmm")
            $fileName = "$updatedDate-$orgName.zip"
            $localFullPath = "$DownloadPath/$fileName"  # Construct the full local path for the file

            # Download the file to the specified local path
            Invoke-WebRequest -Uri $downloadUrl -OutFile $localFullPath -ErrorAction Stop

            # Show download and upload progress
            Write-Host "Uploading file ${currentFileNumber} of ${fileCount}: ${fileName}"

            # Upload the downloaded file to S3, if the file exists locally
            if (Test-Path $localFullPath) {
                try {
                    Write-S3Object -BucketName $BucketName -Key $fileName -File $localFullPath -EndpointUrl $S3Endpoint -Credential (Get-AWSCredential -ProfileName WasabiCreds)
                    Write-Host "File uploaded successfully to ${BucketName}/${fileName}"
                } catch {
                    Write-Host "Failed to upload ${fileName} to ${BucketName}: $_"  # Provide error details if the upload fails
                }
            } else {
                Write-Host "Failed to download the file: ${fileName}"  # Error if the file failed to download
            }

            # Remove the local file after uploading to free up space
            Remove-Item -Path $localFullPath -Force -ErrorAction Continue
        }
    }
} else {
    Write-Host "No files available to upload."  # Inform the user if no files are available to download
}

