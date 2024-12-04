FROM ruby:3.2.2

RUN apt update
RUN apt-get install -y curl
RUN apt-get install -y jq
RUN apt-get install -y bash
RUN apt-get install -y less
RUN apt-get install -y vim
RUN apt-get install -y coreutils

WORKDIR /home/folio-tasks

COPY bin ./bin/
COPY config/settings/pod.yml ./config/settings/pod.yml
COPY lib ./lib/
COPY tasks ./tasks/
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock
COPY Rakefile ./Rakefile
COPY run_rake.sh ./run_rake.sh

RUN bundle
