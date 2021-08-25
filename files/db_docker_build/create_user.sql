/*
CREATE USER '{{ db_user }}'@'%' IDENTIFIED WITH mysql_native_password BY '{{ db_pass }}';
GRANT ALL ON {{ db_database }}.* TO '{{ db_user }}'@'%';
*/

CREATE USER '{{ db_user }}'@'%' IDENTIFIED BY '{{ db_pass }}';
GRANT ALL ON {{ db_database }}.* TO '{{ db_user }}'@'%';

/* Due to a mysql problem we need this https://bugs.mysql.com/bug.php?id=91432 
CREATE USER 'mysql.infoschema'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON *.* TO `mysql.infoschema`@`localhost`;
*/

FLUSH PRIVILEGES;