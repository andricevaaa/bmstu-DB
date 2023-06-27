import psycopg2
from psycopg2 import OperationalError
#
# fetchall() – возвращает число записей в виде упорядоченного списка;
# fetchmany(size) – возвращает число записей не более size;
# fetchone() – возвращает первую запись.

# Важно! Стандартный курсор забирает все данные с сервера сразу, не зависимо от того, используем мы .fetchall() или .fetchone()

text = '''
1)Выполнить скалярный запрос
2)Выполнить запрос с несколькими join
3)Выполнить запрос с ОТВ и оконными функциями
4)Выполнить запрос к метаданным
5)Вызвать скалярную функцию(написанную в третьей л.р.)
6)Вызвать многооператорную или табличную функцию(написанную в 3 л.р.)
7)Вызвать хранимую процедуру(написанную 3 л.р.)
8)Вызвать системную функцию или процедуру
9)Создать таблицу в базе данных, соответствующую теме бд
10)Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY
11) 
'''

# получение человека c id = 980
scalarRequest = '''
select ApplicantID, FirstName, LastName from sch.Applicant where ApplicantID = 980;
'''

# получить имена игроков, аббревиатуру команды, дату игры для команды 'ATL'
multJoinRequest = '''
select sch.Applicant.FirstName, sch.Applicant.LastName, sch.School.SchoolID, sch.Application.Status
from sch.Applicant join sch.School on sch.Applicant.AttestateCode = sch.School.AttestateCode join sch.Application on sch.Applicant.ApplicantID = sch.Application.ApplicantID
where sch.Applicant.Sex = 'M'
'''

#Получить средний NeededPoints для каждого города:
OTV = '''
WITH Points(NeededPoints, City) AS
(
	SELECT NeededPoints, City
	from sch.University
)
SELECT DISTINCT City, AVG(NeededPoints) OVER(PARTITION by City)
from Points;
'''

# Получить все данные из public
metadataRequest = '''
select * from pg_tables where schemaname = 'public';
'''

#  Получить максимальное количество баллов для поступления в университет
scalarFunc = '''
select * from most_points();
'''

# Вывести все стипендии для которых нужно оценка > 4.8
tableFunc = '''
select * from get_scholarship(4.80);
'''

#Уменьшаем нужную оденку для студентов у которых нет общежитии
storedProc = '''
call change_condition('NO', 0.2);
select *
from sch.Scholarship WHERE sch.Scholarship.Accommodation = 'NO'
'''

# Создать таблицу
tableCreation = '''
create table if not exists test_result(
	ApplicantID int,
	TestScore int
);
'''

# Вставить данные в таблицу
tableInsertion = '''
insert into test_result values
(56, 78),
(752, 55),
(980, 89),
(1000, 95);
select * from test_result;
'''

# Вывести имя текущей базы данных
systemFunc = '''
select current_catalog;
'''

def output(cur, func):
    if func == 1:
        answer = cur.fetchall()
        print("\nВывести человека c id = 980 : \n")
        print("Результат :")
        print("ApplicantID", "FirstName", "LastName")
        print(answer[0][0], answer[0][1], answer[0][2])

    elif func == 2:
        answer = cur.fetchall()

        print("\nПолучить имена, номер атестата и стаус всех мальчиков : \n")
        print("Результат :")
        print("FisrtName LastName SchoolID Status")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3])

    elif func == 3:
        answer = cur.fetchall()

        print("\nПолучить средний NeededPoints для каждого города: \n")
        print("Результат :")
        print("city avg")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1])

    elif func == 4:
        answer = cur.fetchall()

        print("\n Получить все данные из public: \n")
        print("Результат :")
        print("shemaname tablename tableowner tablespace hasIndexes hasrules hastriggers")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2],  answer[i][3],  answer[i][4],  answer[i][5], answer[i][6])

    elif func == 5:
        answer = cur.fetchall()

        print("\n Получить максимальное количество баллов для поступления в университет: \n")
        print("Результат :")
        print("most points")
        print(answer[0][0])

    elif func == 6:
        answer = cur.fetchall()

        print("\n Вывести все стипендии для которых нужно оценка > 4.8 \n")
        print("Результат :")
        print("ScholarshipID, ScholarshipType, Accommodation, AccPayment, Allowance, ConditionalMarks, Degree")
        for i in range (len(answer)):
            print(answer[i])

    elif func == 7:
        answer = cur.fetchall()

        print("\n Уменьшаем нужную оденку для студентов у которых нет общежитии: \n")
        print("Результат :")
        print("ScholarshipID, ScholarshipType, Accommodation, AccPayment, Allowance, ConditionalMarks, Degree")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3], answer[i][4], answer[i][5], answer[i][6])

    elif func == 8:
        answer = cur.fetchall()


        print("\n Вывести имя текущей базы данных: \n")
        print("Результат :")
        print("current catalog")
        print(answer[0][0])

    elif func == 9:
        print("\n Создать таблицу: \n")
        print("Результат :")
        print("Table created")

    elif func == 10:
        answer = cur.fetchall()

        print("\n Вставить данные в таблицу: \n")
        print("Результат :")
        print("ApplicantID, TestScore")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1])
        

def requestPgQuery(connection, query, func):
    cursor = connection.cursor()
    cursor.execute(query)
    # COMMIT фиксирует текущую транзакцию. Все изменения, произведённые транзакцией, становятся видимыми для других и гарантированно сохранятся в случае сбоя.
    connection.commit()
    output(cursor, func)
    cursor.close()



def connect():
    connection = None
    try:
        connection = psycopg2.connect(
            host="localhost",
            database="DB",
            user="postgres",
            password="katarina123")


        print("Connection to PostgreSQL DB successful")

    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection


def menu(connection):
    print(text)
    print("Выберите действие:")
    choice = int(input())
    while(choice):
        if (choice == 1):
            requestPgQuery(connection, scalarRequest, 1)
        elif choice == 2:
            requestPgQuery(connection, multJoinRequest, 2)
        elif choice == 3:
            requestPgQuery(connection, OTV, 3)
        elif choice == 4:
            requestPgQuery(connection, metadataRequest, 4)
        elif choice == 5:
            requestPgQuery(connection, scalarFunc, 5)
        elif choice == 6:
            requestPgQuery(connection, tableFunc, 6)
        elif choice == 7:
            requestPgQuery(connection, storedProc, 7)
        elif choice == 8:
            requestPgQuery(connection, systemFunc, 8)
        elif choice == 9:
            requestPgQuery(connection, tableCreation, 9)
        elif choice == 10:
            requestPgQuery(connection, tableInsertion, 10)
        print("\nВыберите действие:")
        choice = int(input())


if __name__ == '__main__':
    connection = connect()
    menu(connection)
    connection.close()
