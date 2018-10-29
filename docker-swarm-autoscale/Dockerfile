FROM ubuntu:xenial

RUN apt-get update -qq \
  && apt-get install -y -qq \
    jq \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
  && apt-get update -qq \
  && apt-get install -y -qq \
    docker-ce=18.03.0~ce-0~ubuntu \
  && apt-get -qq clean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

COPY auto-scale.sh /auto-scale.sh
RUN chmod a+x /auto-scale.sh

ENTRYPOINT ["/bin/bash"]
CMD ["/auto-scale.sh"]
