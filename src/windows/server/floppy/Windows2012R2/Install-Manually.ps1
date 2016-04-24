$SemaphoreFile = "C:\delete-me-to-continue.txt"

Write-Host "Creating semaphore file: $SemaphoreFile"
Set-Content $SemaphoreFile "Delete this file to let Packer shutdown and pack the box."

while (Test-Path $SemaphoreFile) { Start-Sleep 10 }
