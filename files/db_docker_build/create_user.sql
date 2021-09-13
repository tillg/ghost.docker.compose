CREATE USER '{{ db_user }}'@'%' IDENTIFIED BY '{{ db_pass }}';
GRANT ALL ON {{ db_database }}.* TO '{{ db_user }}'@'%';
FLUSH PRIVILEGES;