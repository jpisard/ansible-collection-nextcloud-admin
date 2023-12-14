#!/bin/bash
apt-get update
apt-get -y install vim iputils-ping python3-venv curl wget git python3-setuptools python3-dev build-essential

# install venv ansible
python3 -m venv /opt/ansible
/opt/ansible/bin/pip install ansible
/opt/ansible/bin/pip install netaddr

cd /root
mkdir ansible-nextcloud && cd ansible-nextcloud && git clone https://github.com/jpisard/ansible-collection-nextcloud-admin.git
mv ansible-collection-nextcloud-admin/requirements.yml ./ && mv ansible-collection-nextcloud-admin/roles ./
/opt/ansible/bin/ansible-galaxy collection install -r /root/ansible-nextcloud/requirements.yml
/opt/ansible/bin/ansible-galaxy role install -r /root/ansible-nextcloud/requirements.yml

cat <<EOL > /root/ansible-nextcloud/reverseproxy.yml
- hosts: localhost
  roles:
    - role: install_nextcloud
      nextcloud_install_db: false
      nextcloud_install_redis_server: false
      nextcloud_install_websrv: false
      nextcloud_install_reverseproxy: true
      nextcloud_reverseproxy: "nginx"
      nextcloud_trusted_domain:
        - "nextcloud.domaine.ext"
      nextcloud_websrv_address: "x.x.x.x"
      nextcloud_tls_cert_method: "self-signed" #installed
      #nextcloud_tls_cert: "/path/to/cert/files.pem"
      #nextcloud_tls_cert_key: "/path/to/cert/files.pem"
EOL

/opt/ansible/bin/ansible-playbook /root/ansible-nextcloud/reverseproxy.yml
