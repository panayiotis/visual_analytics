# docker build -t hackathon .
# docker run --rm -it -p 3000:3000 -v `pwd`:/var/www/hackathon:z hackathon rails server -b 0.0.0.0

FROM fedora:25

RUN dnf -y install rubygems ruby-devel gcc gcc-c++ redhat-rpm-config \
  libffi-devel sqlite-devel zlib-devel libxslt-devel make

RUN echo 'gem: --no-document' > ~/.gemrc

RUN gem update --system

RUN gem install bundler

RUN mkdir -p /var/www/hackathon

ENV APP_HOME /var/www/hackathon

WORKDIR $APP_HOME

RUN bundle config build.nokogiri --use-system-libraries

ADD Gemfile Gemfile.lock $APP_HOME/

RUN bundle install

CMD bash
