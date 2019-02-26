# Copyright 2019 VMware, Inc.
# SPDX-License-Identifier: BSD-3-Clause

.PHONY: help
help:
	@echo "Usage: make <TARGET>"
	@echo ""
	@echo "Available targets are:"
	@echo ""
	@echo "    generate-go              Generate Go files from proto"
	@echo "    generate-js              Generate JavaScript files from proto"
	@echo ""
	@echo "    run-server               Run the server"
	@echo "    run-server-docker        Run the server over Docker"
	@echo "    run-client-local         Run the client and connect to local server"
	@echo "    run-client-istio         Run the client and connect to server via Istio"
	@echo ""
	@echo "    build-server             Build the server image"
	@echo "    build-webapp             Build the webapp image"
	@echo ""
	@echo "    deploy-server            Deploy the server over Kubernetes"
	@echo "    deploy-webapp            Deploy the webapp over Kubernetes"
	@echo "    deploy-gateway           Deploy the gateway configuration"
	@echo ""
	@echo "    inspect-proxy            Inspect the Istio proxy configuration"
	@echo "    proxy-logs               Inspect the Istio proxy logs"
	@echo ""
	@echo "    reset                    Reset the deployment"
	@echo ""

.PHONY: generate-go
generate-go:
	protoc -I proto/ proto/emoji.proto \
	       --go_out=plugins=grpc:proto

.PHONY: generate-js
generate-js:
	protoc -I proto/ proto/emoji.proto \
	       --js_out=import_style=commonjs:proto \
	       --grpc-web_out=import_style=commonjs,mode=grpcwebtext:proto

.PHONY: run-server
run-server:
	go run -v cmd/server.go

.PHONY: run-server-docker
run-server-docker:
	docker run --rm -p 9000:9000 vnoronha/grpc-web-istio-demo:server

.PHONY: run-client-local
run-client-local:
	go run -v cmd/client.go --server 'localhost:9000' --text 'I like :pizza: and :sushi:!'

.PHONY: run-client-istio
run-client-istio:
	go run -v cmd/client.go --server '192.168.99.100:31380' --text 'I like :pizza: and :sushi:!'

.PHONY: build-server
build-server:
	docker build -f docker/server.Dockerfile -t vnoronha/grpc-web-istio-demo:server .

.PHONY: build-webapp
build-webapp:
	docker build -f docker/webapp.Dockerfile -t vnoronha/grpc-web-istio-demo:webapp .

.PHONY: deploy-server
deploy-server:
	kubectl apply -f <(istioctl kube-inject -f istio/server.yaml)

.PHONY: deploy-webapp
deploy-webapp:
	kubectl apply -f <(istioctl kube-inject -f istio/webapp.yaml)

.PHONY: deploy-gateway
deploy-gateway:
	kubectl apply -f istio/gateway.yaml

.PHONY: inspect-proxy
inspect-proxy:
	$(eval POD := $(shell kubectl get pod -l app=server -o jsonpath='{.items..metadata.name}'))
	istioctl proxy-config listeners ${POD}.default --port 9000 -o json

.PHONY: proxy-logs
proxy-logs:
	$(eval POD := $(shell kubectl get pod -l app=server -o jsonpath='{.items..metadata.name}'))
	kubectl logs ${POD} istio-proxy -f

.PHONY: reset
reset:
	kubectl delete -f istio/server.yaml
	kubectl delete -f istio/webapp.yaml
	kubectl delete -f istio/gateway.yaml
