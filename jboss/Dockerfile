# dockerfile to build image for JBoss EAP 6.4 

# start from
FROM centos 

# file author / maintainer
MAINTAINER "Oleg Vilkovsky" "olegvilkovsky@gmail.com" 

# update OS
RUN yum -y update && \
yum -y install java-1.8.0-openjdk-devel unzip wget && \
yum clean all

# enabling sudo group
# enabling sudo over ssh
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
sed -i 's/.*requiretty$/Defaults !requiretty/' /etc/sudoers

# add a user for the application, with sudo permissions
RUN useradd -m jboss ; echo jboss: | chpasswd ; usermod -a -G wheel jboss

# create workdir
RUN mkdir -p /opt/rh
WORKDIR /opt/rh

# install JBoss EAP 6.4.0
RUN wget https://download.unitedthinkers.com/jboss-eap-6.4/jboss-eap-6.4.0.zip && \
unzip jboss-eap-6.4.0.zip

# set environment
ENV JBOSS_HOME /opt/rh/jboss-eap-6.4

# create JBoss console user
RUN $JBOSS_HOME/bin/add-user.sh admin admin@2016 --silent

# configure JBoss
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> $JBOSS_HOME/bin/standalone.conf

# set permission folder
RUN chown -R jboss:jboss /opt/rh

# JBoss ports
EXPOSE 8080 9990 9999

# start JBoss
ENTRYPOINT $JBOSS_HOME/bin/standalone.sh -c standalone-full-ha.xml

# deploy app

#ADD myapp.war "$JBOSS_HOME/standalone/deployments/"
#RUN sleep 60
USER jboss
CMD /bin/bash
