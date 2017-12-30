--Trigger example using hstore;
CREATE TABLE company (
   id SERIAL PRIMARY KEY,
   date_created timestamp WITHOUT TIME ZONE DEFAULT NOW(),
   name VARCHAR(50) NOT NULL
);

CREATE TABLE users_domain (
   id SERIAL PRIMARY KEY,
   date_created timestamp WITHOUT TIME ZONE DEFAULT NOW(),
   company_id integer NOT NULL,
   domain_name VARCHAR(20) NOT NULL,
   FOREIGN KEY (company_id) REFERENCES company(id)
);

CREATE TABLE audit_table_changes (
  id SERIAL PRIMARY KEY,
  date_created timestamp WITHOUT TIME ZONE DEFAULT NOW(),
  changes text
);

CREATE EXTENSION hstore;

CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
DECLARE
	_col text;
	_old_data text;
	_new_data text;
	_company_id integer;
	str text = '';
BEGIN
	IF (TG_TABLE_NAME = 'company') THEN
		RAISE NOTICE 'TRIGGER CALLED  ON %', TG_TABLE_NAME;
		IF (TG_OP IN ('INSERT', 'UPDATE')) THEN
			_company_id = NEW.id;
		ELSE
			_company_id = OLD.id;
		END IF;
	ELSE
		RAISE NOTICE 'TRIGGER CALLED  ON %', TG_TABLE_NAME;
		IF (TG_OP IN ('INSERT', 'UPDATE')) THEN
			_company_id = NEW.company_id;
		ELSE
			_company_id = OLD.company_id;
		END IF;
	END IF;

	IF (TG_OP = 'INSERT') THEN
		INSERT INTO audit_table_changes(changes) VALUES('NEW RECORD ' || NEW.id || ' added to ' || TG_TABLE_NAME || ' table');
		RETURN NEW;
	ELSIF (TG_OP = 'UPDATE') THEN
		FOR _col, _old_data, _new_data IN 
			SELECT key, o.value, n.value FROM
			each(hstore(OLD)) o JOIN each(hstore(NEW)) n USING (key)
			WHERE o.value IS DISTINCT FROM n.value
		LOOP
			IF (_old_data IS NULL) THEN
				_old_data = '';
			END IF;
			IF (_new_data IS NULL) THEN
				_new_data = '';
			END IF;
			str := str || _col ||' has changed from ' ||_old_data || ' to ' ||_new_data || '; ';
		END LOOP;

		IF str <> '' THEN
			str := TG_TABLE_NAME ||': ' || str;
			INSERT INTO audit_table_changes(changes) VALUES(str);
		END IF;
		
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO audit_table_changes(changes) VALUES('RECORD ' || OLD.id || ' removed from ' || TG_TABLE_NAME || ' table');
		RETURN OLD;
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_company_changes
BEFORE INSERT OR UPDATE OR DELETE ON company
FOR EACH ROW
EXECUTE PROCEDURE audit_changes();

CREATE TRIGGER audit_user_domain_changes
BEFORE INSERT OR UPDATE OR DELETE ON users_domain
FOR EACH ROW
EXECUTE PROCEDURE audit_changes();

INSERT INTO company(name) VALUES ('PLS-IT Limited');
INSERT INTO company(name) VALUES ('Hone Your Skills Limited');
UPDATE company SET name = 'PLS-IT Limited' WHERE id = 1
DELETE FROM company WHERE id = 3;

INSERT INTO users_domain(company_id, domain_name) VALUES(1, 'pls-it.com');
UPDATE users_domain SET company_id = 4, domain_name = 'hys.com' WHERE id = 1;

SELECT * FROM company
SELECT * FROM users_domain
SELECT * FROM audit_table_changes



	    
