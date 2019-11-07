
.EXPORT_ALL_VARIABLES:

NAMESPACE := default

DEFAULT_OWNER := global-it-operation@greenpeace.org

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

YAMLLINT := $(shell command -v yamllint 2> /dev/null)
JQ := $(shell command -v jq 2> /dev/null)

all: init lint deploy

init: .git/hooks/pre-commit

.git/hooks/%:
	@chmod 755 .githooks/*
	@find .git/hooks -type l -exec rm {} \;
	@find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;

lint: init lint-json clean ingress lint-yaml

lint-yaml:
ifndef YAMLLINT
	$(error "yamllint is not installed: https://github.com/adrienverge/yamllint")
endif
	@find . -type f -name '*.yml' | xargs $(YAMLLINT)
	@find . -type f -name '*.yaml' | xargs $(YAMLLINT)

lint-json:
ifndef JQ
	$(error "jq is not installed: https://stedolan.github.io/jq/")
endif
	@find . -type f -name '*.json' | xargs $(JQ) .

list:
	kubectl -n $(NAMESPACE) get ingress -l app=redirects

clean:
	rm -fr ingress

ingress: lint
	mkdir -p ingress
	./go.sh

connect:
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_CLUSTER) --zone $(PROD_ZONE) --project $(PROD_PROJECT)

namespace: connect
	-kubectl create namespace $(NAMESPACE)

deploy: ingress lint connect namespace
ifndef CI
	$(error This is intended to be deployed via CI, please commit and push)
endif
	kubectl -n $(NAMESPACE) apply -f ingress/

destroy: lint connect
	kubectl -n $(NAMESPACE) delete -f ingress/

traefik: lint connect
	for i in $(shell kubectl -n kube-system get pod -l app=traefik -o name); \
	do echo $$i; \
	kubectl -n kube-system delete $$i; \
	sleep 20; \
	done
