-- Seed products generated from image folders

DECLARE @ProductId_Adizero_Boston_12 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Adizero Boston 12')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Adizero Boston 12',
        N'Adidas Adizero Boston 12 shoes',
        3200000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Adizero_Boston_12 = ProductId
FROM Products
WHERE ProductName = N'Adizero Boston 12';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Boston_12
    AND ImageUrl = N'/images/products/adidas/Adizero-Boston-12/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Boston_12, N'/images/products/adidas/Adizero-Boston-12/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'36',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'37',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'38',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'39',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'40',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'41',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'42',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'43',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'44',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'45',
        N'black',
        3200000,
        20,
        N'Adizero-Boston-12-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Boston_12
    AND ImageUrl = N'/images/products/adidas/Adizero-Boston-12/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Boston_12, N'/images/products/adidas/Adizero-Boston-12/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'36',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'37',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'38',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'39',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'40',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'41',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'42',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'43',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'44',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'45',
        N'blue',
        3200000,
        20,
        N'Adizero-Boston-12-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Boston_12
    AND ImageUrl = N'/images/products/adidas/Adizero-Boston-12/pink.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Boston_12, N'/images/products/adidas/Adizero-Boston-12/pink.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'36',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'37',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'38',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'39',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'40',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'41',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'42',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'43',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'44',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-pink-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'45',
        N'pink',
        3200000,
        20,
        N'Adizero-Boston-12-pink-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Boston_12
    AND ImageUrl = N'/images/products/adidas/Adizero-Boston-12/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Boston_12, N'/images/products/adidas/Adizero-Boston-12/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'36',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'37',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'38',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'39',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'40',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'41',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'42',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'43',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'44',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Boston-12-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Boston_12,
        N'45',
        N'white',
        3200000,
        20,
        N'Adizero-Boston-12-white-45',
        1
    );
END
DECLARE @ProductId_Adizero_Adios_Pro_3 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Adizero Adios Pro 3')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Adizero Adios Pro 3',
        N'Adidas Adizero Adios Pro 3 shoes',
        5500000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Adizero_Adios_Pro_3 = ProductId
FROM Products
WHERE ProductName = N'Adizero Adios Pro 3';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Adios_Pro_3
    AND ImageUrl = N'/images/products/adidas/Adizero-Adios-Pro-3/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Adios_Pro_3, N'/images/products/adidas/Adizero-Adios-Pro-3/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'36',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'37',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'38',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'39',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'40',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'41',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'42',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'43',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'44',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'45',
        N'black',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Adios_Pro_3
    AND ImageUrl = N'/images/products/adidas/Adizero-Adios-Pro-3/green.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Adios_Pro_3, N'/images/products/adidas/Adizero-Adios-Pro-3/green.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'36',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'37',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'38',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'39',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'40',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'41',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'42',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'43',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'44',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-green-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'45',
        N'green',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-green-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Adios_Pro_3
    AND ImageUrl = N'/images/products/adidas/Adizero-Adios-Pro-3/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Adios_Pro_3, N'/images/products/adidas/Adizero-Adios-Pro-3/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'36',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'37',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'38',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'39',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'40',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'41',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'42',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'43',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'44',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'45',
        N'red',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Adizero_Adios_Pro_3
    AND ImageUrl = N'/images/products/adidas/Adizero-Adios-Pro-3/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Adizero_Adios_Pro_3, N'/images/products/adidas/Adizero-Adios-Pro-3/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'36',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'37',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'38',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'39',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'40',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'41',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'42',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'43',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'44',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Adizero-Adios-Pro-3-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Adizero_Adios_Pro_3,
        N'45',
        N'white',
        5500000,
        20,
        N'Adizero-Adios-Pro-3-white-45',
        1
    );
END
DECLARE @ProductId_Ultraboost_Light INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Ultraboost Light')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Ultraboost Light',
        N'Adidas Ultraboost Light shoes',
        4500000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Ultraboost_Light = ProductId
FROM Products
WHERE ProductName = N'Ultraboost Light';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Ultraboost_Light
    AND ImageUrl = N'/images/products/adidas/Ultraboost-Light/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Ultraboost_Light, N'/images/products/adidas/Ultraboost-Light/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'36',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'37',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'38',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'39',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'40',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'41',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'42',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'43',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'44',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'45',
        N'black',
        4500000,
        20,
        N'Ultraboost-Light-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Ultraboost_Light
    AND ImageUrl = N'/images/products/adidas/Ultraboost-Light/green.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Ultraboost_Light, N'/images/products/adidas/Ultraboost-Light/green.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'36',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'37',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'38',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'39',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'40',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'41',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'42',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'43',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'44',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-green-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'45',
        N'green',
        4500000,
        20,
        N'Ultraboost-Light-green-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Ultraboost_Light
    AND ImageUrl = N'/images/products/adidas/Ultraboost-Light/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Ultraboost_Light, N'/images/products/adidas/Ultraboost-Light/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'36',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'37',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'38',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'39',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'40',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'41',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'42',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'43',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'44',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-Light-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_Light,
        N'45',
        N'white',
        4500000,
        20,
        N'Ultraboost-Light-white-45',
        1
    );
END
DECLARE @ProductId_Ultraboost_5 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Ultraboost 5')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Ultraboost 5',
        N'Adidas Ultraboost 5 shoes',
        4700000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Ultraboost_5 = ProductId
FROM Products
WHERE ProductName = N'Ultraboost 5';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Ultraboost_5
    AND ImageUrl = N'/images/products/adidas/Ultraboost-5/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Ultraboost_5, N'/images/products/adidas/Ultraboost-5/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'36',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'37',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'38',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'39',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'40',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'41',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'42',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'43',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'44',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'45',
        N'black',
        4700000,
        20,
        N'Ultraboost-5-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Ultraboost_5
    AND ImageUrl = N'/images/products/adidas/Ultraboost-5/gray.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Ultraboost_5, N'/images/products/adidas/Ultraboost-5/gray.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'36',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'37',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'38',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'39',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'40',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'41',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'42',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'43',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'44',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-gray-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'45',
        N'gray',
        4700000,
        20,
        N'Ultraboost-5-gray-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Ultraboost_5
    AND ImageUrl = N'/images/products/adidas/Ultraboost-5/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Ultraboost_5, N'/images/products/adidas/Ultraboost-5/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'36',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'37',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'38',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'39',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'40',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'41',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'42',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'43',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'44',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Ultraboost-5-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Ultraboost_5,
        N'45',
        N'white',
        4700000,
        20,
        N'Ultraboost-5-white-45',
        1
    );
END
DECLARE @ProductId_Supernova_Rise INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Supernova Rise')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Supernova Rise',
        N'Adidas Supernova Rise shoes',
        2800000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Supernova_Rise = ProductId
FROM Products
WHERE ProductName = N'Supernova Rise';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Supernova_Rise
    AND ImageUrl = N'/images/products/adidas/Supernova-Rise/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Supernova_Rise, N'/images/products/adidas/Supernova-Rise/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'36',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'37',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'38',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'39',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'40',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'41',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'42',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'43',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'44',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'45',
        N'black',
        2800000,
        20,
        N'Supernova-Rise-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Supernova_Rise
    AND ImageUrl = N'/images/products/adidas/Supernova-Rise/gray.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Supernova_Rise, N'/images/products/adidas/Supernova-Rise/gray.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'36',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'37',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'38',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'39',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'40',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'41',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'42',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'43',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'44',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-gray-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'45',
        N'gray',
        2800000,
        20,
        N'Supernova-Rise-gray-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Supernova_Rise
    AND ImageUrl = N'/images/products/adidas/Supernova-Rise/while.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Supernova_Rise, N'/images/products/adidas/Supernova-Rise/while.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'36',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'37',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'38',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'39',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'40',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'41',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'42',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'43',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'44',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Rise-while-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Rise,
        N'45',
        N'while',
        2800000,
        20,
        N'Supernova-Rise-while-45',
        1
    );
END
DECLARE @ProductId_Supernova_Stride INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Supernova Stride')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Supernova Stride',
        N'Adidas Supernova Stride shoes',
        2500000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Supernova_Stride = ProductId
FROM Products
WHERE ProductName = N'Supernova Stride';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Supernova_Stride
    AND ImageUrl = N'/images/products/adidas/Supernova-Stride/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Supernova_Stride, N'/images/products/adidas/Supernova-Stride/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'36',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'37',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'38',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'39',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'40',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'41',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'42',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'43',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'44',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'45',
        N'black',
        2500000,
        20,
        N'Supernova-Stride-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Supernova_Stride
    AND ImageUrl = N'/images/products/adidas/Supernova-Stride/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Supernova_Stride, N'/images/products/adidas/Supernova-Stride/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'36',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'37',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'38',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'39',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'40',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'41',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'42',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'43',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'44',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'45',
        N'blue',
        2500000,
        20,
        N'Supernova-Stride-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Supernova_Stride
    AND ImageUrl = N'/images/products/adidas/Supernova-Stride/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Supernova_Stride, N'/images/products/adidas/Supernova-Stride/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'36',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'37',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'38',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'39',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'40',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'41',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'42',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'43',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'44',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Supernova-Stride-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Supernova_Stride,
        N'45',
        N'white',
        2500000,
        20,
        N'Supernova-Stride-white-45',
        1
    );
END
DECLARE @ProductId_Solar_Glide_6 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Solar Glide 6')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Solar Glide 6',
        N'Adidas Solar Glide 6 shoes',
        3300000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Solar_Glide_6 = ProductId
FROM Products
WHERE ProductName = N'Solar Glide 6';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Solar_Glide_6
    AND ImageUrl = N'/images/products/adidas/Solar-Glide-6/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Solar_Glide_6, N'/images/products/adidas/Solar-Glide-6/blue.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'36',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'37',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'38',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'39',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'40',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'41',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'42',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'43',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'44',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'45',
        N'blue',
        3300000,
        20,
        N'Solar-Glide-6-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Solar_Glide_6
    AND ImageUrl = N'/images/products/adidas/Solar-Glide-6/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Solar_Glide_6, N'/images/products/adidas/Solar-Glide-6/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'36',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'37',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'38',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'39',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'40',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'41',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'42',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'43',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'44',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'45',
        N'red',
        3300000,
        20,
        N'Solar-Glide-6-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Solar_Glide_6
    AND ImageUrl = N'/images/products/adidas/Solar-Glide-6/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Solar_Glide_6, N'/images/products/adidas/Solar-Glide-6/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'36',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'37',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'38',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'39',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'40',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'41',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'42',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'43',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'44',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Solar-Glide-6-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Solar_Glide_6,
        N'45',
        N'white',
        3300000,
        20,
        N'Solar-Glide-6-white-45',
        1
    );
END
DECLARE @ProductId_Response_Runner INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Response Runner')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Response Runner',
        N'Adidas Response Runner shoes',
        1600000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Response_Runner = ProductId
FROM Products
WHERE ProductName = N'Response Runner';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Response_Runner
    AND ImageUrl = N'/images/products/adidas/Response-Runner/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Response_Runner, N'/images/products/adidas/Response-Runner/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'36',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'37',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'38',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'39',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'40',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'41',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'42',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'43',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'44',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'45',
        N'black',
        1600000,
        20,
        N'Response-Runner-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Response_Runner
    AND ImageUrl = N'/images/products/adidas/Response-Runner/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Response_Runner, N'/images/products/adidas/Response-Runner/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'36',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'37',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'38',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'39',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'40',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'41',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'42',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'43',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'44',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'45',
        N'blue',
        1600000,
        20,
        N'Response-Runner-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Response_Runner
    AND ImageUrl = N'/images/products/adidas/Response-Runner/gray.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Response_Runner, N'/images/products/adidas/Response-Runner/gray.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'36',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'37',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'38',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'39',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'40',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'41',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'42',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'43',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'44',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Response-Runner-gray-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Response_Runner,
        N'45',
        N'gray',
        1600000,
        20,
        N'Response-Runner-gray-45',
        1
    );
END
DECLARE @ProductId_Duramo_SL_2 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Duramo SL 2')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Duramo SL 2',
        N'Adidas Duramo SL 2 shoes',
        1500000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Duramo_SL_2 = ProductId
FROM Products
WHERE ProductName = N'Duramo SL 2';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Duramo_SL_2
    AND ImageUrl = N'/images/products/adidas/Duramo-SL-2/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Duramo_SL_2, N'/images/products/adidas/Duramo-SL-2/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'36',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'37',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'38',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'39',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'40',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'41',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'42',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'43',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'44',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'45',
        N'black',
        1500000,
        20,
        N'Duramo-SL-2-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Duramo_SL_2
    AND ImageUrl = N'/images/products/adidas/Duramo-SL-2/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Duramo_SL_2, N'/images/products/adidas/Duramo-SL-2/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'36',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'37',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'38',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'39',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'40',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'41',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'42',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'43',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'44',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'45',
        N'blue',
        1500000,
        20,
        N'Duramo-SL-2-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Duramo_SL_2
    AND ImageUrl = N'/images/products/adidas/Duramo-SL-2/green.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Duramo_SL_2, N'/images/products/adidas/Duramo-SL-2/green.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'36',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'37',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'38',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'39',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'40',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'41',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'42',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'43',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'44',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-green-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'45',
        N'green',
        1500000,
        20,
        N'Duramo-SL-2-green-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Duramo_SL_2
    AND ImageUrl = N'/images/products/adidas/Duramo-SL-2/OIP.webp'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Duramo_SL_2, N'/images/products/adidas/Duramo-SL-2/OIP.webp', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'36',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'37',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'38',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'39',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'40',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'41',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'42',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'43',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'44',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-OIP-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'45',
        N'OIP',
        1500000,
        20,
        N'Duramo-SL-2-OIP-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Duramo_SL_2
    AND ImageUrl = N'/images/products/adidas/Duramo-SL-2/pink.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Duramo_SL_2, N'/images/products/adidas/Duramo-SL-2/pink.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'36',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'37',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'38',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'39',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'40',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'41',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'42',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'43',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'44',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-pink-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'45',
        N'pink',
        1500000,
        20,
        N'Duramo-SL-2-pink-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Duramo_SL_2
    AND ImageUrl = N'/images/products/adidas/Duramo-SL-2/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Duramo_SL_2, N'/images/products/adidas/Duramo-SL-2/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'36',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'37',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'38',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'39',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'40',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'41',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'42',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'43',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'44',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Duramo-SL-2-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Duramo_SL_2,
        N'45',
        N'white',
        1500000,
        20,
        N'Duramo-SL-2-white-45',
        1
    );
END
DECLARE @ProductId_Runfalcon_5 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Runfalcon 5')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Runfalcon 5',
        N'Adidas Runfalcon 5 shoes',
        1400000,
        1,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Runfalcon_5 = ProductId
FROM Products
WHERE ProductName = N'Runfalcon 5';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Runfalcon_5
    AND ImageUrl = N'/images/products/adidas/Runfalcon-5/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Runfalcon_5, N'/images/products/adidas/Runfalcon-5/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'36',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'37',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'38',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'39',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'40',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'41',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'42',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'43',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'44',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'45',
        N'black',
        1400000,
        20,
        N'Runfalcon-5-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Runfalcon_5
    AND ImageUrl = N'/images/products/adidas/Runfalcon-5/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Runfalcon_5, N'/images/products/adidas/Runfalcon-5/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'36',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'37',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'38',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'39',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'40',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'41',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'42',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'43',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'44',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'45',
        N'blue',
        1400000,
        20,
        N'Runfalcon-5-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Runfalcon_5
    AND ImageUrl = N'/images/products/adidas/Runfalcon-5/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Runfalcon_5, N'/images/products/adidas/Runfalcon-5/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'36',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'37',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'38',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'39',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'40',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'41',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'42',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'43',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'44',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Runfalcon-5-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Runfalcon_5,
        N'45',
        N'white',
        1400000,
        20,
        N'Runfalcon-5-white-45',
        1
    );
END
DECLARE @ProductId_Predator_Elite_FG INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Predator Elite FG')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Predator Elite FG',
        N'Adidas Predator Elite FG shoes',
        6200000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Predator_Elite_FG = ProductId
FROM Products
WHERE ProductName = N'Predator Elite FG';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Elite_FG
    AND ImageUrl = N'/images/products/adidas/Predator-Elite-FG/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Elite_FG, N'/images/products/adidas/Predator-Elite-FG/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'36',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'37',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'38',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'39',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'40',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'41',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'42',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'43',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'44',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'45',
        N'black',
        6200000,
        20,
        N'Predator-Elite-FG-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Elite_FG
    AND ImageUrl = N'/images/products/adidas/Predator-Elite-FG/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Elite_FG, N'/images/products/adidas/Predator-Elite-FG/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'36',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'37',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'38',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'39',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'40',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'41',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'42',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'43',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'44',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'45',
        N'red',
        6200000,
        20,
        N'Predator-Elite-FG-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Elite_FG
    AND ImageUrl = N'/images/products/adidas/Predator-Elite-FG/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Elite_FG, N'/images/products/adidas/Predator-Elite-FG/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'36',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'37',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'38',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'39',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'40',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'41',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'42',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'43',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'44',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Elite-FG-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Elite_FG,
        N'45',
        N'white',
        6200000,
        20,
        N'Predator-Elite-FG-white-45',
        1
    );
END
DECLARE @ProductId_Predator_Accuracy_1 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Predator Accuracy.1')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Predator Accuracy.1',
        N'Adidas Predator Accuracy.1 shoes',
        5200000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Predator_Accuracy_1 = ProductId
FROM Products
WHERE ProductName = N'Predator Accuracy.1';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Accuracy_1
    AND ImageUrl = N'/images/products/adidas/Predator-Accuracy.1/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Accuracy_1, N'/images/products/adidas/Predator-Accuracy.1/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'36',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'37',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'38',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'39',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'40',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'41',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'42',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'43',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'44',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'45',
        N'black',
        5200000,
        20,
        N'Predator-Accuracy.1-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Accuracy_1
    AND ImageUrl = N'/images/products/adidas/Predator-Accuracy.1/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Accuracy_1, N'/images/products/adidas/Predator-Accuracy.1/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'36',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'37',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'38',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'39',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'40',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'41',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'42',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'43',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'44',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'45',
        N'blue',
        5200000,
        20,
        N'Predator-Accuracy.1-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Accuracy_1
    AND ImageUrl = N'/images/products/adidas/Predator-Accuracy.1/purpil.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Accuracy_1, N'/images/products/adidas/Predator-Accuracy.1/purpil.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'36',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'37',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'38',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'39',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'40',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'41',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'42',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'43',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'44',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-purpil-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'45',
        N'purpil',
        5200000,
        20,
        N'Predator-Accuracy.1-purpil-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Predator_Accuracy_1
    AND ImageUrl = N'/images/products/adidas/Predator-Accuracy.1/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Predator_Accuracy_1, N'/images/products/adidas/Predator-Accuracy.1/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'36',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'37',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'38',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'39',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'40',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'41',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'42',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'43',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'44',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Predator-Accuracy.1-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Predator_Accuracy_1,
        N'45',
        N'red',
        5200000,
        20,
        N'Predator-Accuracy.1-red-45',
        1
    );
END
DECLARE @ProductId_Copa_Pure_2_Elite INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Copa Pure 2 Elite')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Copa Pure 2 Elite',
        N'Adidas Copa Pure 2 Elite shoes',
        5600000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Copa_Pure_2_Elite = ProductId
FROM Products
WHERE ProductName = N'Copa Pure 2 Elite';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Pure_2_Elite
    AND ImageUrl = N'/images/products/adidas/Copa-Pure-2-Elite/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Pure_2_Elite, N'/images/products/adidas/Copa-Pure-2-Elite/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'36',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'37',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'38',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'39',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'40',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'41',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'42',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'43',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'44',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'45',
        N'black',
        5600000,
        20,
        N'Copa-Pure-2-Elite-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Pure_2_Elite
    AND ImageUrl = N'/images/products/adidas/Copa-Pure-2-Elite/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Pure_2_Elite, N'/images/products/adidas/Copa-Pure-2-Elite/blue.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'36',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'37',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'38',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'39',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'40',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'41',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'42',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'43',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'44',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'45',
        N'blue',
        5600000,
        20,
        N'Copa-Pure-2-Elite-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Pure_2_Elite
    AND ImageUrl = N'/images/products/adidas/Copa-Pure-2-Elite/purpil.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Pure_2_Elite, N'/images/products/adidas/Copa-Pure-2-Elite/purpil.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'36',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'37',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'38',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'39',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'40',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'41',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'42',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'43',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'44',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-purpil-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'45',
        N'purpil',
        5600000,
        20,
        N'Copa-Pure-2-Elite-purpil-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Pure_2_Elite
    AND ImageUrl = N'/images/products/adidas/Copa-Pure-2-Elite/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Pure_2_Elite, N'/images/products/adidas/Copa-Pure-2-Elite/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'36',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'37',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'38',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'39',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'40',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'41',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'42',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'43',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'44',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Pure-2-Elite-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Pure_2_Elite,
        N'45',
        N'white',
        5600000,
        20,
        N'Copa-Pure-2-Elite-white-45',
        1
    );
END
DECLARE @ProductId_Copa_Sense_1 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Copa Sense.1')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Copa Sense.1',
        N'Adidas Copa Sense.1 shoes',
        4900000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Copa_Sense_1 = ProductId
FROM Products
WHERE ProductName = N'Copa Sense.1';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Sense_1
    AND ImageUrl = N'/images/products/adidas/Copa-Sense.1/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Sense_1, N'/images/products/adidas/Copa-Sense.1/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'36',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'37',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'38',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'39',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'40',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'41',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'42',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'43',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'44',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'45',
        N'black',
        4900000,
        20,
        N'Copa-Sense.1-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Sense_1
    AND ImageUrl = N'/images/products/adidas/Copa-Sense.1/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Sense_1, N'/images/products/adidas/Copa-Sense.1/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'36',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'37',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'38',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'39',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'40',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'41',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'42',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'43',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'44',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'45',
        N'red',
        4900000,
        20,
        N'Copa-Sense.1-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Sense_1
    AND ImageUrl = N'/images/products/adidas/Copa-Sense.1/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Sense_1, N'/images/products/adidas/Copa-Sense.1/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'36',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'37',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'38',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'39',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'40',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'41',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'42',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'43',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'44',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Sense.1-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Sense_1,
        N'45',
        N'white',
        4900000,
        20,
        N'Copa-Sense.1-white-45',
        1
    );
END
DECLARE @ProductId_X_Crazyfast_Elite INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'X Crazyfast Elite')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'X Crazyfast Elite',
        N'Adidas X Crazyfast Elite shoes',
        5900000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_X_Crazyfast_Elite = ProductId
FROM Products
WHERE ProductName = N'X Crazyfast Elite';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Crazyfast_Elite
    AND ImageUrl = N'/images/products/adidas/X-Crazyfast-Elite/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Crazyfast_Elite, N'/images/products/adidas/X-Crazyfast-Elite/blue.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'36',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'37',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'38',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'39',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'40',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'41',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'42',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'43',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'44',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'45',
        N'blue',
        5900000,
        20,
        N'X-Crazyfast-Elite-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Crazyfast_Elite
    AND ImageUrl = N'/images/products/adidas/X-Crazyfast-Elite/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Crazyfast_Elite, N'/images/products/adidas/X-Crazyfast-Elite/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'36',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'37',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'38',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'39',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'40',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'41',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'42',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'43',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'44',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'45',
        N'red',
        5900000,
        20,
        N'X-Crazyfast-Elite-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Crazyfast_Elite
    AND ImageUrl = N'/images/products/adidas/X-Crazyfast-Elite/yellow.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Crazyfast_Elite, N'/images/products/adidas/X-Crazyfast-Elite/yellow.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'36',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'37',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'38',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'39',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'40',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'41',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'42',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'43',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'44',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Crazyfast-Elite-yellow-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Crazyfast_Elite,
        N'45',
        N'yellow',
        5900000,
        20,
        N'X-Crazyfast-Elite-yellow-45',
        1
    );
END
DECLARE @ProductId_X_Speedportal_1 INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'X Speedportal.1')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'X Speedportal.1',
        N'Adidas X Speedportal.1 shoes',
        5300000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_X_Speedportal_1 = ProductId
FROM Products
WHERE ProductName = N'X Speedportal.1';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Speedportal_1
    AND ImageUrl = N'/images/products/adidas/X-Speedportal.1/blue.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Speedportal_1, N'/images/products/adidas/X-Speedportal.1/blue.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'36',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'37',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'38',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'39',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'40',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'41',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'42',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'43',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'44',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-blue-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'45',
        N'blue',
        5300000,
        20,
        N'X-Speedportal.1-blue-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Speedportal_1
    AND ImageUrl = N'/images/products/adidas/X-Speedportal.1/grey.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Speedportal_1, N'/images/products/adidas/X-Speedportal.1/grey.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'36',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'37',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'38',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'39',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'40',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'41',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'42',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'43',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'44',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-grey-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'45',
        N'grey',
        5300000,
        20,
        N'X-Speedportal.1-grey-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Speedportal_1
    AND ImageUrl = N'/images/products/adidas/X-Speedportal.1/orange.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Speedportal_1, N'/images/products/adidas/X-Speedportal.1/orange.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'36',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'37',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'38',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'39',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'40',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'41',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'42',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'43',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'44',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-orange-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'45',
        N'orange',
        5300000,
        20,
        N'X-Speedportal.1-orange-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_X_Speedportal_1
    AND ImageUrl = N'/images/products/adidas/X-Speedportal.1/purpil.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_X_Speedportal_1, N'/images/products/adidas/X-Speedportal.1/purpil.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'36',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'37',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'38',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'39',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'40',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'41',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'42',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'43',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'44',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'X-Speedportal.1-purpil-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_X_Speedportal_1,
        N'45',
        N'purpil',
        5300000,
        20,
        N'X-Speedportal.1-purpil-45',
        1
    );
END
DECLARE @ProductId_Goletto_VIII INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Goletto VIII')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Goletto VIII',
        N'Adidas Goletto VIII shoes',
        1200000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Goletto_VIII = ProductId
FROM Products
WHERE ProductName = N'Goletto VIII';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Goletto_VIII
    AND ImageUrl = N'/images/products/adidas/Goletto-VIII/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Goletto_VIII, N'/images/products/adidas/Goletto-VIII/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'36',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'37',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'38',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'39',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'40',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'41',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'42',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'43',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'44',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'45',
        N'black',
        1200000,
        20,
        N'Goletto-VIII-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Goletto_VIII
    AND ImageUrl = N'/images/products/adidas/Goletto-VIII/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Goletto_VIII, N'/images/products/adidas/Goletto-VIII/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'36',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'37',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'38',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'39',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'40',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'41',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'42',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'43',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'44',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'45',
        N'red',
        1200000,
        20,
        N'Goletto-VIII-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Goletto_VIII
    AND ImageUrl = N'/images/products/adidas/Goletto-VIII/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Goletto_VIII, N'/images/products/adidas/Goletto-VIII/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'36',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'37',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'38',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'39',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'40',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'41',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'42',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'43',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'44',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Goletto-VIII-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Goletto_VIII,
        N'45',
        N'white',
        1200000,
        20,
        N'Goletto-VIII-white-45',
        1
    );
END
DECLARE @ProductId_Copa_Gloro INT;

IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Copa Gloro')
BEGIN
    INSERT INTO Products
    (
        ProductName, Description, BasePrice, CategoryId,
        Brand, Gender, Material, IsActive, CreatedAt
    )
    VALUES
    (
        N'Copa Gloro',
        N'Adidas Copa Gloro shoes',
        2200000,
        3,
        N'Adidas',
        N'Unisex',
        N'Synthetic / Textile',
        1,
        GETDATE()
    );
END

SELECT @ProductId_Copa_Gloro = ProductId
FROM Products
WHERE ProductName = N'Copa Gloro';
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Gloro
    AND ImageUrl = N'/images/products/adidas/Copa-Gloro/black.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Gloro, N'/images/products/adidas/Copa-Gloro/black.png', 1);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'36',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'37',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'38',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'39',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'40',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'41',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'42',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'43',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'44',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-black-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'45',
        N'black',
        2200000,
        20,
        N'Copa-Gloro-black-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Gloro
    AND ImageUrl = N'/images/products/adidas/Copa-Gloro/red.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Gloro, N'/images/products/adidas/Copa-Gloro/red.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'36',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'37',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'38',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'39',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'40',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'41',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'42',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'43',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'44',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-red-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'45',
        N'red',
        2200000,
        20,
        N'Copa-Gloro-red-45',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductImages
    WHERE ProductId = @ProductId_Copa_Gloro
    AND ImageUrl = N'/images/products/adidas/Copa-Gloro/white.png'
)
BEGIN
    INSERT INTO ProductImages(ProductId, ImageUrl, IsMain)
    VALUES(@ProductId_Copa_Gloro, N'/images/products/adidas/Copa-Gloro/white.png', 0);
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-36'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'36',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-36',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-37'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'37',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-37',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-38'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'38',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-38',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-39'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'39',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-39',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-40'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'40',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-40',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-41'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'41',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-41',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-42'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'42',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-42',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-43'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'43',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-43',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-44'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'44',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-44',
        1
    );
END
IF NOT EXISTS (
    SELECT 1 FROM ProductVariants
    WHERE SKU = N'Copa-Gloro-white-45'
)
BEGIN
    INSERT INTO ProductVariants
    (
        ProductId, Size, Color, Price,
        StockQuantity, SKU, IsActive
    )
    VALUES
    (
        @ProductId_Copa_Gloro,
        N'45',
        N'white',
        2200000,
        20,
        N'Copa-Gloro-white-45',
        1
    );
END

