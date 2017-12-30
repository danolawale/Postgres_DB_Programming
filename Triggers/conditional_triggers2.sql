CREATE OR REPLACE FUNCTION prevent_changes()
RETURNS TRIGGER AS $$
BEGIN
	RAISE EXCEPTION 'NO changes will happen on %', TG_TABLE_NAME;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--Conditional trigger 1 - preventing UPDATE of the id field
CREATE TRIGGER disallow_pk_change
AFTER UPDATE OF id ON new_tasks --check fo updates to id field
FOR EACH ROW
--EXECUTE PROCEDURE disallow_op();
EXECUTE PROCEDURE prevent_changes();

DROP TRIGGER disallow_pk_change ON new_tasks;

--conditional Trigger 2 - checking to see if the id field value is different from existing
CREATE TRIGGER disallow_pk_change2
AFTER UPDATE ON new_tasks
FOR EACH ROW
WHEN(NEW.id IS DISTINCT FROM OLD.id) --condition
EXECUTE PROCEDURE prevent_changes();

SELECT * FROM new_tasks;
TRUNCATE new_tasks;
INSERT INTO new_tasks DEFAULT VALUES; 
UPDATE new_tasks SET id=0 WHERE id = 3; --returns tru in the trigger since 0 <> 3 AND therefore executes the trigger

DROP TRIGGER disallow_pk_change2 ON new_tasks;
