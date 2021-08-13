
CREATE USER '{{ db_user }}'@'%' IDENTIFIED WITH mysql_native_password BY '{{ db_pass }}';
GRANT ALL ON {{ db_database }}.* TO '{{ db_user }}'@'%';
