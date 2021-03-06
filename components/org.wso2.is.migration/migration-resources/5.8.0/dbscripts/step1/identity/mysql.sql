ALTER TABLE IDN_SAML2_ASSERTION_STORE ADD COLUMN ASSERTION BLOB;

ALTER TABLE IDN_OAUTH_CONSUMER_APPS MODIFY CALLBACK_URL VARCHAR(2048);

ALTER TABLE IDN_OAUTH1A_REQUEST_TOKEN MODIFY CALLBACK_URL VARCHAR(2048);

ALTER TABLE IDN_OAUTH2_AUTHORIZATION_CODE MODIFY CALLBACK_URL VARCHAR(2048);

DROP PROCEDURE IF EXISTS add_column_if_not_exists_with_default_val;

CREATE PROCEDURE add_column_if_not_exists_with_default_val(tbl_name VARCHAR(64), clmn_name VARCHAR(64),
                                                            data_type VARCHAR(64), default_val VARCHAR(64))
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN
    END;
    SET @query = CONCAT('ALTER TABLE ', tbl_name, ' ADD COLUMN ', clmn_name, ' ', data_type, ' NOT NULL default ',
                        default_val);
    PREPARE statement FROM @query; EXECUTE statement;
END;

CALL add_column_if_not_exists_with_default_val('IDN_OAUTH2_AUTHORIZATION_CODE', 'IDP_ID', 'int', '-1');

CALL add_column_if_not_exists_with_default_val('IDN_OAUTH2_ACCESS_TOKEN', 'IDP_ID', 'INT', '-1');

CALL add_column_if_not_exists_with_default_val('IDN_OAUTH2_ACCESS_TOKEN_AUDIT', 'IDP_ID', 'INT', '-1');

DROP PROCEDURE IF EXISTS add_column_if_not_exists_with_default_val;

ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN DROP INDEX CON_APP_KEY;

ALTER TABLE IDN_OAUTH2_ACCESS_TOKEN ADD CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,TOKEN_STATE,TOKEN_STATE_ID,IDP_ID);

CREATE TABLE IF NOT EXISTS IDN_AUTH_USER (
	USER_ID VARCHAR(255) NOT NULL,
	USER_NAME VARCHAR(255) NOT NULL,
	TENANT_ID INTEGER NOT NULL,
	DOMAIN_NAME VARCHAR(255) NOT NULL,
	IDP_ID INTEGER NOT NULL,
	PRIMARY KEY (USER_ID),
	CONSTRAINT USER_STORE_CONSTRAINT UNIQUE (USER_NAME, TENANT_ID, DOMAIN_NAME, IDP_ID));

CREATE TABLE IF NOT EXISTS IDN_AUTH_USER_SESSION_MAPPING (
	USER_ID VARCHAR(255) NOT NULL,
	SESSION_ID VARCHAR(255) NOT NULL,
	CONSTRAINT USER_SESSION_STORE_CONSTRAINT UNIQUE (USER_ID, SESSION_ID));

DROP PROCEDURE IF EXISTS handle_partly_index;

CREATE PROCEDURE handle_partly_index() BEGIN DECLARE indexColumnCount BIGINT; DECLARE subPartValue BIGINT; SELECT SUB_PART INTO subPartValue FROM information_schema.statistics WHERE TABLE_SCHEMA = DATABASE() and table_name = 'IDN_SCIM_GROUP' AND index_name = 'IDX_IDN_SCIM_GROUP_TI_RN_AN' AND COLUMN_NAME = 'ATTR_NAME'; SELECT COUNT(*) AS index_exists INTO indexColumnCount FROM information_schema.statistics WHERE TABLE_SCHEMA = DATABASE() and table_name = 'IDN_SCIM_GROUP' AND index_name = 'IDX_IDN_SCIM_GROUP_TI_RN_AN' AND COLUMN_NAME = 'ATTR_NAME'; IF (subPartValue IS NULL) THEN START TRANSACTION; IF (indexColumnCount > 0) THEN SET @dropQuery = CONCAT('DROP INDEX ', 'IDX_IDN_SCIM_GROUP_TI_RN_AN', ' ON ', 'IDN_SCIM_GROUP'); PREPARE dropStatement FROM @dropQuery; EXECUTE dropStatement; END IF; SET @createQuery = CONCAT('CREATE INDEX ', 'IDX_IDN_SCIM_GROUP_TI_RN_AN', ' ON ', 'IDN_SCIM_GROUP', '(TENANT_ID, ROLE_NAME, ATTR_NAME(500))'); PREPARE createStatement FROM @createQuery; EXECUTE createStatement; COMMIT; END IF; END;

call handle_partly_index();

DROP PROCEDURE IF EXISTS handle_partly_index;

DROP PROCEDURE IF EXISTS skip_index_if_exists;

CREATE PROCEDURE skip_index_if_exists(indexName varchar(64), tableName varchar(64), tableColumns varchar(255)) BEGIN BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END; SET @s = CONCAT('CREATE INDEX ', indexName, ' ON ', tableName, tableColumns); PREPARE stmt FROM @s; EXECUTE stmt; END;END;

CALL skip_index_if_exists('IDX_USER_ID', 'IDN_AUTH_USER_SESSION_MAPPING', '(USER_ID)');

CALL skip_index_if_exists('IDX_SESSION_ID', 'IDN_AUTH_USER_SESSION_MAPPING', '(SESSION_ID)');

CALL skip_index_if_exists('IDX_OCA_UM_TID_UD_APN','IDN_OAUTH_CONSUMER_APPS','(USERNAME,TENANT_ID,USER_DOMAIN, APP_NAME)');

CALL skip_index_if_exists('IDX_SPI_APP','SP_INBOUND_AUTH','(APP_ID)');

CALL skip_index_if_exists('IDX_IOP_TID_CK','IDN_OIDC_PROPERTY','(TENANT_ID,CONSUMER_KEY)');

-- IDN_OAUTH2_ACCESS_TOKEN --

CALL skip_index_if_exists('IDX_AT_AU_TID_UD_TS_CKID','IDN_OAUTH2_ACCESS_TOKEN','(AUTHZ_USER, TENANT_ID, USER_DOMAIN, TOKEN_STATE, CONSUMER_KEY_ID)');

CALL skip_index_if_exists('IDX_AT_AT','IDN_OAUTH2_ACCESS_TOKEN','(ACCESS_TOKEN(191))');

CALL skip_index_if_exists('IDX_AT_AU_CKID_TS_UT','IDN_OAUTH2_ACCESS_TOKEN','(AUTHZ_USER, CONSUMER_KEY_ID, TOKEN_STATE, USER_TYPE)');

CALL skip_index_if_exists('IDX_AT_RTH','IDN_OAUTH2_ACCESS_TOKEN','(REFRESH_TOKEN_HASH)');

CALL skip_index_if_exists('IDX_AT_RT','IDN_OAUTH2_ACCESS_TOKEN','(REFRESH_TOKEN(191))');

-- IDN_OAUTH2_AUTHORIZATION_CODE --

CALL skip_index_if_exists('IDX_AC_CKID','IDN_OAUTH2_AUTHORIZATION_CODE','(CONSUMER_KEY_ID)');

CALL skip_index_if_exists('IDX_AC_TID','IDN_OAUTH2_AUTHORIZATION_CODE','(TOKEN_ID)');

CALL skip_index_if_exists('IDX_AC_AC_CKID','IDN_OAUTH2_AUTHORIZATION_CODE','(AUTHORIZATION_CODE(191), CONSUMER_KEY_ID)');

-- IDN_OAUTH2_SCOPE --

CALL skip_index_if_exists('IDX_SC_TID','IDN_OAUTH2_SCOPE','(TENANT_ID)');

CALL skip_index_if_exists('IDX_SC_N_TID','IDN_OAUTH2_SCOPE','(NAME, TENANT_ID)');

-- IDN_OAUTH2_SCOPE_BINDING --

CALL skip_index_if_exists('IDX_SB_SCPID','IDN_OAUTH2_SCOPE_BINDING','(SCOPE_ID)');

-- IDN_OIDC_REQ_OBJECT_REFERENCE --

CALL skip_index_if_exists('IDX_OROR_TID','IDN_OIDC_REQ_OBJECT_REFERENCE','(TOKEN_ID)');

-- IDN_OAUTH2_ACCESS_TOKEN_SCOPE --

CALL skip_index_if_exists('IDX_ATS_TID','IDN_OAUTH2_ACCESS_TOKEN_SCOPE','(TOKEN_ID)');

-- IDN_AUTH_USER --

CALL skip_index_if_exists('IDX_AUTH_USER_UN_TID_DN','IDN_AUTH_USER ','(USER_NAME, TENANT_ID, DOMAIN_NAME)');

CALL skip_index_if_exists('IDX_AUTH_USER_DN_TOD','IDN_AUTH_USER ','(DOMAIN_NAME, TENANT_ID)');

DROP PROCEDURE IF EXISTS skip_index_if_exists;
