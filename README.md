# Description
This is a dev image for testing.

## Ports
25, 456, 587, 110, 143, 993, 995, 80, 443, 8080, 8443, 7071
ADMIN Port: 7071

# Contianer start

    sudo docker pull adito/zimbra-dev
    sudo docker run -h zimbra.dev.local -p 2223:22 -p 25:25 -p 456:456 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -p 80:80 -p 443:443 -p 8080:8080 -p 8443:8443 -p 7071:7071 --name mail -t adito/zimbra-dev

# Users
admin:docker
user1:password
user2:password
