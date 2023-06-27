CREATE EXTENSION PLPYTHON3U;
-- 1) Скалярная функция PL/Python.
-- Возвращает сколько стипендии остается после оплаты общежитии
CREATE OR REPLACE FUNCTION get_minimal_spendings_py(AccPayment INT, Allowance INT)
RETURNS DECIMAL 
AS $$
    return Allowance - AccPayment
$$ LANGUAGE PLPYTHON3U;
SELECT AccPayment, Allowance, get_minimal_spendings_py(AccPayment, Allowance) FROM sch.Scholarship;

-- 2) Пользовательскую агрегатную функцию CLR
-- Функция умножения всех чисел в столбце

-- функция состояния
--Имя функции перехода состояния, вызываемой для каждой входной строки.
--Для обычных агрегатных функций с N аргументами, функция_состояния должна принимать N+1 аргумент, первый должен иметь тип тип_данных_состояния, 
--а остальные — типы соответствующих входных данных. Возвращать она должна значение типа тип_данных_состояния.
-- Эта функция принимает текущее значение состояния и текущие значения входных данных, и возвращает следующее значение состояния.

-- initcond
--Начальное значение переменной состояния. 
--Оно должно задаваться строковой константой в форме, пригодной для ввода в тип_данных_состояния. Если не указано, начальным значением состояния будет NULL.
create or replace function mul(state int, arg int)
returns int
as $$
    return state * arg
$$ language plpython3u;

CREATE AGGREGATE my_agr(int)
(
    sfunc = mul,
    stype = int,
    initcond = 1
);

select test_for_rec.* from test_for_rec

-- 3) Определяемая пользователем табличная функция PL/Python.
-- Возвращает все вузи которые находятся в городе City. 
CREATE OR REPLACE FUNCTION find_uni_py(City VARCHAR)
RETURNS TABLE (
    City VARCHAR,
    UniversityID INT
) AS $$
    query = f"SELECT '{City}' ct, u.UniversityID uid FROM sch.University u WHERE u.City = '{City}';"
    result = plpy.execute(query)
    for x in result:
        yield(x["ct"], x["uid"])
$$ LANGUAGE PLPYTHON3U;
SELECT * FROM find_uni_py('Belgrade');

-- 4) Хранимая процедура PL/Python.
create or replace function update_var_p (t_name text, p_var char, p_new_var char) returns void
as $$
    plpy.execute("update " + t_name + " set var1 = \'" + str(p_new_var) + "\' where var1 = \'" +  str(p_var) + "\'")
$$ language plpython3u; 

select * from update_var_p('t1', 'B', 'A');
select *
from t1

--5) Триггер CLR
drop table act_tab;

create table act_tab(
    id int,
    act text
);

create or replace function tr_before() returns trigger
as $$
    if TD["event"] == "DELETE":
        old_id = str(TD["old"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + old_id + ", \'delete\')")
        return "OK"
        
    elif TD["event"] == "INSERT":
        new_id = str(TD["new"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + new_id + ", \'insert\')")
        return "OK"
        
    elif TD["event"] == "update":
        new_id = str(TD["new"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + new_id + ", \'update\')")
        return "OK" 
        
    
$$ language plpython3u;

-- create trigger trig_b before delete or update or insert on test_for_rec
-- for each row execute procedure tr_before();

insert into test_for_rec(id, name) values (6, 'D');

select * from act_tab

-- 6)Определяемый пользователем тип данных 
CREATE TYPE complex_new AS (
    r       double precision,
    i       double precision
);

create or replace function set_complex_new(r double precision , i double precision )
returns setof complex_new
as $$
    return ([r, i],)
$$ language plpython3u;

select * from set_complex_new(3, 5);

-- Вспомогательная таблица
create table test_for_rec 
(
    id int,
    name text
);

insert into test_for_rec  (id, name) values (1, 'A');
insert into test_for_rec  (id, name) values (2, 'B');
insert into test_for_rec  (id, name) values (3, 'c');
insert into test_for_rec  (id, name) values (4, 'D');
insert into test_for_rec  (id, name) values (5, 'A');
insert into test_for_rec  (id, name) values (6, 'B');
insert into test_for_rec  (id, name) values (7, 'c');
insert into test_for_rec  (id, name) values (8, 'D');