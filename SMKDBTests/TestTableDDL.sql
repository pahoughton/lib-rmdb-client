DROP TABLE test;

CREATE TABLE test (
  test_id       	int NOT NULL AUTO_INCREMENT,
  test_vchar    	varchar(255) DEFAULT NULL,
  test_date 		datetime DEFAULT NULL,
  test_timestamp 	timestamp NULL DEFAULT NULL,
  test_xres			int,
  test_yres			int,
  test_blob 		blob,
  PRIMARY KEY (`test_id`)
  ;
