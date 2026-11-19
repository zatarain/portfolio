FROM node:26.13.1-slim
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
RUN npm install --global pnpm@12.21.0
COPY . .
RUN pnpm install --frozen-lockfile && pnpm run build
ENTRYPOINT ["bin/entrypoint"]
CMD ["pnpm", "run", "start"]
