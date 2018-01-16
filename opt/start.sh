#!/bin/sh
## Preparing all the variables like IP, Hostname, etc, all of them from the container
sleep 5
HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

#fix gpg Server
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 9BE6ED79
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9BE6ED79
gpg -a --export 9BE6ED79 | apt-key add -

## Installing the DNS Server ##
echo "Installing DNS Server"
#sudo apt-get update && sudo sudo apt-get install -y bind9 bind9utils bind9-doc dnsutils
echo "Configuring DNS Server"
sed "s/-u/-4 -u/g" /etc/default/bind9 > /etc/default/bind9.new
mv /etc/default/bind9.new /etc/default/bind9
rm /etc/bind/named.conf.options
cat <<EOF >>/etc/bind/named.conf.options
options {
directory "/var/cache/bind";
listen-on { 127.0.0.1; }; # ns1 private IP address - listen on private network only
allow-transfer { none; }; # disable zone transfers by default
forwarders {
8.8.8.8;
8.8.4.4;
};
auth-nxdomain no; # conform to RFC1035
#listen-on-v6 { any; };
};
# EOF
# cat <<EOF >/etc/resolv.conf
# search $DOMAIN
# nameserver 127.0.0.1
# nameserver 8.8.8.8
# EOF

# cat <<EOF >/etc/hosts
# 127.0.0.1       localhost
# ::1     localhost ip6-localhost ip6-loopback
# fe00::0 ip6-localnet
# ff00::0 ip6-mcastprefix
# ff02::1 ip6-allnodes
# ff02::2 ip6-allrouters
# $CONTAINERIP $HOSTNAME $DOMAIN
# EOF

cat <<EOF >/etc/bind/named.conf.local
zone "$DOMAIN" {
        type master;
        file "/etc/bind/db.$DOMAIN";
};
EOF
touch /etc/bind/db.$DOMAIN
cat <<EOF >/etc/bind/db.$DOMAIN
\$TTL  604800
@      IN      SOA    ns1.$DOMAIN. root.localhost. (
                              2        ; Serial
                        604800        ; Refresh
                          86400        ; Retry
                        2419200        ; Expire
                        604800 )      ; Negative Cache TTL
;
@     IN      NS      ns1.$DOMAIN.
@     IN      A      $CONTAINERIP
@     IN      MX     10     $HOSTNAME.$DOMAIN.
$HOSTNAME     IN      A      $CONTAINERIP
ns1     IN      A      $CONTAINERIP
mail     IN      A      $CONTAINERIP
pop3     IN      A      $CONTAINERIP
imap     IN      A      $CONTAINERIP
imap4     IN      A      $CONTAINERIP
smtp     IN      A      $CONTAINERIP
EOF
sudo service bind9 start

##Creating the Zimbra Collaboration Config File ##
touch /opt/zimbra-install/installZimbraScript
cat <<EOF >/opt/zimbra-install/installZimbraScript
AVDOMAIN="$DOMAIN"
AVUSER="admin@$DOMAIN"
CREATEADMIN="admin@$DOMAIN"
CREATEADMINPASS="$PASSWORD"
CREATEDOMAIN="$DOMAIN"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOSTNAME.$DOMAIN"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPAMAVISPASS="$PASSWORD"
LDAPPOSTPASS="$PASSWORD"
LDAPROOTPASS="$PASSWORD"
LDAPADMINPASS="$PASSWORD"
LDAPREPPASS="$PASSWORD"
LDAPBESSEARCHSET="set"
LDAPDEFAULTSLOADED="1"
LDAPHOST="$HOSTNAME.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="512"
MAILPROXY="TRUE"
MODE="https"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="https"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN"
SMTPHOST="$HOSTNAME.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN"
SPELLURL="http://$HOSTNAME.$DOMAIN:7780/aspell.php"
STARTSERVERS="yes"
SYSTEMMEMORY="3.8"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="yes"
USEKBSHORTCUTS="TRUE"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$PASSWORD"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD"
ldap_url="ldap://$HOSTNAME.$DOMAIN:389"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/jre/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraDNSMasterIP=""
zimbraDNSTCPUpstream="no"
zimbraDNSUseTCP="yes"
zimbraDNSUseUDP="yes"
zimbraDefaultDomainName="$DOMAIN"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMailProxy="FALSE"
zimbraMtaMyNetworks="127.0.0.0/8 $CONTAINERIP/32 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="America/Los_Angeles"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckInterval="1d"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN"
zimbraVersionCheckSendNotifications="TRUE"
zimbraWebProxy="FALSE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbra_server_hostname="$HOSTNAME.$DOMAIN"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy"
#INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy"
EOF
##Install the Zimbra Collaboration ##
echo "Extracting files from the archive"
tar xzvf /opt/zimbra-install/zimbra-zcs-8.7.11.tar.gz -C /opt/zimbra-install/

echo "Installing Zimbra Collaboration just the Software"
cd /opt/zimbra-install/zcs-* && ./install.sh -s < /opt/zimbra-install/installZimbra-keystrokes

echo "Installing Zimbra Collaboration injecting the configuration"
/opt/zimbra/libexec/zmsetup.pl -c /opt/zimbra-install/installZimbraScript

su - zimbra -c 'zmcontrol restart'
echo "You can access now to your Zimbra Collaboration Server"

#User with ca
echo 'create shareuser1'
/opt/zimbra/bin/zmprov ca shareuser1@`hostname -d` useruser1
echo 'create shareuser2'
/opt/zimbra/bin/zmprov ca shareuser2@`hostname -d` useruser2
echo 'create shareuser3'
/opt/zimbra/bin/zmprov ca shareuser3@`hostname -d` useruser3
echo 'create shareuser4'
/opt/zimbra/bin/zmprov ca shareuser4@`hostname -d` useruser4

echo 'create stduser1'
/opt/zimbra/bin/zmprov ca stduser1@`hostname -d` stdstdstd1
echo 'create stduser2'
/opt/zimbra/bin/zmprov ca stduser2@`hostname -d` stdstdstd2

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

echo "READY"

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
