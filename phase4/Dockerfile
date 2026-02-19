FROM node:18-alpine

WORKDIR /usr/src/app

COPY resources/codebase_partner/package.json resources/codebase_partner/package-lock.json ./

RUN npm install

COPY resources/codebase_partner/ .

EXPOSE 3000

CMD ["node", "index.js"]
