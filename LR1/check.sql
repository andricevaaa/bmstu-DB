ALTER TABLE sch.Applicant ADD CHECK(sch.Applicant.Sex IN('M', 'F'));
ALTER TABLE sch.University ADD CHECK(sch.University.UniType IN('full-time', 'online'));
ALTER TABLE sch.University ADD CHECK(sch.University.StudyType IN('old', 'bologna'));
ALTER TABLE sch.Scholarship ADD CHECK(sch.Scholarship.ScholarshipType IN('full', 'partial'));
ALTER TABLE sch.Scholarship ADD CHECK(sch.Scholarship.Degree IN('Speciality', 'Bachelor', 'Masters', 'PhD'));
ALTER TABLE sch.Application ADD CHECK(sch.Application.Status IN('accepted', 'denied', 'pending'));