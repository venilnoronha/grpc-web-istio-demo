FROM node:8.15 as builder
MAINTAINER Venil Noronha <veniln@vmware.com>

WORKDIR /web-ui/
COPY web-ui/ .
COPY proto/ .
RUN npm install
RUN npx webpack app.js

FROM python:2.7
WORKDIR /web-ui/
COPY --from=builder /web-ui/ .
ENTRYPOINT [ "python" ]
CMD [ "-m", "SimpleHTTPServer", "9001" ]
EXPOSE 9001
