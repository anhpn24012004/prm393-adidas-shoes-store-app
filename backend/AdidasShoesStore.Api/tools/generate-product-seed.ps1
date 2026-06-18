$ErrorActionPreference = "Stop"

function Escape-SqlLiteral {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value
    )

    return $Value -replace "'", "''"
}

$scriptDir = $PSScriptRoot
$apiRoot = Split-Path -Parent $scriptDir
$backendRoot = Split-Path -Parent $apiRoot
$projectRoot = Split-Path -Parent $backendRoot

$imageRoot = Join-Path $apiRoot "wwwroot\images\products\adidas"
$databaseDir = Join-Path $projectRoot "database"
$outputFile = Join-Path $databaseDir "seed-products.sql"

Write-Host "Script directory: $scriptDir"
Write-Host "Image root directory: $imageRoot"
Write-Host "Output database directory: $databaseDir"
Write-Host "Output file path: $outputFile"
Write-Host "Script directory exists: $(Test-Path -LiteralPath $scriptDir -PathType Container)"
Write-Host "Image root directory exists: $(Test-Path -LiteralPath $imageRoot -PathType Container)"
Write-Host "Output database directory exists: $(Test-Path -LiteralPath $databaseDir -PathType Container)"
Write-Host ""

if (!(Test-Path -LiteralPath $imageRoot -PathType Container)) {
    throw "Adidas image root folder does not exist: $imageRoot"
}

if (!(Test-Path -LiteralPath $databaseDir -PathType Container)) {
    Write-Host "Output database directory is missing. Creating: $databaseDir"
    New-Item -Path $databaseDir -ItemType Directory -Force | Out-Null
}

if (!(Test-Path -LiteralPath $databaseDir -PathType Container)) {
    throw "Output database folder does not exist and could not be created: $databaseDir"
}

$products = @(
    @{ Folder = "Adizero-Boston-12"; Name = "Adizero Boston 12"; CategoryId = 1; Price = 3200000 },
    @{ Folder = "Adizero-Adios-Pro-3"; Name = "Adizero Adios Pro 3"; CategoryId = 1; Price = 5500000 },
    @{ Folder = "Ultraboost-Light"; Name = "Ultraboost Light"; CategoryId = 1; Price = 4500000 },
    @{ Folder = "Ultraboost-5"; Name = "Ultraboost 5"; CategoryId = 1; Price = 4700000 },
    @{ Folder = "Supernova-Rise"; Name = "Supernova Rise"; CategoryId = 1; Price = 2800000 },
    @{ Folder = "Supernova-Stride"; Name = "Supernova Stride"; CategoryId = 1; Price = 2500000 },
    @{ Folder = "Solar-Glide-6"; Name = "Solar Glide 6"; CategoryId = 1; Price = 3300000 },
    @{ Folder = "Response-Runner"; Name = "Response Runner"; CategoryId = 1; Price = 1600000 },
    @{ Folder = "Duramo-SL-2"; Name = "Duramo SL 2"; CategoryId = 1; Price = 1500000 },
    @{ Folder = "Runfalcon-5"; Name = "Runfalcon 5"; CategoryId = 1; Price = 1400000 },

    @{ Folder = "Predator-Elite-FG"; Name = "Predator Elite FG"; CategoryId = 3; Price = 6200000 },
    @{ Folder = "Predator-Accuracy.1"; Name = "Predator Accuracy.1"; CategoryId = 3; Price = 5200000 },
    @{ Folder = "Copa-Pure-2-Elite"; Name = "Copa Pure 2 Elite"; CategoryId = 3; Price = 5600000 },
    @{ Folder = "Copa-Sense.1"; Name = "Copa Sense.1"; CategoryId = 3; Price = 4900000 },
    @{ Folder = "X-Crazyfast-Elite"; Name = "X Crazyfast Elite"; CategoryId = 3; Price = 5900000 },
    @{ Folder = "X-Speedportal.1"; Name = "X Speedportal.1"; CategoryId = 3; Price = 5300000 },
    @{ Folder = "Goletto-VIII"; Name = "Goletto VIII"; CategoryId = 3; Price = 1200000 },
    @{ Folder = "Copa-Gloro"; Name = "Copa Gloro"; CategoryId = 3; Price = 2200000 }
)

$imageExtensions = @(".jpg", ".jpeg", ".png", ".webp", ".gif")
$sizes = 36, 37, 38, 39, 40, 41, 42, 43, 44, 45
$sql = "-- Seed products generated from image folders`r`n`r`n"

foreach ($p in $products) {
    $folderPath = Join-Path $imageRoot $p.Folder

    if (!(Test-Path -LiteralPath $folderPath -PathType Container)) {
        throw "Missing product image folder for '$($p.Name)': $folderPath"
    }

    $imageFiles = Get-ChildItem -LiteralPath $folderPath -File |
        Where-Object { $imageExtensions -contains $_.Extension.ToLowerInvariant() } |
        Sort-Object Name

    if ($imageFiles.Count -eq 0) {
        throw "No image files found for '$($p.Name)' in folder: $folderPath"
    }

    $safeVar = $p.Folder -replace '[^a-zA-Z0-9]', '_'
    $productName = Escape-SqlLiteral $p.Name
    $description = Escape-SqlLiteral "Adidas $($p.Name) shoes"

    $sql += @"
DECLARE @ProductId_$safeVar INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'$productName')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'$productName',
        N'$description',
        $($p.Price),
        $($p.CategoryId),
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_$safeVar = ProductId
FROM Products
WHERE ProductName = N'$productName';

"@

    $isFirstImage = $true

    foreach ($file in $imageFiles) {
        $color = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $imageUrl = "/images/products/adidas/$($p.Folder)/$($file.Name)"
        $isMain = if ($isFirstImage) { 1 } else { 0 }
        $isFirstImage = $false

        $sqlColor = Escape-SqlLiteral $color
        $sqlImageUrl = Escape-SqlLiteral $imageUrl

        $sql += @"
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_$safeVar
    AND ImageUrl = N'$sqlImageUrl'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_$safeVar, N'$sqlImageUrl', $isMain);
END

"@

        foreach ($size in $sizes) {
            $sku = "$($p.Folder)-$color-$size"
            $sqlSku = Escape-SqlLiteral $sku

            $sql += @"
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'$sqlSku'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_$safeVar,
        N'$size',
        N'$sqlColor',
        $($p.Price),
        20,
        N'$sqlSku',
        1
    );
END

"@
        }
    }
}

$sql | Out-File -FilePath $outputFile -Encoding utf8 -Force

Write-Host "Generated: $outputFile"
