FROM ruby:2.4.1

ENV port=80
ENV apihost=localhost
ENV apiport=8081
ENV dbhost=localhost
ENV dbport=8082
ENV dbpass=password123

RUN apt-get update -q && \
    apt-get install -q -y tcpdump

RUN  mkdir -p /opt/k8s_connect
COPY . /opt/k8s_connect

RUN gem install bundler --without development --no-ri --no-rdoc

WORKDIR /opt/k8s_connect
RUN bundle install --without development

EXPOSE $port

CMD ["bundle", "exec", "ruby", "app.rb"]
