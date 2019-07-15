# Extending image
# FROM node:carbon

# RUN apt-get update
# RUN apt-get upgrade -y
# RUN apt-get -y install autoconf automake libtool nasm make pkg-config git apt-utils

# # Create app directory
# RUN mkdir -p /usr/src/app
# # WORKDIR /usr/src/app

# # Versions
# RUN npm -v
# RUN node -v

# # Install app dependencies
# COPY package.json /usr/src/app/
# # COPY package-lock.json /usr/src/app/

# RUN npm install

# # Bundle app source
# COPY . /usr/src/app

# # Port to listener
# EXPOSE 3000

# # Environment variables
# ENV NODE_ENV production
# ENV PORT 3000
# ENV PUBLIC_PATH "/"

# RUN npm run start:build

# # Main command
# CMD [ "npm", "run", "start:server" ]

# # stage: 1
# FROM node:8 as react-build
# WORKDIR /app
# COPY . ./
# RUN yarn
# RUN yarn build

### STAGE 1: Build ###
FROM node:9.11.1 as react-build
RUN mkdir /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json
RUN npm install --silent
RUN npm install react-scripts -g --silent
COPY . /usr/src/app
RUN npm run build

# stage: 2 — the production environment
FROM nginx:1.13.12-alpine
COPY --from=react-build /usr/src/app/build/ /usr/share/nginx/html/
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/conf.d
EXPOSE 80
# CMD [“nginx”, “-g”, “daemon off;”]