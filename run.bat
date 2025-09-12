@echo off
set CONTAINER_NAME=ansible
set INVENTORY=inventory/hosts/hosts.yml
set PLAYBOOK=roles/github-actions-runner/tasks/main.yml

docker exec -it %CONTAINER_NAME% sh -c "ansible-playbook -i %INVENTORY% -b %PLAYBOOK%"
