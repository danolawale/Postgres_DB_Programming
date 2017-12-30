--SELECT CURRENT_TIMESTAMP AS date, EXTRACT(DOW FROM CURRENT_TIMESTAMP) AS DOW;

--Conditional triggers with the WHEN clause
CREATE OR REPLACE FUNCTION cancel_with_message()
RETURNS TRIGGER AS $$
BEGIN
	RAISE EXCEPTION '%', TG_ARGV[0];
	RAISE NOTICE '%', TG_ARGV[1]; --Notice this doesn't get executed because an error or exception is raised
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE new_tasks (id SERIAL PRIMARY KEY, sample TEXT);

CREATE TRIGGER no_changes_on_weekends
BEFORE INSERT OR UPDATE OR DELETE OR TRUNCATE ON new_tasks
FOR EACH STATEMENT
WHEN (CURRENT_TIME > '18:00' OR EXTRACT(DOW FROM CURRENT_TIMESTAMP) > 5) --no changes on weekends or after 6pm
EXECUTE PROCEDURE cancel_with_message('Sorry, we have a "No task change on weekends and after 6pm" policy!', 'Peace');

INSERT INTO new_tasks(sample) values('test2');

DROP TRIGGER no_changes_on_weekends ON new_tasks;

--one thing to note about trigger arguments is that the argument list is always an array of text(text[])
--All of the arguments given in the CREATE TRIGGER statement are converted to strings, and this includes any NULL values
--This means that putting NULL in the argument list results in the text NULL in the corresponding slot in TG_ARGV.
