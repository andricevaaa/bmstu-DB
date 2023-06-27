-- Андрич Катарина ИУ7И - 56Б
-- Вариант 2

-- Задание 1

-- создание таблиц
CREATE TABLE Executor (
    ExecutorID SERIAL PRIMARY KEY,
    FIO varchar(30) NOT NULL,
    YearBorn int NOT NULL,
    WorkExperience int NOT NULL,
    Telephone varchar(20) NOT NULL
);

CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,
    FIO varchar(30) NOT NULL,
    YearBorn int NOT NULL,
    WorkExperience int NOT NULL,
    Telephone varchar(20) NOT NULL
);

CREATE TABLE Work (
    WorkID SERIAL PRIMARY KEY,
    WorkName varchar(30) NOT NULL,
    LaborCosts int NOT NULL,
    Equipment varchar(30) NOT NULL
);

CREATE TABLE WorkExec(
	WID int references Work(WorkID) NOT NULL,
	EID int references Executor(ExecutorID) NOT NULL
);

CREATE TABLE WorkCust(
	WID int references Work(WorkID) NOT NULL,
	CID int references Customer(CustomerID) NOT NULL
);

CREATE TABLE CustExec(
	CID int references Customer(CustomerID) NOT NULL,
	EID int references Executor(ExecutorID) NOT NULL
);

-- заполнение

INSERT INTO Executor(FIO, YearBorn, WorkExperience, Telephone) VALUES 
	('Johnson K', 1989, 10, '89885756440'),
	('Smith A', 1972, 20, '89886438340'),
    ('McArthur D', 1999, 2, '89886483340'),
    ('Nelson A', 1959, 30, '89958474630'),
    ('Choi H', 1972, 12, '898394857540'),
    ('Dumphry P', 1998, 5, '8744590540'),
    ('Gaynor G', 1989, 6, '89884903850'),
    ('Peterson T', 1980, 15, '897575540'),
    ('Duff M', 1977, 10, '897474796840'),
    ('Gomez P', 1992, 8, '79545684527');

INSERT INTO Customer(FIO, YearBorn, WorkExperience, Telephone) VALUES
	('Wert A', 1977, 6, '79886753420'),
	('Aert B', 1976, 10, '79886753421'),
	('Ejfhg C', 1956,  50, '7988656843422'),
	('Ojdkds D', 1976, 20, '79845863423'),
	('Olkckd E', 1960, 30, '89958474630'),
	('Ajfrt F', 1967, 15, '79887859515'),
	('Ijdksgj G', 1978, 20, '79886556226'),
	('Fkjsf H', 1950, 13, '79545684527'),
    ('Pdorjr G', 1978, 5, '79886546226'),
	('Zajehe H', 1950, 8, '795445544527');

INSERT INTO Work(WorkName, LaborCosts, Equipment) VALUES 
	('fashion', 30, 'dress'),
	('sport', 10, 'trainers'), 
	('music', 30, 'piano'),
	('IT', 100, 'Computer'),
	('food', 7, 'bread'),
	('school', 50, 'notebook'),
	('clinic', 17, 'stetoscope'),
	('shoes', 1188, 'heels'),
	('car', 123, 'wheels'),
    ('makeup', '2052', 'brush');


INSERT INTO WorkExec(WID, EID) VALUES
	(2, 7),
	(2, 4),
	(1, 10),
	(2, 2), 
	(1, 8),
	(4, 7),
	(4, 1),
	(5, 5),
	(3, 10),
	(6, 6),
	(10, 2),
	(7, 3),
	(8, 7),
	(9, 9);

INSERT INTO WorkCust(WID, CID) VALUES
	(6, 6),
	(10, 2),
    (2, 7),
	(2, 4),
	(1, 10),
	(2, 2), 
	(8, 8),
	(3, 10),
	(7, 3),
	(5, 5),
	(9, 9),
    (1, 8),
	(4, 7),
	(4, 1);

INSERT INTO CustExec(CID, EID) VALUES
	(10, 2),
    (2, 7),
    (3, 10),
    (6, 6),
	(9, 9),
    (1, 8),
	(4, 7),
	(4, 1),
	(2, 4),
	(1, 10),
	(2, 2), 
	(8, 8),
    (7, 3),
	(5, 5);

-- Задание 2

-- Инструкция SELECT, использующая предикат сравнения
-- Вывести названия работы у которых трудозатраты < 1000
SELECT WorkName
FROM Work
WHERE LaborCosts < 1000


-- Инструкцию, использующую оконную функцию
-- Вывести информацию и дать уникальные номера опыту исполнителя, который делает каждую работу.
SELECT Work.WorkName, Work.LaborCosts, Executor.ExecutorID, Executor.WorkExperience, 
row_number()
OVER(PARTITION BY Work.WorkID ORDER BY Executor.WorkExperience) as row_number
FROM Work JOIN WorkExec on Work.WorkID = WorkExec.WorkID JOIN Executor on Executor.ExecutorID = WorkExec.ExecutorID

-- Инструкция SELECT, использующая вложенные коррелированные
-- Вывести ФИО и дату рождения исполнителей, являющихся по совместительству заказчиками.
-- (Считаем что исполнитель == заказчик если у них один и тот же номер телефона).
SELECT Executor.FIO, Executor.YearBorn 
FROM Executor 
JOIN LATERAL (
	SELECT FIO, YearBorn, Telephone
	FROM Customer 
	WHERE Telephone = Executor.Telephone
) AS Person
ON Person.Telephone = Executor.Telephone;

-- Задание 3
-- Создать хранимую процедуру с двумя входными параметрами – имя базы
-- данных и имя таблицы, которая выводит сведения об индексах указанной
-- таблицы в указанной базе данных. Созданную хранимую процедуру
-- протестировать.

CREATE OR REPLACE PROCEDURE get_indexes_info(TableName VARCHAR)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT pind.indexname, pind.indexdef FROM pg_indexes pind 
        WHERE pind.schemaname = 'public' AND pind.tablename = TableName
        ORDER BY pind.indexname;
BEGIN
    OPEN current;
    LOOP
        FETCH cur INTO rec;
        RAISE NOTICE 'TABLE: %, INDEX: %s, DEFINITION: %', TableName, rec.indexname, rec.indexdef;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE current;
END;
$$ LANGUAGE PLPGSQL;
CALL get_indexes_info('Executor');
CALL get_indexes_info('Customer');
CALL get_indexes_info('Work');