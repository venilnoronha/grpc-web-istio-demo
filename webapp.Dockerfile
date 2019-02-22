FROM node:8.15 as builder
MAINTAINER Venil Noronha <veniln@vmware.com>

WORKDIR /webapp/
COPY webapp/ .
COPY proto/ .
RUN npm install
RUN npx webpack app.js

FROM python:2.7
WORKDIR /webapp/
COPY --from=builder /webapp/ .
ENTRYPOINT [ "python" ]
CMD [ "-m", "SimpleHTTPServer", "9001" ]
EXPOSE 9001
