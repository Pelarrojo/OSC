FROM almalinux:8 
RUN yum -y update && \ 
yum -y install httpd && \ 
yum clean all 
COPY ./index.html/ /var/www/html/ 
EXPOSE 80 
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]