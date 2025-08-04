-- 1. FN_CalcExamResult
USE [ExaminationSys]
GO

USE [ExaminationSys]
GO

CREATE FUNCTION FN_CalcExamResult
(
    @StudentID INT,
    @ExamID INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @FinalResult FLOAT;

    SELECT @FinalResult = SUM(QuestionScore)
    FROM (
        SELECT 
            CASE 
		    	-- must add "type" attribute for [Question] table
                WHEN q.[Type] = 'MC' AND sa.StdAnswer = mq.CorrectChoice THEN mq.FullDegree
                WHEN q.[Type] = 'TF' AND sa.StdAnswer = tq.CorrectAns THEN tq.FullDegree  -- must add "FullDegree" attribute to [TFQuestion] table
                -- Add more cases for other question types as needed
                ELSE 0
            END AS QuestionScore
        FROM [dbo].[StdAnswers] sa
        INNER JOIN [dbo].[Question] q ON sa.QstID = q.ID
        LEFT JOIN [dbo].[MCQuestion] mq ON q.ID = mq.QuestionID AND q.[Type] = 'MC'
        LEFT JOIN [dbo].[TFQuestion] tq ON q.ID = tq.QuestionID AND q.[Type] = 'TF'
        WHERE sa.StdID = @StudentID AND sa.ExamID = @ExamID
    ) AS ResultDetails;

    RETURN @FinalResult;
END;
GO

DECLARE @Result FLOAT;
SET @Result = dbo.FN_CalcExamResult(@StudentID = 1, @ExamID = 123);

------------------------------------------------------------------------------------------------------------
-- 1. checkStdAnswer TRIGGER
USE [ExaminationSys]
GO

CREATE TRIGGER checkStdAnswer
ON [dbo].[StdAnswers]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @QuestionID INT, @StudentAnswer NVARCHAR(MAX), @ExamID INT;
    DECLARE @Degree FLOAT;

    -- Cursor to iterate through the inserted rows in StdAnswers
    DECLARE answerCursor CURSOR FOR
    SELECT QstID, StdAnswer, ExamID
    FROM inserted;

    OPEN answerCursor;

    FETCH NEXT FROM answerCursor INTO @QuestionID, @StudentAnswer, @ExamID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
      
        SELECT @Degree = CASE 
		-- must add "type" attribute for [Question] table
                            WHEN q.[Type] = 'MC' AND @StudentAnswer = mq.CorrectChoice THEN mq.FullDegree
                            WHEN q.[Type] = 'TF' AND @StudentAnswer = tq.CorrectAns THEN tq.FullDegree
                            -- Add more cases for other question types as needed
                            ELSE 0
                        END
        FROM [dbo].[Question] q
        LEFT JOIN [dbo].[MCQuestion] mq ON q.ID = mq.QuestionID AND q.[Type] = 'MC'
        LEFT JOIN [dbo].[TFQuestion] tq ON q.ID = tq.QuestionID AND q.[Type] = 'TF'
        WHERE q.ID = @QuestionID;

        UPDATE [dbo].[StdAnswers]
        SET Degree = @Degree  -- must add "degree" attribute for [StdAnswers] table
        WHERE QstID = @QuestionID AND StdAnswer = @StudentAnswer AND ExamID = @ExamID;

        FETCH NEXT FROM answerCursor INTO @QuestionID, @StudentAnswer, @ExamID;
    END;

    CLOSE answerCursor;
    DEALLOCATE answerCursor;
END;
GO

----------------------------------------------------------------------------------
-- 1. MCQExamContentVE VIEW
CREATE VIEW MCQExamContentVE
AS
SELECT
    e.ID AS ExamID,
    e.CourseID,
    q.ID AS QuestionID,
    q.Content AS QuestionContent,
    mcq.Choice1,
    mcq.Choice2,
    mcq.Choice3,
    mcq.Choice4
FROM
    [dbo].[Exam] e
INNER JOIN
    [dbo].[StdAnswers] sa ON e.ID = sa.ExamID
INNER JOIN
    [dbo].[Question] q ON sa.QstID = q.ID
INNER JOIN
    [dbo].[MCQuestion] mcq ON q.ID = mcq.QuestionID
WHERE
    q.[Type] = 'MC'; -- Assuming 'MC' is the type for multiple-choice questions
	-- must add "type" attribute for [Question] table
GO

-----------------------------------------------------------------------------------
-- 2. TFQExamContentVE VIEW

CREATE VIEW TFQExamContentVE
AS
SELECT
    e.ID AS ExamID,
    e.CourseID,
    q.ID AS QuestionID,
    q.Content AS QuestionContent,
    tfq.CorrectAns
FROM
    [dbo].[Exam] e
INNER JOIN
    [dbo].[StdAnswers] sa ON e.ID = sa.ExamID
INNER JOIN
    [dbo].[Question] q ON sa.QstID = q.ID
INNER JOIN
    [dbo].[TFQuestion] tfq ON q.ID = tfq.QuestionID
WHERE
    q.[Type] = 'TF'; -- Assuming 'TF' is the type for true/false questions
	-- must add "type" attribute for [Question] table
GO




