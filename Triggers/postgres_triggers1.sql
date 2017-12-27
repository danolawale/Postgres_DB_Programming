--Trigger functions are like regular functions except that they do not take arguments and they return value type trigger
CREATE OR REPLACE FUNCTION notify_trigger()
RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE 'Hi, I got % invoked FOR % % % on %', 
		TG_NAME, TG_LEVEL, TG_WHEN, TG_OP, TG_TABLE_NAME;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE notify_test(i int);

--1 INSERT TRIGGER
CREATE TRIGGER notify_insert_trigger
AFTER INSERT ON notify_test
FOR EACH ROW
EXECUTE PROCEDURE notify_trigger();

INSERT INTO notify_test VALUES(1), (2);

--2 UPDATE TRIGGER
CREATE TRIGGER notify_update_trigger
AFTER UPDATE ON notify_test
FOR EACH ROW
EXECUTE PROCEDURE notify_trigger();

UPDATE notify_test SET i = i/10;

--3 DELETE TRIGGER
CREATE TRIGGER notify_delete_trigger
AFTER DELETE ON notify_test
FOR EACH ROW
EXECUTE PROCEDURE notify_trigger();

DELETE FROM notify_test;

--4 All purpose trigger
CREATE TRIGGER notify_trigger
AFTER INSERT OR UPDATE OR DELETE 
ON notify_test
FOR EACH ROW
EXECUTE PROCEDURE notify_trigger();

DROP TRIGGER notify_insert_trigger ON notify_test;
DROP TRIGGER notify_update_trigger ON notify_test;
DROP TRIGGER notify_delete_trigger ON notify_test;
TRUNCATE notify_test;

--the TRUNCATE command does not act on single rows so the foreach row triggers make no sense for truncate

--5 TRUNCATE trigger
CREATE TRIGGER notify_trigger
AFTER TRUNCATE ON notify_test
FOR EACH STATEMENT
EXECUTE PROCEDURE notify_trigger();

TRUNCATE notify_test;
