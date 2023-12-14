#!/bin/bash
apt-get update
apt-get -y install vim iputils-ping python3-venv curl wget git python3-setuptools python3-dev build-essential

#install venv ansible
python3 -m venv /opt/ansible
/opt/ansible/bin/pip install ansible
/opt/ansible/bin/pip install netaddr
/opt/ansible/bin/pip install PyMySQL

cd /root
mkdir ansible-nextcloud && cd ansible-nextcloud && git clone https://github.com/jpisard/ansible-collection-nextcloud-admin.git
mv ansible-collection-nextcloud-admin/requirements.yml ./ && mv ansible-collection-nextcloud-admin/roles ./
/opt/ansible/bin/ansible-galaxy collection install -r /root/ansible-nextcloud/requirements.yml
/opt/ansible/bin/ansible-galaxy role install -r /root/ansible-nextcloud/requirements.yml

cat <<EOL > /root/ansible-nextcloud/nextcloud_db.yml

- hosts: localhost
  roles:
    - role: install_nextcloud
      nextcloud_install_db: true
      nextcloud_install_redis_server: false
      nextcloud_install_websrv: false
      nextcloud_install_reverseproxy: false
      nextcloud_install_tls: false
      nextcloud_db_pwd: "motdepasseBDD"
      nextcloud_db_backend: "mariadb"
EOL

/opt/ansible/bin/ansible-playbook /root/ansible-nextcloud/nextcloud_db.yml
