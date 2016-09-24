FROM centos:6.8
RUN yum update -y \
&& yum install -y mysql mysql-connector-odbc mysql-devel mysql-server apr-util-mysql wget
RUN wget https://github.com/mikbill/distr/raw/master/mysql/start.sh \
&& chmod +x start.sh
CMD ./start.sh

LABEL version="0.1" \
      name="Mikbill-mysql image"