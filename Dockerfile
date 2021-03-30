FROM gitlab/gitlab-runner:v13.10.0

ENV TERM=linux
ENV DOCKER_VERSION_CURRENT=19.03.8
ENV COMPOSE_VERSION_CURRENT=1.28.6
ENV PHPUNIT=7
    
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y install \
            sudo \
            make \
            rsync \
            curl \
            nano \
            sshpass \
            php-cli \
        --no-install-recommends && \
    apt-get -y clean && \
    rm -r /var/lib/apt/lists/*

# add missing SSL certificate https://bugs.launchpad.net/ubuntu/+source/ca-certificates/+bug/1261855
RUN curl -o /usr/local/share/ca-certificates/como.crt \
      https://gist.githubusercontent.com/schmunk42/5abeaf7ca468dc259325/raw/2a8e19139d29aeea2871206576e264ef2d45a46d/comodorsadomainvalidationsecureserverca.crt \
 && update-ca-certificates

RUN curl -L https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION_CURRENT}.tgz > /tmp/docker-${DOCKER_VERSION_CURRENT}.tgz && \
    cd /tmp && tar -xzf ./docker-${DOCKER_VERSION_CURRENT}.tgz && \
    mv /tmp/docker/docker /usr/local/bin/docker-${DOCKER_VERSION_CURRENT} && \
    chmod +x /usr/local/bin/docker-${DOCKER_VERSION_CURRENT} && \
    rm -rf /tmp/docker*

RUN curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION_CURRENT}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose-${COMPOSE_VERSION_CURRENT} && \
    chmod +x /usr/local/bin/docker-compose-${COMPOSE_VERSION_CURRENT}

# Link default versions
RUN ln -s /usr/local/bin/docker-${DOCKER_VERSION_CURRENT} /usr/local/bin/docker && \
    ln -s /usr/local/bin/docker-compose-${COMPOSE_VERSION_CURRENT} /usr/local/bin/docker-compose

# PHP stuff
RUN cd /tmp && wget -O phpunit https://phar.phpunit.de/phpunit-${PHPUNIT}.phar && chmod +x phpunit && mv phpunit /usr/bin/

# SSH Key
RUN mkdir /home/gitlab-runner/.ssh && chown gitlab-runner:gitlab-runner /home/gitlab-runner/.ssh
#RUN DEBIAN_FRONTEND=noninteractive ssh-keygen -q -t rsa -N '' -f /home/gitlab-runner/.ssh/id_rsa
USER gitlab-runner
RUN DEBIAN_FRONTEND=noninteractive ssh-keygen -q -t rsa -N '' <<< ""$'\n'"y" 2>&1 >/dev/null

CMD ["run", "--user=root", "--working-directory=/home/gitlab-runner"]

RUN git config --global user.email "ci-runner@example.com" && \
    git config --global user.name "CI Runner"
