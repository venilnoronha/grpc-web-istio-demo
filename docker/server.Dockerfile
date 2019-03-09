FROM golang:1.12 as builder
MAINTAINER Venil Noronha <veniln@vmware.com>

WORKDIR /root/go/src/github.com/venilnoronha/grpc-web-istio-demo/
COPY ./ .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -v -o bin/server ./cmd/server.go

FROM scratch
WORKDIR /bin/
COPY --from=builder /root/go/src/github.com/venilnoronha/grpc-web-istio-demo/bin/server .
ENTRYPOINT [ "/bin/server" ]
EXPOSE 9000
