
.EXPORT_ALL_VARIABLES:

NAMESPACE := default

DEFAULT_OWNER := global-it-operation@greenpeace.org

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

all: clean ingress deploy

lint:
	@find . -type f -name '*.yml' | xargs yamllint
	@find . -type f -name '*.yaml' | xargs yamllint

clean:
	rm -fr ingress

ingress:
	mkdir -p ingress
	./go.sh

connect:
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_CLUSTER) --zone $(PROD_ZONE) --project $(PROD_PROJECT)

namespace: connect
	-kubectl create namespace $(NAMESPACE)

deploy: ingress lint connect namespace
	kubectl -n $(NAMESPACE) apply -f ingress/

destroy: lint connect
	kubectl -n $(NAMESPACE) delete -f ingress/

traefik: connect
	for i in $(shell kubectl -n kube-system get pod -l app=traefik -o name); \
	do echo $$i; \
	kubectl -n kube-system delete $$i; \
	sleep 20; \
	done
