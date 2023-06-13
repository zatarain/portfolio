FROM zatarain/next-web
COPY . .
RUN npm ci && npm run build
CMD ["npm", "run", "start"]
