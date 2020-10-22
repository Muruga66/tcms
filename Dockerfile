ADD file:538afc0c5c964ce0dde0141953a4dcf03c2d993c5989c92e7fee418e9305e2a3 in /
LABEL org.label-schema.schema-version=1.0 org.label-schema.name=CentOS Base Image org.label-schema.vendor=CentOS org.label-schema.license=GPLv2 org.label-schema.build-date=20200809
CMD ["/bin/bash"]
  /bin/sh -c dnf -y --setopt=tsflags=nodocs install python3 mariadb mariadb-connector-c postgresql     httpd python3-mod_wsgi mod_ssl sscg &&     dnf -y --setopt=tsflags=nodocs -y update &&     dnf clean all

EXPOSE 8080
EXPOSE 8443

COPY file:ca0390cf5bcd1cd6780121330bcc6bfa8e1e3fa0ce17aa711bcd4b61ffa06596 in /httpd-foreground
CMD ["/bin/sh" "-c" "/httpd-foreground"]

 /bin/sh -c sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf &&     sed -i 's/Listen 443/Listen 8443/' /etc/httpd/conf.d/ssl.conf &&     sed -i 's!ErrorLog "logs/error_log"!ErrorLog "/dev/stderr"!' /etc/httpd/conf/httpd.conf &&     sed -i 's!CustomLog "logs/access_log"!CustomLog "/dev/stdout"!' /etc/httpd/conf/httpd.conf &&     sed -i 's!ErrorLog logs/ssl_error_log!ErrorLog "/dev/stderr"!' /etc/httpd/conf.d/ssl.conf &&     sed -i 's!TransferLog logs/ssl_access_log!TransferLog "/dev/stdout"!' /etc/httpd/conf.d/ssl.conf &&     sed -i 's!CustomLog logs/ssl_request_log!CustomLog "/dev/stdout"!' /etc/httpd/conf.d/ssl.conf &&     chmod -R a+rwx /run/httpd
 
COPY file:2356db97447d54ff50910d33280a984d672e597508faceaf268ea11488268405 in /etc/httpd/conf.d/
ENV PATH=/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin     VIRTUAL_ENV /venv
COPY dir:b036bdb30c8d038ad1c46c24a15b5a7030a97cb7c58005edf206342ff3621e55 in /venv
COPY file:d7ba59f8b46c6b36c38b068487209bc765823aa0d125f14c2c56c1de0ab28378 in /Kiwi/ 
/bin/sh -c mkdir /Kiwi/ssl /Kiwi/static /Kiwi/uploads
/bin/sh -c /usr/bin/sscg -v -f     --country BG --locality Sofia     --organization "Kiwi TCMS"     --organizational-unit "Quality Engineering"     --ca-file       /Kiwi/static/ca.crt         --cert-file     /Kiwi/ssl/localhost.crt     --cert-key-file /Kiwi/ssl/localhost.key
/bin/sh -c sed -i "s/tcms.settings.devel/tcms.settings.product/" /Kiwi/manage.py &&     ln -s /Kiwi/ssl/localhost.crt /etc/pki/tls/certs/localhost.crt &&     ln -s /Kiwi/ssl/localhost.key /etc/pki/tls/private/localhost.key
/bin/sh -c /Kiwi/manage.py collectstatic --noinput --link
/bin/sh -c chown -R 1001 /Kiwi/ /venv/
USER 1001