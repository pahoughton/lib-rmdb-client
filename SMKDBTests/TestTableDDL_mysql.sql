
CREATE TABLE test (
  test_id       	int NOT NULL AUTO_INCREMENT,
  test_vchar    	varchar(255) DEFAULT NULL,
  test_date 		datetime DEFAULT NULL,
  test_timestamp 	timestamp NULL DEFAULT NULL,
  test_xres		int NULL,
  test_yres		int NULL,
  test_blob 		blob NULL,
  PRIMARY KEY (`test_id`)
  ;
