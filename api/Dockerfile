FROM zatarain/rails-api
COPY . .
RUN echo 'export $(strings /proc/1/environ | grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)' >> /root/.profile
RUN echo 'precedence  2a04:4e42::0/32  5' >> /etc/gai.conf
RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
  libpq-dev \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN bundle install
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
