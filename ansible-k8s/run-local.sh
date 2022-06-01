ansible-playbook -u ${1:-default-user} -i hosts site.yml ${@:2}
