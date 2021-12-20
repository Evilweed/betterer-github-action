#FROM node:16-alpine
#
#COPY ["entrypoint.sh", "package.json", "./"]
#
#RUN npm install
#
#COPY . .
#
#COPY entrypoint.sh /entrypoint.sh
#
#ENTRYPOINT ["/entrypoint.sh"]

FROM node:16-alpine AS builder
WORKDIR /action
COPY package.json ./
RUN yarn install
COPY tsconfig.json ./
COPY src/ src/
RUN npm run build \
  && npm prune --production

FROM node:16-alpine
WORKDIR /
RUN apk add --no-cache tini
COPY --from=builder action/package.json .
COPY --from=builder action/build build/
COPY --from=builder action/node_modules node_modules/
COPY entrypoint.sh .
ENTRYPOINT [ "/sbin/tini", "--", "node_modules/@betterer/betterer/cli/bin/betterer" ]
#ENTRYPOINT [ "/sbin/tini", "--", "cd /", "yarn", "run", "betterer" ]
#ENTRYPOINT ["/bin/sh -c"]
#ENTRYPOINT [ "/entrypoint.sh" ]
