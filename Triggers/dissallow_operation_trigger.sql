--DISALLOWING OPERATION e.g DELETE
--This trigger function can be used for BEFORE AND AFTER triggers
--If used as a BEFORE trigger, the operation is skipped with a message
--If used as a AFTER trigger, an error trigger is raised and the current sub(transaction ) is rolled back
CREATE OR REPLACE FUNCTION disallow_op()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_WHEN = 'AFTER' THEN
		RAISE EXCEPTION 'YOU ARE NOT ALLOWED TO % ROWS IN %.%',
		TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME;
	END IF;

	RAISE NOTICE '% ON ROWS IN %.% WON''T HAPPEN',
		TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE delete_test1(i int);

INSERT INTO delete_test1 VALUES (1);

CREATE TRIGGER disallow_delete 
AFTER DELETE ON delete_test1
FOR EACH ROW
EXECUTE PROCEDURE disallow_op();

DELETE FROM delete_test1 WHERE i = 1;

CREATE TRIGGER disallow_truncate
AFTER TRUNCATE ON delete_test1
FOR EACH STATEMENT
EXECUTE PROCEDURE disallow_op();

TRUNCATE delete_test1;
