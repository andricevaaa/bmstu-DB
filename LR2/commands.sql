-- 1)Инструкция SELECT, использующая предикат сравнения.
-- Вывести имя людей у которых Сербскые пасспорты
SELECT DISTINCT sch.Applicant.FirstName
FROM sch.Applicant
WHERE sch.Applicant.PassportCode = 'SER'

-- 2)Инструкция SELECT, использующая предикат BETWEEN.
-- Вывести почту всех университетов для коротых нужно больше 280 баллов
SELECT DISTINCT sch.University.UniMail
FROM sch.University
WHERE sch.University.NeededPoints BETWEEN 280 AND 350

-- 3)Инструкция SELECT, использующая предикат LIKE.
-- Фамилия людей, у которых в имени "en"
SELECT DISTINCT sch.Applicant.LastName
FROM sch.Applicant
WHERE sch.Applicant.FirstName LIKE '%en%'

-- 4) Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- ИД унивсерситетов в Лондоне
SELECT sch.University.Registration, sch.University.Specialty
FROM sch.University
WHERE sch.University.Registration in 
(
	SELECT sch.University.Registration 
	from sch.University
	WHERE City ='Tokyo'
)
AND  sch.University.UniType = 'online' 

-- 5)Инструкция SELECT, использующая предикат EXISTS(Возвращает значение TRUE, если вложенный запрос содержит хотя бы одну строку.) с вложенным подзапросом.
-- Вывести статус людей у которых средняя оценка между 3.5 и 4.0
SELECT Status
FROM sch.Application
WHERE EXISTS 
(
	SELECT ConditionalMarks
	from sch.Scholarship
	WHERE Application.ScholarshipID = Scholarship.ScholarshipID  AND ConditionalMarks BETWEEN 3.5 AND 4.0
)

-- 6)Инструкция SELECT, использующая предикат сравнения с квантором.
-- Вывести тиш стипендии у кооторых самая высокая выплата между тем у которых нет обшаги 
SELECT ScholarshipType
from sch.Scholarship
WHERE Allowance > ALL
(
	SELECT Allowance
	from sch.Scholarship
	WHERE Accommodation = 'NO'
) 

-- 7)Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- AVG - Эта функция возвращает среднее арифметическое группы значений. Значения NULL она не учитывает.
-- Вывести средню оценку для все полных стипендии
SELECT AVG(ConditionalMarks) AS Mark
FROM sch.Scholarship
WHERE ScholarshipType = 'full'

-- 8)Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Вывести все данные о университетах, для которых нужно больше среднего балла
SELECT *
FROM sch.University
WHERE NeededPoints > (SELECT AVG(NeededPoints) FROM sch.University)

-- 9)Инструкция SELECT, использующая простое выражение CASE
-- Вывод имени и фамилии студента и статус стипендии
SELECT FirstName, LastName,
	CASE Status
		WHEN 'accepted' THEN 'Applicant got the scholarship'
		WHEN 'denied' THEN 'Applicant did not get the scholarship'
		WHEN 'pending' THEN 'The decision has not yet been made'
		ELSE 'status uknown'
	END
FROM sch.Application JOIN sch.Applicant ON sch.Application.ApplicantID = sch.Applicant.ApplicantID

-- 10)Инструкция SELECT, использующая поисковое выражение CASE.
-- Анализ баллов нужных для поступления в универзитет
SELECT Registration, UniMail,
	CASE
		WHEN NeededPoints > 225 THEN 'Needed more points'
		ELSE 'Needed less points'
	END
FROM sch.University

-- 11)Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- Создать временую таблицу с вузами, в которые труднее всего поступить
CREATE TEMP TABLE 
best_unis AS
SELECT *
from sch.University
WHERE NeededPoints > 340

-- 12)Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
--вывести имя и фамилию всех людей которые получили стипендию
SELECT DISTINCT FirstName, LastName
FROM sch.Applicant p JOIN LATERAL 
	(SELECT DateApplied, ApplicantID
	 FROM sch.Application 
	 WHERE Status = 'accepted') q
ON p.ApplicantID = q.ApplicantID;

-- 13) Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Вывести ид всех школах у которых ученики котрые хотят поступить на университет
-- для которого нужно больше 250 баллов
SELECT ID
FROM sch.School
WHERE AttestateCode in 
(
	SELECT AttestateCode
	FROM sch.Applicant
	WHERE sch.Applicant.ApplicantID IN
	(
		SELECT ApplicantID
		FROM sch.Application
		WHERE UniversityID IN
		(
			SELECT UniversityID
			FROM sch.University
			WHERE NeededPoints > 250
		)
	)
)

-- 14) Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Вывести среднее количество стипендии для каждого уровня образования при проживании в общежитии
SELECT CAST(AVG(Allowance) as INT), Degree
FROM sch.Scholarship
WHERE Accommodation = 'YES'
GROUP BY Degree

-- 15)Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Вывести среднее количество стипендии для каждого уровня образования при проживании в общежитии
SELECT CAST(AVG(Allowance) as INT), Accommodation, Degree
FROM sch.Scholarship
GROUP BY Degree, Accommodation
HAVING Accommodation = 'YES'

-- 16) Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
-- добавить строчку в таблицу application
INSERT INTO sch.Application VALUES (1051, 561, 56, 888, '25/09/2021', '25/10/2021', 'Embassy', 'pending');

-- 17) Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
INSERT INTO sch.Scholarship (ScholarshipID, ScholarshipType, Accommodation, AccPayment, Allowance, ConditionalMarks, Degree)
SELECT MAX(ScholarshipID) * 2, 'full', 'YES', 1024, 2500, 4.23, 'Masters' 
FROM sch.Scholarship  
WHERE ConditionalMarks > 4.00;

-- 18) Простая инструкция UPDATE.
UPDATE sch.Applicant
SET FirstName = 'Natasha'
WHERE ApplicantID = 727

-- 19)Инструкция UPDATE со скалярным подзапросом в предложении SET
UPDATE sch.University
SET NeededPoints = 
(
SELECT AVG(NeededPoints)
FROM sch.University
WHERE UniversityID = 556
)
WHERE UniversityID = 556

-- 20) Простая инструкция DELETE.
DELETE FROM sch.Application
WHERE Status = 'denied'

-- 21)Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE
DELETE FROM sch.Application
WHERE sch.Application.ScholarshipID in (SELECT sch.Scholarship.ScholarshipID FROM sch.Scholarship WHERE ConditionalMarks > 4.00)

-- 22) Инструкция SELECT, использующая простое обобщенное табличное выражение
--Выбрать из таблицы среднее баллы для каждый город
WITH CityPoints(NeededPoints, City)
AS 
(
	SELECT CAST(AVG(NeededPoints) as INT), City
	FROM sch.University
	GROUP BY City
)
SELECT *
FROM CityPoints

-- 23)Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
WITH RECURSIVE applicanttt AS (
	SELECT
		FirstName,
		LastName,
		AttestateCode,
		Sex
	FROM
		sch.Applicant
	WHERE
		Sex = 'F'
	UNION
		SELECT
			sch.Applicant.FirstName, sch.Applicant.LastName,sch.Applicant.AttestateCode, sch.Applicant.Sex
		FROM
			sch.Applicant
		JOIN applicanttt ON applicanttt.AttestateCode = sch.Applicant.AttestateCode
) SELECT
	*
FROM
	applicanttt;

-- 24)Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
SELECT DISTINCT Registration, Specialty, AVG(NeededPoints) OVER(PARTITION BY Specialty) AS avg_points FROM sch.University

-- 25)Оконные фнкции для устранения дублей
CREATE TABLE test( name VARCHAR NOT NULL, surname VARCHAR NOT NULL, age INTEGER);
INSERT INTO test (name, surname, age) VALUES 
('Ann', 'Kosenko', 12), ('Brian', 'Shaw', 22), ('Brian', 'Shaw', 22), ('Brian', 'Shaw', 22), ('Ann', 'Kosenko', 12);

WITH test_deleted AS(DELETE FROM test RETURNING *),
test_inserted AS(SELECT name, surname, age, ROW_NUMBER() OVER(PARTITION BY name, surname, age ORDER BY name, surname, age) 
 				 rownum FROM test_deleted)INSERT INTO test SELECT name, surname, age
				 FROM test_inserted WHERE rownum = 1;
SELECT *
FROM test




