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
RUN npm config set fund false -g \
	&& npm config set audit false -g
COPY . .
RUN npm ci --omit=optional && npm run build && npm test
ENTRYPOINT ["bin/entrypoint"]
CMD ["npm", "run", "start"]
