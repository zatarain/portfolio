FROM node:19.9.0-slim
EXPOSE 5000

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
	build-essential \
	less \
	git \
	curl \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ARG NEXT_PUBLIC_API_URL
ENV LANG=C.UTF-8 \
	NODE_ENV=development \
	NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
WORKDIR /web
RUN npm config set fund false -g \
	&& npm config set audit false -g
COPY . .
RUN npm ci && npm run build
RUN curl -vvv https://localhost:3000/
RUN curl -vvv http://localhost:3000/
RUN curl -vvv https://api.beta.zatara.in/
ENTRYPOINT ["bin/entrypoint"]
CMD ["npm", "run", "start"]
