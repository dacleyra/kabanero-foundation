#!/bin/bash
#
# Run this script to collect Kabanero debug information
# get, describe & pod logs of api-resources in namespaces


set -Euox pipefail


BIN=oc
LOGS_DIR=kabanero-debug
NAMESPACES=(istio-system kabanero knative-eventing knative-serving knative-sources kube-system)
APIRESOURCES=(
pods
configmaps
services
routes.route.openshift.io
apiserversources.sources.eventing.knative.dev
appsodyapplications.appsody.dev
brokers.eventing.knative.dev
certificates.networking.internal.knative.dev
channels.eventing.knative.dev
clusterchannelprovisioners.eventing.knative.dev
clusteringresses.networking.internal.knative.dev
clustertasks.tekton.dev
collections.kabanero.io
config.operator.tekton.dev
configurations.serving.knative.dev
containersources.sources.eventing.knative.dev
cronjobsources.sources.eventing.knative.dev
eventtypes.eventing.knative.dev
extensions.dashboard.tekton.dev
githubsources.sources.eventing.knative.dev
images.caching.internal.knative.dev
kabaneros.kabanero.io
knativeeventings.eventing.knative.dev
knativeservings.serving.knative.dev
pipelineresources.tekton.dev
pipelineruns.tekton.dev
pipelines.tekton.dev
podautoscalers.autoscaling.internal.knative.dev
revisions.serving.knative.dev
serverlessservices.networking.internal.knative.dev
services.serving.knative.dev
subscriptions.eventing.knative.dev
taskruns.tekton.dev
tasks.tekton.dev
triggers.eventing.knative.dev
)


rm -Rf ${LOGS_DIR}

for NAMESPACE in ${NAMESPACES[@]}
do
	for APIRESOURCE in ${APIRESOURCES[@]}
	do
		mkdir -p ${LOGS_DIR}/${NAMESPACE}/${APIRESOURCE}
		${BIN} describe ${APIRESOURCE} -n ${NAMESPACE} > ${LOGS_DIR}/${NAMESPACE}/${APIRESOURCE}/describe.log
		${BIN} get ${APIRESOURCE} -n ${NAMESPACE} -o=yaml > ${LOGS_DIR}/${NAMESPACE}/${APIRESOURCE}/get.log
	done
	
	PODS=$(${BIN} get pods -n ${NAMESPACE} -o jsonpath="{.items[*].metadata.name}")
	mkdir -p ${LOGS_DIR}/${NAMESPACE}/pods/
	for POD in ${PODS[@]}
	do
		${BIN} logs --all-containers=true -n ${NAMESPACE} ${POD} > ${LOGS_DIR}/${NAMESPACE}/pods/${POD}.log
	done
	
	
done

${BIN} get nodes -o=wide > ${LOGS_DIR}/get-nodes.log


tar -zcf ${LOGS_DIR}.tar.gz ${LOGS_DIR}
rm -Rf ${LOGS_DIR}


