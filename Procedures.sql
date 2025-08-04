-- 1. updateIntakeNumSP 
CREATE PROCEDURE updateIntakeNumSP
    @IntakeID INT,
    @NewNumber INT
AS
BEGIN
    UPDATE [dbo].[Intake]
    SET [Number] = @NewNumber
    WHERE [ID] = @IntakeID;
END;
GO
EXEC updateIntakeNumSP @IntakeID = , @NewNumber = ;
--------------------------------------------------------------------
-- 2. addCourseSP 
CREATE PROCEDURE addCourseSP
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @MaxDegree FLOAT,
    @MinDegree FLOAT
AS
BEGIN
    INSERT INTO [dbo].[Course] ([Title], [Description], [MaxDegree], [MinDegree])
    VALUES (@Title, @Description, @MaxDegree, @MinDegree);
END;
GO
EXEC addCourseSP 
    @Title = N'',
    @Description = N'',
    @MaxDegree = ,
    @MinDegree = ;
------------------------------------------------------------------------------
-- 3. updateCrsTitleSP 
CREATE PROCEDURE updateCrsTitleSP
    @CourseID INT,
    @NewTitle NVARCHAR(255)
AS
BEGIN
    UPDATE [dbo].[Course]
    SET [Title] = @NewTitle
    WHERE [ID] = @CourseID;
END;
GO
EXEC updateCrsTitleSP @CourseID = , @NewTitle = N'';
----------------------------------------------------------------------------------
-- 4. updateCrsDescSP
CREATE PROCEDURE updateCrsDescSP
    @CourseID INT,
    @NewDescription NVARCHAR(MAX)
AS
BEGIN
    UPDATE [dbo].[Course]
    SET [Description] = @NewDescription
    WHERE [ID] = @CourseID;
END;
GO
EXEC updateCrsDescSP @CourseID = , @NewDescription = N'';
----------------------------------------------------------------------------
-- 5. updateCrsMinMaxDegreeSP
CREATE PROCEDURE updateCrsMinMaxDegreeSP
    @CourseID INT,
    @NewMinDegree FLOAT,
    @NewMaxDegree FLOAT
AS
BEGIN
    UPDATE [dbo].[Course]
    SET [MinDegree] = @NewMinDegree,
        [MaxDegree] = @NewMaxDegree
    WHERE [ID] = @CourseID;
END;
GO
EXEC updateCrsMinMaxDegreeSP @CourseID = , @NewMinDegree = , @NewMaxDegree = ;
---------------------------------------------------------------------------------------------











