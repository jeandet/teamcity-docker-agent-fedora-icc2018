FROM fedora:26
#Derived from official TeamCity image
LABEL modified "Alexis Jeandet <alexis.jeandet@member.fsf.org>"

RUN dnf clean all
RUN dnf update -y
RUN dnf install -y java-1.8.0-openjdk mercurial git tar gzip unzip xorg-x11-server-Xvfb

VOLUME /data/teamcity_agent/conf
ENV CONFIG_FILE=/data/teamcity_agent/conf/buildAgent.properties \
    TEAMCITY_AGENT_DIST=/opt/buildagent

RUN mkdir $TEAMCITY_AGENT_DIST

ADD https://teamcity.jetbrains.com/update/buildAgent.zip $TEAMCITY_AGENT_DIST/
RUN unzip $TEAMCITY_AGENT_DIST/buildAgent.zip -d $TEAMCITY_AGENT_DIST/

LABEL dockerImage.teamcity.version="latest" \
      dockerImage.teamcity.buildNumber="latest"

COPY run-agent.sh /run-agent.sh
COPY run-services.sh /run-services.sh

RUN useradd -m buildagent && \
    chmod +x /run-agent.sh /run-services.sh && \
    rm $TEAMCITY_AGENT_DIST/buildAgent.zip && \
    sync


RUN dnf install -y findutils
RUN dnf install -y cppcheck luabind-devel tcl-devel tk-devel lua-devel python2-devel clang-devel ncurses-devel llvm-static clang-analyzer lcov 
RUN dnf install -y git ninja-build ncurses-devel cups-devel zlib-static zlib-devel itstool libpcap-devel SDL2-devel wget redhat-rpm-config  gettext unzip doxygen
RUN dnf install -y gcc-objc++ flex flex-devel bison-devel bison gcc-objc libasan valgrind
RUN dnf install -y vala hg
RUN dnf install -y libwmf-devel qt5*-devel qt*-devel 
RUN dnf install -y llvm llvm-devel llvm3.9-devel llvm-static
RUN dnf install -y boost-*
RUN dnf install -y openmpi mpich-devel environment-modules openmpi-devel
RUN dnf install -y graphviz texlive-* 
RUN dnf install -y gitstats

RUN wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip
RUN wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip
RUN unzip build-wrapper-linux-x86.zip -d /opt/
RUN unzip sonar-runner-dist-2.4.zip -d /opt/
RUN ln -s /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 /usr/bin/build-wrapper-linux
RUN ln -s /opt/sonar-runner-2.4/bin/sonar-runner /usr/bin/sonar-runner

RUN rm build-wrapper-linux-x86.zip sonar-runner-dist-2.4.zip 
	
RUN git clone https://github.com/KDE/clazy.git /root/clazy
RUN cd /root/clazy && mkdir build && cd build && cmake ../ && make -j 4 && make install

RUN wget http://pc-instru.lpp.polytechnique.fr/setups/parallel_studio_xe_2018_update1_composer_edition.tgz
RUN tar -xf parallel_studio_xe_2018_update1_composer_edition.tgz
RUN mkdir -p /opt/intel/licenses/
RUN wget http://jetons.polytechnique.fr/licences/intel/license.lic -O /opt/intel/licenses/license.lic 
RUN wget http://jetons.polytechnique.fr/licences/intel/server.lic -O /opt/intel/licenses/server.lic 
COPY silent.cfg /silent.cfg 
RUN parallel_studio_xe_2018_update1_composer_edition/install.sh -s silent.cfg
RUN rm -rf parallel_studio_xe_2018_update1_composer_edition*

RUN echo "system.has_qt5=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_icc=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.icc_version=2017" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_gcov=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_clang=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_clazy=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_cppcheck=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_clang_analyzer=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_lcov=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_gitstats=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_graphviz=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_sonarqube=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_openmpi=true" >> /opt/buildagent/conf/buildAgent.dist.properties  && \
    echo "system.agent_name=fedora-icc2018" >> /opt/buildagent/conf/buildAgent.dist.properties  && \
    echo "system.agent_repo=https://github.com/jeandet/teamcity-docker-agent-fedora-icc2018" >> /opt/buildagent/conf/buildAgent.dist.properties

CMD ["/run-services.sh"]

EXPOSE 9090
