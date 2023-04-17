FROM zatarain/next-web
COPY . .
RUN npm install && npm run lint
CMD ["npm", "run", "dev"]
