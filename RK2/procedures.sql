--3 задание 
--Создать хранимую процедуру, которая не уничтожая базу данных уничтожает все те таблицы текущей базы данных в схеме 'dbo' (в psql - public),
-- имена которых начинаются с фразы 'TableName'. вар3

drop procedure del();

create procedure del()
AS $$
	declare
		row record;
		cur cursor
		for select table_name from information_schema.tables
		where table_schema = 'public' and table_name like 'tablename%';

	begin
		open cur;
		loop
			fetch cur into row;
			exit when not found;
			raise notice '%', row.table_name;
			execute 'drop table ' || row.table_name ;
		end loop;
		close cur;
	end;
$$ language plpgsql;

call del();

-- Создать хранимую процедуру с двумя входными параметрами – имя базы
-- данных и имя таблицы, которая выводит сведения об индексах указанной
-- таблицы в указанной базе данных. Созданную хранимую процедуру
-- протестировать. вар2
CREATE OR REPLACE PROCEDURE get_indexes_info(tblname VARCHAR)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT pind.indexname, pind.indexdef FROM pg_indexes pind 
        WHERE pind.schemaname = 'public' AND pind.tablename = tblname
        ORDER BY pind.indexname;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        RAISE NOTICE 'TABLE: %, INDEX: %s, DEFINITION: %', tblname, rec.indexname, rec.indexdef;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE PLPGSQL;
CALL get_indexes_info('executors');
CALL get_indexes_info('customers');
CALL get_indexes_info('activities');


-- вар 1
CREATE OR REPLACE PROCEDURE DeleteTriggers IS
    ttype VARCHAR2(128);
    ttname VARCHAR2(128);
    count_ INTEGER;
BEGIN
    count_ := 0;
    DBMS_OUTPUT.enable(1000000);
    FOR trigger IN (
        SELECT trigger_name, trigger_type
        FROM all_triggers
    ) LOOP
        ttype := trigger.trigger_type;
        ttname := trigger.trigger_name;
        IF ttype = 'CREATE' OR ttype = 'ALTER' OR ttype = 'DROP' THEN
            EXECUTE IMMEDIATE 'DROP TRIGGER $ttname';
            count_ := count_ + 1;
        END IF;
    END LOOP;
    DBMS_OUTPUT.put_line(count_);
END;
/

BEGIN
    DeleteTriggers();
END;

-- 3 задание 4вар
CREATE OR REPLACE PROCEDURE delete_not_encode()
AS $$
BEGIN
	SELECT viewname AS name_temp FROM pg_catalog.pg_views 
	WHERE schemaname='public'
	INSERT INTO temp_table
	

END;
$$
Language PLpgSql