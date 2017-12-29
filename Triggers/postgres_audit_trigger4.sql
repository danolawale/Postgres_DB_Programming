--the values of created_by and created_at should be enforced for INSERT
--the values should not change for UPDATES
--The values of last_changed_by and last_changed_at however changes for updates
CREATE OR REPLACE FUNCTION usagestamp()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
	   NEW.created_by = SESSION_USER;
	   NEW.created_at = CURRENT_TIMESTAMP;
	ELSE
	   NEW.created_by = OLD.created_by;
	   NEW.created_at = OLD.created_at;
	END IF;

	NEW.last_changed_by = SESSION_USER;
	NEW.last_changed_at = CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER usagestamp
BEFORE INSERT OR UPDATE ON modify_test
FOR EACH ROW
EXECUTE PROCEDURE usagestamp();

DROP TRIGGER changestamp ON modify_test;

UPDATE modify_test SET created_by = 'notpostgres';

SELECT * FROM modify_test;
--NB: created_by is as set in the trigger function
