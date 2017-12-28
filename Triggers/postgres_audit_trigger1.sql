CREATE TABLE audit_log (
	username text, --who did the change
	event_time_utc timestamp, --when the event was recorded
	table_name text, --contains schema-qualified table-name
	operation text, --INSERT, UPDATE, DELETE, TRUNCATE
	before_value json, -- the OLD tuple value
	after_value json -- the NEW tuple value
	);

CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER AS $$
DECLARE
	old_row json := NULL;
	new_row json := NULL;
BEGIN

	IF TG_OP IN ('UPDATE', 'DELETE') THEN
		old_row = row_to_json(OLD);
	END IF;
	IF TG_OP IN ('INSERT', 'UPDATE') THEN
		new_row = row_to_json(NEW);
	END IF;

	INSERT INTO audit_log(username, event_time_utc, table_name, operation, before_value, after_value)
	VALUES(session_user, current_timestamp AT TIME ZONE 'UTC', TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME, TG_OP, old_row, new_row);

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_log
AFTER INSERT OR UPDATE OR DELETE
ON notify_test
FOR EACH ROW
EXECUTE PROCEDURE audit_trigger();

--drop previous triggers on notify_test
DROP TRIGGER notify_insert_trigger ON notify_test;
DROP TRIGGER notify_update_trigger ON notify_test;
DROP TRIGGER notify_delete_trigger ON notify_test;
--truncate notify_test
TRUNCATE notify_test;

INSERT INTO notify_test VALUES(1);
UPDATE notify_test SET i = 2;
DELETE FROM notify_test;
SELECT * FROM audit_log;