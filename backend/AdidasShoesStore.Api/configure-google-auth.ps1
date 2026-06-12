$project = Join-Path $PSScriptRoot "AdidasShoesStore.Api.csproj"
$clientId = Read-Host "460139502851-fkhhmn6sie91ms831lenmf3o31ju5u7k.apps.googleusercontent.com"

if ([string]::IsNullOrWhiteSpace($clientId) -or
    -not $clientId.EndsWith(".apps.googleusercontent.com")) {
    throw "Enter a valid Google OAuth Web Client ID."
}

dotnet user-secrets set "GoogleAuth:ClientId" $clientId --project $project

Write-Host ""
Write-Host "Backend Google authentication configured."
Write-Host "Restart the backend and reload Flutter."
