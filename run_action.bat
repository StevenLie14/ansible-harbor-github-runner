@echo off

set CONTAINER_NAME=ansible
set INVENTORY=inventory/hosts
set PLAYBOOK=playbook.yml
set ACTION_TAGS=runner

docker exec -it ansible sh -c "ansible-playbook -i "%INVENTORY%" "%PLAYBOOK%" --tags %ACTION_TAGS%"


