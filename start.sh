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

#User with ca
echo 'create shareuser1'
/opt/zimbra/bin/zmprov ca shareuser1@`hostname -f` user1
echo 'create shareuser2'
/opt/zimbra/bin/zmprov ca shareuser2@`hostname -f` user2
echo 'create shareuser3'
/opt/zimbra/bin/zmprov ca shareuser3@`hostname -f` user3
echo 'create shareuser4'
/opt/zimbra/bin/zmprov ca shareuser4@`hostname -f` user4

echo 'create stduser1'
/opt/zimbra/bin/zmprov ca stduser1@`hostname -f` std1
echo 'create stduser2'
/opt/zimbra/bin/zmprov ca stduser2@`hostname -f` std2


supervisord -c /etc/supervisord.conf
