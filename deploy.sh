#!/bin/bash
[ ! -s deployMetaInf ] && echo "Missing meta data for k8s deploy" && exit 1

[ ! -d k8s/workspace ] && mkdir k8s/workspace
echo "Some body $1"
#localhost/kogito/traffic_violation:ed56cdc4df61d7db8a97ef6744f3cd51665315fd;Traffic.Violation;traffic.violation
read -r line <deployMetaInf
cp k8s/*.yaml k8s/workspace
arrIN=(${line//;/ })
serviceName=${arrIN[1]}
image=${arrIN[0]}
ingressName=${arrIN[2]}
sed -i '' -e "s#{ _service_name_ }#$serviceName#" "k8s/workspace/kogito-process.yaml"
sed -i '' -e "s#{ _image_ }#$image#" "k8s/workspace/kogito-process.yaml"
sed -i '' -e "s#{ _service_path_ }#${serviceName//./%20}#" "k8s/workspace/kogito-process.yaml"
sed -i '' -e "s#{ _ingress_name_ }#$ingressName#" "k8s/workspace/kogito-process.yaml"
kubectl apply -f k8s/workspace/
rm k8s/workspace/*

rm -rf k8s/workspace
rm deployMetaInf
