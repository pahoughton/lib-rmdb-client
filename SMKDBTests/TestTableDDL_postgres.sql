CREATE SEQUENCE test_test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE test (
  test_id 		integer DEFAULT
				nextval('test_test_id_seq'::regclass)
				NOT NULL,
  test_vchar    	character varying(255) DEFAULT NULL,
  test_date 		timestamp with time zone DEFAULT NULL,
  test_timestamp 	timestamp without time zone DEFAULT NULL,
  test_xres		integer,
  test_yres		bigint,
  test_double           double precision,
  test_numeric          numeric(10,4),
  test_blob 		bytea
);

ALTER TABLE ONLY test
    ADD CONSTRAINT test_pkey PRIMARY KEY (test_id);

