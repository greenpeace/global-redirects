
.EXPORT_ALL_VARIABLES:

NAMESPACE := global-redirects

DEFAULT_OWNER := global-it-operation@greenpeace.org

DEV_CLUSTER ?= p4-development
DEV_PROJECT ?= planet-4-151612
DEV_ZONE ?= us-central1-a

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

YAMLLINT := $(shell command -v yamllint 2> /dev/null)
JQ := $(shell command -v jq 2> /dev/null)

init: .git/hooks/pre-commit

.git/hooks/%:
	@chmod 755 .githooks/*
	@find .git/hooks -type l -exec rm {} \;
	@find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;

lint: init lint-json

lint-yaml:
ifdef YAMLLINT
	@find . -type f -name '*.yml' | xargs $(YAMLLINT)
	@find . -type f -name '*.yaml' | xargs $(YAMLLINT)
else
	$(warning "WARNING :: yamllint is not installed: https://github.com/adrienverge/yamllint")
endif

lint-json:
ifdef JQ
	@find . -type f -name '*.json' | xargs $(JQ) .
else
	$(warning "WARNING :: jq is not installed: https://stedolan.github.io/jq/")
endif

#List all redirect ingresses in Global Redirect namespace
list:
	kubectl -n $(NAMESPACE) get ingress -l app=redirects

#Locally delete the ingress subfolder
clean:
	@rm -fr ingress

#Create dev ingress yaml files in ingress subfolder
devingress:
	@mkdir -p ingress
	@./go.sh dev.sites.json

#Create dev ingress yaml files in ingress subfolder
prodingress:
	@mkdir -p ingress
	@./go.sh prod.sites.json

#Prepare yaml files for deployment
devprep: lint clean devingress lint-yaml

#Prepare yaml files for deployment
prodprep: lint clean prodingress lint-yaml

#Deploy ingresses to Dev
dev: devprep
ifndef CI
	$(error This is intended to be deployed via CI, please commit and push)
endif
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	kubectl -n $(NAMESPACE) apply -f ingress/

#Deploy ingresses to Prod
prod: prodprep
ifndef CI
	$(error This is intended to be deployed via CI, please commit and push)
endif
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_PROJECT) --zone $(PROD_ZONE) --project $(PROD_PROJECT)
	kubectl -n $(NAMESPACE) apply -f ingress/

#Delete all the ingresses
destroy: lint connect
	@echo -n "You are about to ** DELETE INGRESS/S **, enter y if your sure ? [y/N] " && read ans && [ $${ans:-N} = y ]
	kubectl -n $(NAMESPACE) delete -f ingress/
