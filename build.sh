#!/bin/bash
[ -z "$KOGITO_PATH" ] && echo Missing kogito path param! && exit 1
[ -z "$REPO_HOST" ] && echo Missing repo host param! && exit 1
[ ! -f validatedMetaInf ] && echo "Missing validated file for build" && exit 1

rm deployMetaInf
##### get number of files
numberFiles=$(echo $( ls -l $KOGITO_PATH/*.{dmn,bpmn,bpmn2,pmml} | wc -l ))
echo "number of files $numberFiles"
[ $numberFiles -gt 1 ] && echo Wrong number of files! && exit 1
#####
##### parse git commit hash
line=$(head -n 1 $KOGITO_PATH/.git/HEAD)
refs=($line)
tag=$(echo $(head -n 1 $KOGITO_PATH/.git/${refs[1]}))
echo "Tag $tag"
echo "Tag $EVENT_TAG"
#####
for f in $KOGITO_PATH/*.{dmn,bpmn,bpmn2,pmml}
do
  [ ! -f "$f" ] && continue
  echo "Processing $f file..."
  rm src/main/resources/kogito/*
  cp "$f" src/main/resources/kogito/
  fullname=$(basename -- "$f")
  name="${fullname%.*}"
  filename=$( echo ${fullname%.*} | tr '[:upper:]' '[:lower:]')
  nameNormalize=${filename// /_}
  mvn clean install \
    -Dquarkus.container-image.insecure=true \
    -Dquarkus.container-image.group=kogito \
    -Dquarkus.container-image.registry=$REPO_HOST \
    -Dquarkus.container-image.name=$nameNormalize \
    -Dquarkus.container-image.tag=$tag
  result=$(echo $?)
  echo "Build result $result"
  [ -f "target/.*jar" ] && echo Failed build! && exit 1
  echo "Pushed image for $f file..."
  imageUrl="$REPO_HOST/kogito/$nameNormalize:$tag"
  echo "Image $imageUrl"
  [ ! -d k8s/workspace ] && mkdir k8s/workspace
  cp k8s/*.yaml k8s/workspace
  serviceName="${name// /.}"
  ingressName="${filename// /.}"
  sed -i '' -e "s#{ _service_name_ }#$serviceName#" "k8s/workspace/kogito-process.yaml"
  sed -i '' -e "s#{ _image_ }#$imageUrl#" "k8s/workspace/kogito-process.yaml"
  sed -i '' -e "s#{ _service_path_ }#${serviceName//./%20}#" "k8s/workspace/kogito-process.yaml"
  sed -i '' -e "s#{ _ingress_name_ }#$ingressName#" "k8s/workspace/kogito-process.yaml"
  cat k8s/workspace/kogito-process.yaml
  echo "Done"
done

