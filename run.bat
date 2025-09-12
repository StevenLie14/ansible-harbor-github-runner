@echo off
set CONTAINER_NAME=ansible
set INVENTORY=github-actions-runner/hosts/hosts.yml
set PLAYBOOK=github-actions-runner/tasks/main.yml

docker exec -it %CONTAINER_NAME% sh -c "ansible-playbook -i %INVENTORY% -b %PLAYBOOK%"
