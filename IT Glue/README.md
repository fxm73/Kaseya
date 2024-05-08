# Wasabi / AWS S3 File Uploader Script

## Purpose
This PowerShell script automates the process of downloading Export files from the IT Glue API and uploading them to an Wasabi / AWS S3 bucket. It is designed to handle secure credential management and provide clear logging for each step of the process.

## Prerequisites
Before using this script, ensure you have the following configured on your system:
- **PowerShell**: Version 5.1 or higher.
- **AWSPowerShell Module**: This module is required to interact with AWS services. Install it using PowerShellGet with the command `Install-Module -Name AWSPowerShell`.
- **Environment Variables**: Set the following environment variables on your system:
  - `AWS_ACCESS_KEY`: Your AWS access key.
  - `AWS_SECRET_KEY`: Your AWS secret key.
  - `ITG_API_KEY`: Your IT Glue API key.

## Configuration
You must provide several parameters either through the command line or by modifying the script directly:

- `BucketName`: Name of the AWS S3 bucket where files will be uploaded.
- `S3Endpoint`: The endpoint URL for the S3 service.
- `BaseUrl`: The base URL for the IT Glue API.
- `DownloadPath`: The path on your local system where files should be downloaded before uploading.

## Usage
To run the script, open PowerShell and execute the script with the required parameters. For example:

```powershell
./UploadFilesToS3.ps1 -BucketName 'your-bucket-name' -S3Endpoint 'https://s3.your-region.amazonaws.com' -BaseUrl 'https://api.your-itglue-region.com' -DownloadPath 'C:\path\to\your\download\folder'
