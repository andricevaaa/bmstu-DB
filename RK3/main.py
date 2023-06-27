# РК3 Вариант 1
# Андрич Катарина ИУ7И - 56Б

import os
import psycopg2
from psycopg2 import OperationalError
from psycopg2.extras import  DictConnection, DictCursor
from py_linq import Enumerable
from tabulate import tabulate
from datetime import time


def connect():
        connection = None
        try:
                connection = psycopg2.connect(
                    host="localhost",
                    database="BD",
                    user="postgres",
                    password="katarina123")

                print("Connection to PostgreSQL DB successful")

        except OperationalError as e:
                print("The error '{e}' occurred")
        return connection

connection = connect()

#Найти все отделы, в которых работает более 10 сотрудников
def find_dep_bd():
        try:
            cursor = connection.cursor(cursor_factory=DictCursor)
            query = '''
                SELECT department
                FROM employee
                GROUP BY department
                HAVING count(ID) > 10;
            '''
            cursor.execute(query)
            answ = cursor.fetchall()
            print("Найти все отделы, в которых работает более 10 сотрудников")
            print(tabulate(answ, headers=['Отдел']))
            cursor.close()
        except Exception:
                print("Error")

def find_dep_pri():
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute('select * from employee')
    employee = Enumerable(cursor.fetchall())
    cursor.close()
    dep = (employee.group_by(key_names=['department'], key = lambda x: x['department']))\
        .select(lambda g: {'department': g.key.department, 'cnt':g.count()}).where(lambda g: g['cnt'] > 10)\
        .to_list()
    print(dep)

#Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
def find_empl_bd():
    try:
        cursor = connection.cursor(cursor_factory=DictCursor)
        query = '''
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
        '''
        cursor.execute(query)
        answ = cursor.fetchall()
        print("Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня")
        print(tabulate(answ))
        cursor.close()
    except Exception:
        print("Error")

def  find_empl_pri():
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute('select * from record')
    record = Enumerable(cursor.fetchall())
    cursor.close()

    bad_workers = (record.group_by(key_names=['employeeid', 'rdate', 'rtype'], key=lambda x: (x['employeeid'],
                                   str(x['rdate']), x['rtype'])). select(lambda g: {'rtype' : g.key.rtype,
                                    'employeeid': g.key.employeeid, 'cnt':g.count()})\
                   .where(lambda g:g['rtype'] == 2 and g['cnt'] > 1).to_list())
    cursor =connection.cursor(cursor_factory=DictCursor)
    cursor.execute('select * from employee')
    employee = Enumerable(cursor.fetchall())
    cursor.close()

    good_w = []
    for w in employee:
        if w not in bad_workers and w not in good_w:
            good_w.append(w)
    print(good_w)


#Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры
def  find_late():
    try:
        target_data = input('Введите дату: ')
        cursor = connection.cursor(cursor_factory=DictCursor)
        query = '''
                SELECT DISTINCT department
                FROM employee
                WHERE ID in 
                (
                    SELECT EMPLOYEEID
                    from
                    (
                        SELECT EMPLOYEEID, min(rtime)
                        FROM record
                        WHERE rtype = 1 and rdate = target_data
                        GROUP BY EMPLOYEEID
                        HAVING min(rtime) > '9:00'
                    ) AS tmp
                );
        '''
        cursor.execute(query)
        answ = cursor.fetchall()
        print("Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры")
        print(tabulate(answ))
        cursor.close()
    except Exception:
        print("ERROR")



def print_menu():
    print('\n\
          1. Найти все отделы, в которых работает более 10 сотрудников (уровень БД)\n\
          2. Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (уровень БД) \n\
          3. Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры \n\
          4. Найти все отделы, в которых работает более 10 сотрудников (уровень приложения)\n\
          5. Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (уровень приложения) \n\
          6. Выход \n\  ')

execute = [
    '__empty__',
    find_dep_bd, find_empl_bd,  find_late, find_dep_pri,  find_empl_pri,
    lambda: print("END")
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('Выбор: '))
        execute[choice]()
