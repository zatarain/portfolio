FROM ruby:3.2.1-slim
EXPOSE 3000

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
	build-essential \
	less \
	git \
	libvips \
	curl \
	libpq-dev \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
	BUNDLE_JOBS=4 \
	BUNDLE_RETRY=3

RUN gem update --system && gem install bundler

WORKDIR /api
COPY . .
RUN echo 'export $(strings /proc/1/environ | grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)' >> /root/.profile
ENTRYPOINT ["./bin/entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
