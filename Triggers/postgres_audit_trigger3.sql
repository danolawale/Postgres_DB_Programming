CREATE OR REPLACE FUNCTION changestamp()
RETURNS TRIGGER AS $$
BEGIN	
	--These values can be changed as below.
	--Everytime the update occurs, the value of last_changed_by and last_changed_at can be changed as below
	--NEW.last_changed_by := SESSION_USER;
	NEW.last_changed_by := 'CEO PLS IT Limited';
	NEW.last_changed_at := CURRENT_TIMESTAMP;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE modify_test (
   id SERIAL PRIMARY KEY,
   data text,
   created_by text default SESSION_USER,
   created_at timestamp default CURRENT_TIMESTAMP,
   last_changed_by text default SESSION_USER,
   last_changed_at timestamp default CURRENT_TIMESTAMP
   );

   CREATE TRIGGER changestamp
   BEFORE UPDATE ON modify_test
   FOR EACH ROW
   EXECUTE PROCEDURE changestamp();

   DROP TRIGGER changestamp ON modify_test
   INSERT INTO modify_test(data) VALUES('something');
   INSERT INTO modify_test(data) VALUES('Peace');

   -- Notice the last_changed_by and last_changed_At values changes as per the trigger function
   --even without specifically changing these values in the update statement.
   UPDATE modify_test SET data = 'Something Wild' WHERE id = 1;
    UPDATE modify_test SET data = 'Peace Loving' WHERE id = 2;

   SELECT * FROM modify_test
