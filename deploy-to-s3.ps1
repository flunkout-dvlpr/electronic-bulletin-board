param(
    [string]$BucketName,
    [string]$Region = "us-east-1"
)

# Step 1: Build Quasar project
Write-Host "Building Quasar project..."
quasar build

$DistPath = "dist\spa"

if (-Not (Test-Path $DistPath)) {
    Write-Error "Build failed. Folder $DistPath not found."
    exit 1
}

# Step 2: Check if bucket exists
Write-Host "Checking if bucket '$BucketName' exists..."
aws s3api head-bucket --bucket $BucketName 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Bucket does not exist. Creating..."
    if ($Region -eq "us-east-1") {
        aws s3api create-bucket --bucket $BucketName --region $Region
    } else {
        aws s3api create-bucket --bucket $BucketName --region $Region `
            --create-bucket-configuration LocationConstraint=$Region
    }
}

# Step 3: Apply bucket policy from file
$PolicyFilePath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "bucket-policy.json"
Write-Host "Applying bucket policy from $PolicyFilePath..."
aws s3api put-bucket-policy --bucket $BucketName --policy "file://$PolicyFilePath"

# Step 4: Enable static website hosting
Write-Host "Enabling static website hosting..."
aws s3 website s3://$BucketName/ --index-document index.html --error-document index.html

# Step 5: Upload files
Write-Host "Uploading files to bucket..."
aws s3 sync $DistPath s3://$BucketName

# Step 6: Return URL
$WebsiteUrl = "http://$BucketName.s3-website-$Region.amazonaws.com"
Write-Host "Deployment complete!"
Write-Host ("Your site is live at: {0}" -f $WebsiteUrl)
