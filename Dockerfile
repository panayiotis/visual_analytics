# docker build -t hackathon .
# docker run --rm -it -p 3000:3000 -v `pwd`:/var/www/hackathon:z hackathon rails server -b 0.0.0.0

FROM panos/ruby

RUN mkdir -p /var/www/hackathon

ENV APP_HOME /var/www/hackathon

WORKDIR $APP_HOME

RUN bundle config build.nokogiri --use-system-libraries

ADD Gemfile Gemfile.lock $APP_HOME/

RUN bundle install

CMD bash
