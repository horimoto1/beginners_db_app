-- ロール作成
CREATE ROLE beginners_db_app WITH LOGIN PASSWORD 'beginners_db_app';
ALTER ROLE beginners_db_app WITH Superuser;

-- DB作成
CREATE DATABASE beginners_db_app_development WITH OWNER beginners_db_app;
CREATE DATABASE beginners_db_app_test WITH OWNER beginners_db_app;
