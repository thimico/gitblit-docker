# Basico
#
from ubuntu:latest
maintainer Thiago Menezes <thimico@gmail.com>
run apt-get update
run apt-get install -q -y git-core redis-server

# Instalar Java 7

run DEBIAN_FRONTEND=noninteractive apt-get install -q -y software-properties-common
run DEBIAN_FRONTEND=noninteractive apt-get install -q -y python-software-properties
run DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:webupd8team/java -y
run apt-get update
run echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
run DEBIAN_FRONTEND=noninteractive apt-get install oracle-java7-installer -y

# Instalar Gitblit

run apt-get install -q -y curl
run curl -Lks http://dl.bintray.com/gitblit/releases/gitblit-1.6.2.tar.gz -o /root/gitblit.tar.gz
run mkdir -p /opt/gitblit
run tar zxf /root/gitblit.tar.gz -C /opt/gitblit
run rm -f /root/gitblit.tar.gz

# Move arquivos para um diretorio separado
run mkdir -p /opt/gitblit-data
run mv /opt/gitblit/data/* /opt/gitblit-data
run mv /opt/gitblit-data/gitblit.properties /opt/gitblit-data/default.properties

# Ajusta configuracao padrao do Gitblit para 80, 443, 9418, 29418, e permite administracao via RPC.
#
# Note: we are writing to a different file here because sed doesn't like to the same file it
# is streaming.  This is why the original properties file was renamed earlier.
run sed -e "s/server\.httpsPort\s=\s8443/server\.httpsPort=443/" \
        -e "s/server\.httpPort\s=\s0/server\.httpPort=80/" \
        -e "s/server\.redirectToHttpsPort\s=\sfalse/server\.redirectToHttpsPort=true/" \
        -e "s/web\.enableRpcManagement\s=\sfalse/web\.enableRpcManagement=true/" \
        -e "s/web\.enableRpcAdministration\s=\sfalse/web.enableRpcAdministration=true/" \
        /opt/gitblit-data/default.properties > /opt/gitblit-data/gitblit.properties

# Configura o container Docker e roda o Gitblit
workdir /opt/gitblit
expose 80
expose 443
expose 9418
expose 29418
cmd ["java", "-server", "-Xmx1024M", "-Djava.awt.headless=true", "-jar", "/opt/gitblit/gitblit.jar", "--baseFolder", "/opt/gitblit-data"]
