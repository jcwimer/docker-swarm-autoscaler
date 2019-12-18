FROM ubuntu:xenial

RUN apt-get update -qq \
  && apt-get install -y -qq \
    jq \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    dnsutils \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
  && apt-get update -qq \
  && apt-get install -y -qq \
    docker-ce=5:19.03.5* \
  && apt-get -qq clean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

COPY auto-scale.sh /auto-scale.sh
RUN chmod a+x /auto-scale.sh

CMD ["/auto-scale.sh"]