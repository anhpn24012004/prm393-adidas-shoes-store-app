IF COL_LENGTH('Reviews', 'EditCount') IS NULL
BEGIN
    ALTER TABLE Reviews
    ADD EditCount INT NOT NULL
        CONSTRAINT DF_Reviews_EditCount DEFAULT 0;
END;
GO
