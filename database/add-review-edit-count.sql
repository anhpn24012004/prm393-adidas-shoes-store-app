USE AdidasShoesStore;
GO

IF COL_LENGTH('dbo.Users', 'ResetPasswordOtp') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD ResetPasswordOtp NVARCHAR(6) NULL;
END
GO

IF COL_LENGTH('dbo.Users', 'ResetPasswordOtpExpiredAt') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD ResetPasswordOtpExpiredAt DATETIME NULL;
END
GO

IF COL_LENGTH('dbo.Users', 'ResetPasswordToken') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD ResetPasswordToken NVARCHAR(255) NULL;
END
GO

IF COL_LENGTH('dbo.Users', 'ResetPasswordTokenExpires') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD ResetPasswordTokenExpires DATETIME NULL;
END
GO