#!/bin/sh

HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

## Installing the DNS Server ##
echo "Configuring DNS Server"
cat <<EOF >/etc/named.conf
zone "$DOMAIN" {
        type master;
        file "/etc/db.$DOMAIN";
};
EOF
touch /etc/db.$DOMAIN
cat <<EOF >/etc/db.$DOMAIN
\$TTL  604800
@      IN      SOA    ns1.$DOMAIN. root.localhost. (
                              2        ; Serial
                        604800        ; Refresh
                          86400        ; Retry
                        2419200        ; Expire
                        604800 )      ; Negative Cache TTL
;
     IN      NS      ns1.$DOMAIN.
     IN      A      $CONTAINERIP
     IN      MX     10     $HOSTNAME.$DOMAIN.
$HOSTNAME     IN      A      $CONTAINERIP
ns1     IN      A      $CONTAINERIP
mail     IN      A      $CONTAINERIP
pop3     IN      A      $CONTAINERIP
imap     IN      A      $CONTAINERIP
imap4     IN      A      $CONTAINERIP
smtp     IN      A      $CONTAINERIP
EOF

# Set DNS Server to localhost
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

service named start

ls /opt/zimbra/installed-by-docker || (
mkdir -p /opt/zimbra
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
/opt/zimbra/bin/zmprov ca shareuser1@`hostname -f` useruser1
echo 'create shareuser2'
/opt/zimbra/bin/zmprov ca shareuser2@`hostname -f` useruser2
echo 'create shareuser3'
/opt/zimbra/bin/zmprov ca shareuser3@`hostname -f` useruser3
echo 'create shareuser4'
/opt/zimbra/bin/zmprov ca shareuser4@`hostname -f` useruser4

echo 'create stduser1'
/opt/zimbra/bin/zmprov ca stduser1@`hostname -f` stdstdstd1
echo 'create stduser2'
/opt/zimbra/bin/zmprov ca stduser2@`hostname -f` stdstdstd2

#set calendar permissions
/opt/zimbra/bin/zmmailbox -z -m shareuser1 modifyFolderGrant /Calendar account shareuser2 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser1 modifyFolderGrant /Calendar account shareuser3 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser1 modifyFolderGrant /Calendar account shareuser4 rwixd

/opt/zimbra/bin/zmmailbox -z -m shareuser2 modifyFolderGrant /Calendar account shareuser1 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser2 modifyFolderGrant /Calendar account shareuser3 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser2 modifyFolderGrant /Calendar account shareuser4 rwixd

/opt/zimbra/bin/zmmailbox -z -m shareuser3 modifyFolderGrant /Calendar account shareuser1 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser3 modifyFolderGrant /Calendar account shareuser2 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser3 modifyFolderGrant /Calendar account shareuser4 rwixd

/opt/zimbra/bin/zmmailbox -z -m shareuser4 modifyFolderGrant /Calendar account shareuser1 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser4 modifyFolderGrant /Calendar account shareuser2 rwixd
/opt/zimbra/bin/zmmailbox -z -m shareuser4 modifyFolderGrant /Calendar account shareuser3 rwixd

supervisord -c /etc/supervisord.conf
