-- РК3 Вариант 1
-- Андрич Катарина ИУ7И - 56Б

CREATE TABLE employee (
	ID SERIAL NOT NULL PRIMARY KEY,
	name TEXT,
	birthday DATE, 
	department TEXT
);

CREATE TABLE record(
	EMPLOYEEID INT REFERENCES employee(ID) NOT NULL,
	rdate DATE,
	day TEXT,
	rtime TIME,
	rtype INT
)

INSERT INTO employee(name, birthday, department)
	VALUES ('Qwer Inna A', '25-09-1995', 'IT'),
	('Qas Inna A', '30-09-1999', 'IT'),
	('B Eem W', '25-09-1990', 'Fin'),
	('Qwer Ad Q', '15-09-1997', 'Fin');

INSERT INTO record(EMPLOYEEID, rdate, day, rtime, rtype)
	VALUES
	(1, '18-12-2021', 'Вторник', '09:01', 1),
	(1, '18-12-2021', 'Вторник', '09:12', 2),
	(1, '18-12-2021', 'Вторник', '09:40', 1),
	(1, '18-12-2021', 'Вторник', '20:01', 2),

	(3, '18-12-2021', 'Вторник', '09:01', 1),
	(3, '18-12-2021', 'Вторник', '09:12', 2),
	(3, '18-12-2021', 'Вторник', '09:40', 1),
	(3, '18-12-2021', 'Вторник', '20:01', 2),

	(2, '18-12-2021', 'Вторник', '08:51', 1),
	(2, '18-12-2021', 'Вторник', '20:31', 2),

	(4, '18-12-2021', 'Вторник', '09:51', 1),
	(4, '18-12-2021', 'Вторник', '20:31', 2),

	(1, '21-12-2021', 'Пятница', '09:11', 1),
	(1, '21-12-2021', 'Пятница', '09:12', 2),
	(1, '21-12-2021', 'Пятница', '09:40', 1),
	(1, '21-12-2021', 'Пятница', '20:01', 2),

	(3, '21-12-2021', 'Пятница', '09:01', 1),
	(3, '21-12-2021', 'Пятница', '09:12', 2),
	(3, '21-12-2021', 'Пятница', '09:50', 1),
	(3, '21-12-2021', 'Пятница', '20:01', 2),

	(2, '21-12-2021', 'Пятница', '08:41', 1),
	(2, '21-12-2021', 'Пятница','20:31', 2),

	(4, '21-12-2021', 'Пятница', '09:51', 1),
	(4, '21-12-2021', 'Пятница', '20:31', 2);

--Написать скалярную функцию, возвращающую количество сотрудников в возрасте от 18 до
--40, выходивших более 3х раз.

CREATE OR REPLACE FUNCTION latters_cnt(target_date date) RETURNS INT AS $$
	BEGIN
	RETURN(
		SELECT count(*)
		FROM(
			SELECT DISTINCT ID
			FROM employee
			WHERE EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birthday) BETWEEN 18 AND 40 AND 
			ID IN(
				SELECT EMPLOYEEID
				FROM(
					SELECT EMPLOYEEID, rdate, rtype, count(*)
					FROM record
					WHERE rdate = target_date
					GROUP BY EMPLOYEEID, rdate, rtype
					HAVING rtype = 2 AND count(*) > 3
					) AS tmp0
				)
			) AS tmp1
		);
	END;
	$$ language plpgsql;

SELECT * FROM latters_cnt('21-12-2021')


--------------------------------------------------------
--Найти все отделы, в которых работает более 10 сотрудников
SELECT department
FROM employee
GROUP BY department
HAVING count(ID) > 10;

--Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
SELECT ID
FROM employee
WHERE ID not IN(
	SELECT EMPLOYEEID
	FROM (
		SELECT EMPLOYEEID, rdate, rtype, count(*)
		FROM record
		GROUP BY EMPLOYEEID, rdate, rtype
		HAVING rtype=2 AND count(*) > 1
		) AS tmp
);

--Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры
SELECT DISTINCT department
FROM employee
WHERE ID IN 
(
	SELECT EMPLOYEEID
	FROM
	(
		SELECT EMPLOYEEID, min(rtime)
		FROM record
		WHERE rtype = 1 AND rdate = '21-12-2021'
		GROUP BY EMPLOYEEID
		HAVING min(rtime) > '9:00'
	) AS tmp
);