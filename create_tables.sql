-- ############################## CREATING TABLES ################################
-- CREATING Students TABLE
DROP TABLE IF EXISTS Students;
CREATE TABLE Students (
	StudentID BIGSERIAL NOT NULL PRIMARY KEY,
	StudentFname TEXT DEFAULT NULL,
	StudentLname TEXT DEFAULT NULL,
	BisonEmail TEXT DEFAULT NULL
);

-- CREATING Courses TABLE
DROP TYPE IF EXISTS SEMESTER;
DROP TABLE IF EXISTS Courses;
CREATE TYPE SEMESTER AS ENUM ('fall', 'spring', 'summer');
CREATE TABLE Courses (
	CourseID BIGSERIAL NOT NULL PRIMARY KEY,
	CourseName TEXT  DEFAULT NULL,
	CourseNumber INTEGER  DEFAULT NULL,
	DepartmentName TEXT  DEFAULT NULL,
	Semester SEMESTER DEFAULT 'fall',
	Year INTEGER DEFAULT NULL
);

-- CREATING CourseEnrollments TABLE
DROP TABLE IF EXISTS CourseEnrollments;
CREATE TABLE CourseEnrollments (
	StudentID BIGSERIAL NOT NULL REFERENCES Students(StudentID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,
	CourseID BIGSERIAL NOT NULL REFERENCES Courses(CourseID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,
	PRIMARY KEY (StudentID, CourseID)
);

-- CREATING Distributions TABLE
DROP TABLE IF EXISTS Distributions;
CREATE TABLE Distributions (
	DistributionID BIGSERIAL NOT NULL PRIMARY KEY,
	CourseID  INTEGER REFERENCES Courses(CourseID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,

	CategoryName TEXT  DEFAULT NULL,
	Percent REAL  DEFAULT 0.00
);

-- CREATING Assignments TABLE
DROP TABLE IF EXISTS Assignments;
CREATE TABLE Assignments (
	AssignmentID BIGSERIAL NOT NULL PRIMARY KEY,
	DistributionID INTEGER REFERENCES Distributions(DistributionID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,
	CourseID INTEGER REFERENCES Courses(CourseID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,
  MaximumPoints REAL  DEFAULT 0.00,
  AssignmentName TEXT  DEFAULT NULL,
  AssignmentDescription TEXT  DEFAULT NULL
);

-- CREATING StudentGrades TABLE
DROP TABLE IF EXISTS StudentGrades;
CREATE TABLE StudentGrades (
	StudentID BIGSERIAL NOT NULL REFERENCES Students(StudentID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,
	AssignmentID BIGSERIAL NOT NULL REFERENCES Assignments(AssignmentID)
                          ON DELETE CASCADE
                          ON UPDATE CASCADE,
	PointsObtained REAL  DEFAULT 0.00,
	PRIMARY KEY (StudentID, AssignmentID)
);
