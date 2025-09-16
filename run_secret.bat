@echo off

set CONTAINER_NAME=ansible
set INVENTORY=inventory/hosts
set PLAYBOOK=playbook.yml
set SECRET_TAGS=secret

docker exec -it ansible sh -c "ansible-playbook -i "%INVENTORY%" "%PLAYBOOK%" --tags %SECRET_TAGS%"


