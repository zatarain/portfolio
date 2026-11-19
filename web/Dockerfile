FROM node:26.13.1-slim
EXPOSE 5000

ARG TARGETARCH
ARG PNPM_VERSION=12.21.0

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
	build-essential \
	less \
	git \
	curl \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN set -eu; \
	case "$TARGETARCH" in \
		amd64) pnpm_arch=linux-x64; pnpm_sha256=84c4773bcf4a217f4083cd7b2a91e4cee6103cf42426c1282ef37d308f55a410 ;; \
		arm64) pnpm_arch=linux-arm64; pnpm_sha256=6c5913a48c93b3a556b71c3bd9bf12c6bf9fbfbbbd2dcbd1d52a85c539751b9e ;; \
		*) echo "Unsupported Docker architecture: $TARGETARCH" >&2; exit 1 ;; \
	esac; \
	pnpm_archive="/tmp/pnpm-${pnpm_arch}.tar.gz"; \
	curl -fsSL "https://github.com/pnpm/pnpm/releases/download/v${PNPM_VERSION}/pnpm-${pnpm_arch}.tar.gz" -o "$pnpm_archive"; \
	echo "$pnpm_sha256  $pnpm_archive" | sha256sum -c -; \
	tar -xzf "$pnpm_archive" -C /usr/local/bin pnpm; \
	chmod 755 /usr/local/bin/pnpm; \
	rm -f "$pnpm_archive"; \
	test "$(pnpm --version)" = "$PNPM_VERSION"
RUN mkdir -p /usr/local/etc && printf 'ignore-scripts=true\n' > /usr/local/etc/npmrc
ARG NEXT_PUBLIC_API_URL
ENV LANG=C.UTF-8 \
	NODE_ENV=development \
	NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
WORKDIR /web
COPY . .
RUN pnpm install --frozen-lockfile && pnpm run build
ENTRYPOINT ["bin/entrypoint"]
CMD ["pnpm", "run", "start"]
