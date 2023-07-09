FROM zatarain/rails-api
RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
	libpq-dev \
	postgresql-client \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY . .
RUN echo 'export $(strings /proc/1/environ | grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)' >> /root/.profile
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
