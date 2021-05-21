FROM centos:8 as mybuild
ENV java_version=16.0.1
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
#ENV JAVA_HOME=/usr/local/java/openjdk-${java_version}
ENV JAVA="${JAVA_HOME}/bin"
#ENV PATH=$PATH:$JAVA
#Installing java
RUN yum install wget -y \
    && yum install git -y \
    && yum install java-1.8.0-openjdk-devel wget -y
   # && wget https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-${java_version}_linux-x64_bin.tar.gz \
   # && tar xvfz openjdk-${java_version}_linux-x64_bin.tar.gz \
   # && mkdir /usr/local/java/openjdk-${java_version} -p \
   # && mv jdk-${java_version}/* /usr/local/java/openjdk-${java_version}/ \
   # && yum clean all \
   # && rm -rf openjdk-${java_version}_linux-x64_bin.tar.gz \
   # && rm -rf jdk-${java_version}
###Installing maven
ENV maven_version=3.8.1
ENV M2_HOME=/usr/local/apache-maven-${maven_version}
ENV M2="${M2_HOME}/bin"
ENV PATH=$PATH:$JAVA:$M2
RUN wget https://downloads.apache.org/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz -P /tmp \
    && tar xvfz /tmp/apache-maven-${maven_version}-bin.tar.gz -C /usr/local \
    && rm -rf /opt/local \
    && git clone https://github.com/lekhrajprasad/mybookstore-v-1.2.git /opt/local \
    && cd /opt/local/ \
    && git checkout mybookstore-dev-v1.2 \
    && rm -rf /tmp/apache-maven-${maven_version}-bin.tar.gz \
    && yum clean all
#RUN cd /opt/local/ \
 #   && git checkout mybookstore-dev-v1.2
WORKDIR /opt/local/my-bookstore-web/
#RUN mvn clean install -DskipTests
RUN mvn clean install
## 2nd stage docker fie
# Installing and configuring tomcat
FROM centos:8
EXPOSE 5000
ENV tomcat_version=9.0.46
ENV java_version=16.0.1
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
#ENV JAVA_HOME=/usr/local/java/openjdk-${java_version}
ENV JAVA="${JAVA_HOME}/bin"
ENV PATH=$PATH:$JAVA
RUN yum install wget -y \
    && yum install java-1.8.0-openjdk-devel wget -y \
#    && wget https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL/openjdk-${java_version}_linux-x64_bin.tar.gz \
 #   && tar xvfz openjdk-${java_version}_linux-x64_bin.tar.gz \
  #  && mkdir /usr/local/java/openjdk-${java_version} -p \
   # && mv jdk-${java_version}/* /usr/local/java/openjdk-${java_version}/ \
   # && rm -rf openjdk-${java_version}_linux-x64_bin.tar.gz \
   # && rm -rf jdk-${java_version} \
    && wget https://mirrors.estointernet.in/apache/tomcat/tomcat-9/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz -P /tmp \
    && tar xvfz /tmp/apache-tomcat-${tomcat_version}.tar.gz -C /opt/ \
    && rm -rf /tmp/apache-tomcat-9*.tar.gz \
    && yum clean all
ADD server.xml /opt/apache-tomcat-${tomcat_version}/conf/
ADD tomcat-users.xml /opt/apache-tomcat-${tomcat_version}/conf/
COPY --from=mybuild /opt/local/my-bookstore-web/target/my-bookstore-web-v12.war /opt/apache-tomcat-${tomcat_version}/webapps/myapp.war
CMD ["/opt/apache-tomcat-9.0.46/bin/catalina.sh","run"]
