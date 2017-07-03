#!/bin/sh

ls /opt/zimbra/installed-by-docker || (
mkdir /opt/zimbra
chown zimbra. /opt/zimbra
cp -a -r --sparse=always /opt/.zimbra/{.*,*} /opt/zimbra/ && rm -rf /opt/.zimbra
sed -i "s/XHOSTNAMEX/`hostname -f`/" /tmp/zcs/config.defaults
sed -i "s/XPASSWORDX/`date | sha1sum | cut -c-8`/" /tmp/zcs/config.defaults
sed -i "s/XPASSWORD2X/`date | sha1sum | cut -c-8`/" /tmp/zcs/config.defaults
sed -i "s/XRANDOMX/`date | sha1sum | cut -c-8`/" /tmp/zcs/config.defaults
sed -i "s/XRANDOM2X/`date | sha1sum | cut -c-8`/" /tmp/zcs/config.defaults
sed -i "s/XRANDOM3X/`date | sha1sum | cut -c-8`/" /tmp/zcs/config.defaults
cp /tmp/zcs/config.defaults /opt/zimbra/config.install
mv /opt/zimbra/.install_history{,.orig}
/opt/zimbra/libexec/zmsetup.pl -d -c /opt/zimbra/config.install
touch /opt/zimbra/installed-by-docker
)

echo 'create user1'
/opt/zimbra/bin/zmprov ca user1@`hostname -f` password
echo 'create user2'
/opt/zimbra/bin/zmprov ca user2@`hostname -f` password

#exec /usr/sbin/sshd -D -e

#"/opt/zimbra/bin/zmcontrol start" zimbra 
supervisord -c /etc/supervisord.conf
