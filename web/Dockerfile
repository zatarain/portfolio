FROM node:19.9.0-slim
EXPOSE 5000

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
	build-essential \
	less \
	git \
	curl \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=C.UTF-8 \
	NODE_ENV=development
WORKDIR /web
COPY . .
ENTRYPOINT ["bin/entrypoint"]
CMD ["npm", "run", "start"]
