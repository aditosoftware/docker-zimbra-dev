# Description
This is a dev image for dev testing.

## Ports
25, 456, 587, 110, 143, 993, 995, 80, 443, 8080, 8443, 7071 \
ADMIN Port: 7071

# Contianer start

    sudo docker pull adito/zimbra-dev
    sudo docker run \
    -h zimbra.dev.local \
    --name zimbra-mail \
    -p 2223:22 \
    -p 25:25 \
    -p 456:456 \
    -p 587:587 \
    -p 110:110 \
    -p 143:143 \
    -p 993:993 \
    -p 995:995 \
    -p 80:80 \
    -p 443:443 \
    -p 8080:8080 \
    -p 8443:8443 \
    -p 7071:7071 \
    -t adito/zimbra-dev

# Users

| User          | Password           | Permissions  | Shared Calendar    |
| ------------- |:-------------      |:-------------|:------------------:|
| admin         | $PASSWORD variable |**admin**     |X                   | 
| stduser1      | stdstdstd1         |**admin**     |X                   |
| stduser2      | stdstdstd2         |**admin**     |X                   |
| shareuser1    | useruser1          |user          |V                   |
| shareuser2    | useruser2          |user          |V                   |
| shareuser3    | useruser3          |user          |V                   |
| shareuser4    | useruser4          |user          |V                   |