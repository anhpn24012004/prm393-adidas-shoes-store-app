param(
    [string]$ProjectPath = $PSScriptRoot
)

$project = Join-Path $ProjectPath "AdidasShoesStore.Api.csproj"
$email = Read-Host "Gmail address"
$securePassword = Read-Host "Google App Password (16 characters)" -AsSecureString
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR(
    $securePassword
)

try {
    $appPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
        $passwordPointer
    ).Replace(" ", "")

    if ([string]::IsNullOrWhiteSpace($email) -or $email -notmatch "@") {
        throw "Enter a valid Gmail address."
    }

    if ($appPassword.Length -ne 16) {
        throw "Google App Password must contain 16 characters."
    }

    dotnet user-secrets set "Email:SmtpHost" "smtp.gmail.com" --project $project
    dotnet user-secrets set "Email:SmtpPort" "587" --project $project
    dotnet user-secrets set "Email:Username" $email --project $project
    dotnet user-secrets set "Email:Password" $appPassword --project $project
    dotnet user-secrets set "Email:From" $email --project $project
    dotnet user-secrets set "Email:FromName" "Adidas Shoes Store" --project $project

    Write-Host ""
    Write-Host "SMTP configuration saved to .NET User Secrets."
    Write-Host "Restart the backend before testing forgot password."
}
finally {
    if ($passwordPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }

    $appPassword = $null
    $securePassword = $null
}
