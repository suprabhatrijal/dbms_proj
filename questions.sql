-- Question 4:
SELECT StudentGrades.AssignmentID, AVG(StudentGrades.PointsObtained), 
  MAX(StudentGrades.PointsObtained), 
  MIN(StudentGrades.PointsObtained)
FROM StudentGrades
WHERE StudentGrades.AssignmentID = 2
GROUP BY StudentGrades.AssignmentID;



-- Question 5: LIST ALL THE STUDENTS IN A GIVEN COURSE
SELECT StudentFname, StudentLname, BisonEmail, CourseName FROM
  Students JOIN CourseEnrollments ON Students.StudentID = CourseEnrollments.StudentID
  JOIN Courses ON CourseEnrollments.CourseID = Courses.CourseID
WHERE Courses.CourseID = 1

-- Question 6: List all of the students in a course and all of their scores on every assignment
SELECT StudentFname, StudentLname, BisonEmail, Courses.CourseName, AssignmentName, PointsObtained,MaximumPoints FROM
  Students JOIN CourseEnrollments ON Students.StudentID = CourseEnrollments.StudentID
  JOIN Courses ON CourseEnrollments.CourseID = Courses.CourseID
  JOIN StudentGrades ON Students.StudentID = StudentGrades.StudentID
  JOIN Assignments ON StudentGrades.AssignmentID = Assignments.AssignmentID
WHERE CourseEnrollments.CourseID = 1
ORDER BY StudentFname;



-- Question 7: Add an assignment to a course;
INSERT INTO Assignments (DistributionID, CourseID, AssignmentName, AssignmentDescription, MaximumPoints)
	VALUES
	(
		(SELECT DistributionID FROM 
			Distributions JOIN Courses ON Distributions.CourseID = Courses.CourseID
		WHERE Courses.CourseName = 'Persuasive Writing' AND
		Distributions.CategoryName = 'Project'),
		(
			SELECT CourseID FROM Courses WHERE CourseName = 'Persuasive Writing'
		),
		'New Project',
		'This is a new project',
		50
	)
RETURNING *;


-- Question 8: Change the percentages of the categories for a course
UPDATE Distributions SET Percent=10 WHERE CategoryName = 'Project' AND CourseID = 4 RETURNING *;

UPDATE Distributions SET Percent=60 WHERE CategoryName = 'Final' AND CourseID = 4 RETURNING *;
	
UPDATE Distributions SET Percent=30 WHERE CategoryName = 'Participation' AND CourseID = 4 RETURNING *;

SELECT * FROM Distributions WHERE CourseID = 4;

-- Question 9:
UPDATE StudentGrades SET PointsObtained = PointsObtained + 2 WHERE AssignmentID = 5;
SELECT * FROM StudentGrades WHERE AssignmentID = 5;

-- Question 10
UPDATE StudentGrades SET PointsObtained = PointsObtained + 2
	WHERE StudentGrades.StudentID IN (
	SELECT Students.StudentID FROM Students WHERE StudentLname LIKE '%q%' OR StudentLname LIKE '%Q%' 
)
RETURNING *;



-- Question 11
-- Get total weighted grade out of 100 for all courses for a particular student
SELECT 
	Students.StudentFname, 
	Students.StudentLname, 
	Courses.CourseName, 
	GradesByCourse.Grade 
FROM 
	(
		SELECT 
			WeightedGrades.CourseID, 
			WeightedGrades.StudentID, 
			SUM(Avg)*100 AS GRADE 
		FROM 
			(
				SELECT StudentGrades.StudentID,
						Assignments.CourseID, 
						Distributions.CategoryName, 
						AVG((StudentGrades.PointsObtained/Assignments.MaximumPoints)*(Distributions.Percent/100)) 
				FROM
					StudentGrades JOIN Assignments ON Assignments.AssignmentID = StudentGrades.AssignmentID
					JOIN Distributions ON Distributions.DistributionID = Assignments.DistributionID
				WHERE StudentGrades.StudentID = 1
				GROUP BY 
					Distributions.CategoryName, 
					Assignments.CourseID, 
					StudentGrades.StudentID
			) AS WeightedGrades
		GROUP BY WeightedGrades.CourseID, WeightedGrades.StudentID
	) AS GradesByCourse
JOIN Students ON Students.StudentID = GradesByCourse.StudentID
JOIN Courses ON Courses.CourseID = GradesByCourse.CourseID;

-- Get total weighted grade out of 100 for a pariticular courses for a particular student
SELECT 
	Students.StudentFname, 
	Students.StudentLname, 
	Courses.CourseName, 
	GradesByCourse.Grade 
FROM 
	(
		SELECT 
			WeightedGrades.CourseID, 
			WeightedGrades.StudentID, 
			SUM(Avg)*100 AS GRADE 
		FROM 
			(
				SELECT StudentGrades.StudentID,
						Assignments.CourseID, 
						Distributions.CategoryName, 
						AVG((StudentGrades.PointsObtained/Assignments.MaximumPoints)*(Distributions.Percent/100)) 
				FROM
					StudentGrades JOIN Assignments ON Assignments.AssignmentID = StudentGrades.AssignmentID
					JOIN Distributions ON Distributions.DistributionID = Assignments.DistributionID
				WHERE StudentGrades.StudentID = 1
				GROUP BY 
					Distributions.CategoryName, 
					Assignments.CourseID, 
					StudentGrades.StudentID
			) AS WeightedGrades
		GROUP BY WeightedGrades.CourseID, WeightedGrades.StudentID
	) AS GradesByCourse
JOIN Students ON Students.StudentID = GradesByCourse.StudentID
JOIN Courses ON Courses.CourseID = GradesByCourse.CourseID
WHERE Courses.CourseID = 1;


-- Question 12
SELECT 
	Students.StudentFname, 
	Students.StudentLname, 
	Courses.CourseName, 
	GradesByCourse.Grade 
FROM 
	(
		SELECT 
			WeightedGrades.CourseID, 
			WeightedGrades.StudentID, 
			SUM(Avg)*100 AS GRADE 
		FROM 
			(
				SELECT StudentGrades.StudentID,
						Assignments.CourseID, 
						Distributions.CategoryName, 
						AVG((StudentGrades.PointsObtained/Assignments.MaximumPoints)*(Distributions.Percent/100)) 
				FROM
					StudentGrades JOIN Assignments ON Assignments.AssignmentID = StudentGrades.AssignmentID
					JOIN Distributions ON Distributions.DistributionID = Assignments.DistributionID
				WHERE StudentGrades.StudentID = 1
				AND StudentGrades.AssignmentID != 
					(
						SELECT StudentGrades.AssignmentID 
						FROM StudentGrades JOIN Assignments ON Assignments.AssignmentID = StudentGrades.AssignmentID
						WHERE (StudentGrades.PointsObtained/Assignments.MaximumPoints) = 
							(
								SELECT MIN(StudentGrades.PointsObtained/Assignments.MaximumPoints) 
								FROM StudentGrades JOIN Assignments ON Assignments.AssignmentID = StudentGrades.AssignmentID
									JOIN Distributions ON Distributions.DistributionID = Assignments.DistributionID
								WHERE Assignments.CourseID = 1
								AND Distributions.CategoryName = 'Midterm'
							)
					)
				GROUP BY 
					Distributions.CategoryName, 
					Assignments.CourseID, 
					StudentGrades.StudentID
			) AS WeightedGrades
		GROUP BY WeightedGrades.CourseID, WeightedGrades.StudentID
	) AS GradesByCourse
JOIN Students ON Students.StudentID = GradesByCourse.StudentID
JOIN Courses ON Courses.CourseID = GradesByCourse.CourseID
WHERE Courses.CourseID = 1;
