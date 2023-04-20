FROM zatarain/next-web
# COPY . .
RUN npm ci && npm run build
# && npm run lint
CMD ["npm", "run", "dev"]
