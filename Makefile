# #
# VERSION			:= $(shell git describe --tags)
# BUILD 			:= $(shell git rev-parse --short HEAD)
#PROJECT_NAME 	:= $(shell basename "$(PWD)")
PROJECT_NAME 	:= mq-to-db
PROJECT_BIN_PATH := cmd

# Golang
GO ?= go
GO_BUILD ?= $(GO) build
GO_TEST ?= $(GO) test
GO_FMT ?= $(GO)fmt
GO_MOD ?= $(GO) mod
GO_OPTS ?= -race -v
GO_VENDOR_FOLDER ?= ./vendor

# Container
CONTAINER_BUILD_COMMAND ?= docker build
CONTAINER_BUILD_FILE ?= ./Dockerfile
CONTAINER_BUILD_CONTEXT ?= ./
CONTAINER_IMAGE_ARCH ?= amd64
CONTAINER_IMAGE_NAME ?= $(PROJECT_NAME)
CONTAINER_IMAGE_REPO ?= christiangda
CONTAINER_IMAGE_TAG ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD))


#
.PHONY: all
all: go-lint go-tidy go-test go-build container-build

.PHONY: go-lint
go-lint:
	@echo "--> Linting"

.PHONY: go-fmt
go-fmt:
	@echo "--> Checking formating"
	$(GO_FMT) $(GO_OPTS) -d $$(find . -path $(GO_VENDOR_FOLDER) -prune -o -name '*.go' -print)

.PHONY: go-build
go-build:
	@echo "--> Building"
	$(GO_BUILD) $(GO_OPTS) -o $(PROJECT_NAME) $$(find ./cmd -name '*.go' -print)

.PHONY: go-update-deps
go-update-deps:
	@echo "--> Updating Go dependencies"
	for dep in $$($(GO) list -mod=readonly -m -f '{{ if and (not .Indirect) (not .Main)}}{{.Path}}{{end}}' all); do \
		$(GO) get $$dep; \
	done

.PHONY: go-tidy
go-tidy:
	@echo "--> Tidying"
	$(GO_MOD) tidy
ifneq (,$(wildcard $(GO_VENDOR_FOLDER)))
	@echo "--> Generating Vendor folder"
	$(GO_MOD) vendor
endif

.PHONY: go-test
go-test:
	@echo "--> Test"

.PHONY: clean
clean:
	@echo "--> Cleaning"

.PHONY: container-build
container-build:
	@echo "--> Building container image"
	$(CONTAINER_BUILD_COMMAND) \
		--build-arg ARCH="$(CONTAINER_IMAGE_ARCH)" \
		--build-arg PROJECT_NAME="$(CONTAINER_IMAGE_NAME)" \
		--tag "$(CONTAINER_IMAGE_REPO)/$(CONTAINER_IMAGE_NAME):$(CONTAINER_IMAGE_TAG)" \
		--file $(CONTAINER_BUILD_FILE) \
		$(CONTAINER_BUILD_CONTEXT)
