SHELL := $(shell which bash)
.PHONY: test

test:
	pushd test; \
	go mod init "aws-bedrock-inference-profile"; \
	go mod tidy; \
	go test -v -tags integration -timeout 3600s; \
	popd
