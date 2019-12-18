FROM ruby:2.6.3
RUN apt-get update -qq && \
  apt-get install -y -qq \
    jq \
    make \
    gcc \
    bash
    
RUN echo 'gem: --no-rdoc --no-ri' > /root/.gemrc
RUN gem install bundler
RUN gem update --system
RUN mkdir -p /gemfile

#Cache gems so they don't install on every code change
WORKDIR /gemfile
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --jobs 4