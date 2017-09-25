FROM centos:6

ADD config.defaults /tmp/zcs/config.defaults
ADD utilfunc.sh.patch /tmp/zcs/utilfunc.sh.patch
ADD start.sh /start.sh
ADD supervisord.conf /etc/supervisord.conf

RUN yum -y install perl sysstat nc libaio python-setuptools wget patch sudo bind  && \
	useradd -mUs /bin/bash -p '$6$iKh435EZ$XF4mLsy9/hQKmeyE8pbSddiR7QfHT0Mo78fb0LYx6FaxCoJimKlUoCxWflrfgACG.dJxH0ZUdULp/5VOXdSFh.' user && \
	easy_install supervisor && mkdir -p /var/log/supervisor && \
	mkdir -p /tmp/zcs && \
	cd /tmp/zcs && wget -O- http://files2.zimbra.com/downloads/8.0.7_GA/zcs-8.0.7_GA_6021.RHEL6_64.20140408123911.tgz | tar xz && chown -R user. /tmp/zcs && \
	cd /tmp/zcs/zcs-* && patch util/utilfunc.sh </tmp/zcs/utilfunc.sh.patch && \
	cd /tmp/zcs/zcs-* && ./install.sh -s --platform-override /tmp/zcs/config.defaults && \
	mv /opt/zimbra /opt/.zimbra && \
	chmod +x /start.sh

VOLUME ["/opt/zimbra"]

EXPOSE 22 25 456 587 110 143 993 995 80 443 8080 8443 7071

CMD ["/start.sh"]
