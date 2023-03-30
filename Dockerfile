FROM ruby:3.2.1-slim

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    build-essential \
    less \
    git \
    libvips \
    curl \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
  
RUN gem update --system && gem install bundler

WORKDIR /service
RUN rm -f /usr/src/app/tmp/pids/server.pid
COPY . .
RUN bundle check || bundle install --jobs 4
RUN rails new --force --api .
EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
