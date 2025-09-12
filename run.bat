@echo off
set CONTAINER_NAME=ansible
set INVENTORY=inventory/hosts/hosts.yml
set ACTION_PLAYBOOK=roles/github-actions-runner/tasks/main.yml
set DOCKER_PLAYBOOK=roles/docker/tasks/main.yml

docker exec -it %CONTAINER_NAME% sh -c "ansible-playbook -i %INVENTORY% -b %DOCKER_PLAYBOOK%"
@REM docker exec -it %CONTAINER_NAME% sh -c "ansible-playbook -i %INVENTORY% -b %ACTION_PLAYBOOK%"
