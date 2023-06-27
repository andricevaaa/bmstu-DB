CREATE TABLE sch.Applicant (
    ApplicantID serial NOT NULL PRIMARY KEY,
    FirstName text NOT NULL,
    LastName text NOT NULL,
    DOB varchar(10) NOT NULL,
    Sex varchar(1) NOT NULL,
    Mail text NOT NULL,
    PassportNo int NOT NULL,
    PassportCode varchar(3),
    DateOfIssue varchar(10) NOT NULL,
	AttestateCode int NOT NULL,
	AttestateNo bigint NOT NULL
);

CREATE TABLE sch.School(
	SchoolID serial NOT NULL PRIMARY KEY,
	SchoolName text,
	AttestateCode int NOT NULL
);


CREATE TABLE sch.University (
    UniversityID serial NOT NULL PRIMARY KEY,
    Registration int NOT NULL,
    City text,
    UniType varchar(10),
    Specialty text,
    StudyType varchar(8),
    NeededPoints int NOT NULL,
    UniMail text NOT NULL
);

CREATE TABLE sch.Scholarship (
    ScholarshipID serial NOT NULL PRIMARY KEY,
    ScholarshipType varchar(8) NOT NULL,
    Accommodation varchar(3) NOT NULL,
    AccPayment int,
    Allowance int,
    ConditionalMarks float(10) NOT NULL,
    Degree varchar(10) NOT NULL
);

CREATE TABLE sch.Application (
    ApplicationID serial NOT NULL PRIMARY KEY,
    ApplicantID int REFERENCES sch.Applicant(ApplicantID),
    UniversityID int REFERENCES sch.University(UniversityID),
    ScholarshipID int REFERENCES sch.Scholarship(ScholarshipID),
    DateApplied varchar(10) NOT NULL,
    TestDate varchar(10),
    TestPlace text,
    Status text NOT NULL
);