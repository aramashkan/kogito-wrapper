#!/bin/bash
[ -z "$KOGITO_PATH" ] && echo Missing kogito path param! && exit 1
[ -z "$REPO_HOST" ] && echo Missing repo host param! && exit 1
cd wrapper

##### get number of files
numberFiles=$(echo $(ls -l $KOGITO_PATH/*.{bpmn,bpmn2} | wc -l))
echo "number of files $numberFiles"
[ $numberFiles -ne 1 ] && echo Wrong number of files! && exit 1
#####
for f in $KOGITO_PATH/*.{bpmn,bpmn2}; do
  [ ! -f "$f" ] && continue
  echo "Processing $f file..."
  cp "$f" src/main/resources/

  processId=$(echo $(xpath -e 'string(//*[local-name() = "process"]/@id)' $f))
  echo "result parse $processId"
  [ -z $processId ] && echo Cant parse process id! && exit 1
  numberFiles=$(echo $(ls -l src/main/resources/*.{bpmn,bpmn2} | wc -l))
  echo "Number copied files...$numberFiles"
  [ $numberFiles -ne 1 ] && echo Wrong number of copied files! && exit 1
  nameNormalize=$(echo $processId | tr '[:upper:]' '[:lower:]')
  mvn -q clean install \
    -Dquarkus.container-image.insecure=true \
    -Dquarkus.container-image.group=kogito \
    -Dquarkus.container-image.registry=$REPO_HOST \
    -Dquarkus.container-image.name=$nameNormalize-$P_VERSION \
    -Dquarkus.container-image.tag=$GIT_HASH
  result=$(echo $?)
  echo "Maven build result: $result"
  [ $result -ne 0 ] && exit 1
  echo "Pushed image for $f file..."
  imageUrl="$REPO_HOST/kogito/$nameNormalize:$GIT_HASH"
  echo "Image $imageUrl"
  [ ! -d k8s/workspace ] && mkdir k8s/workspace
  cp k8s/*.yaml k8s/workspace
  sed -i '' -e "s#{ _service_name_ }#$nameNormalize-$P_VERSION#" "k8s/workspace/kogito-process.yaml"
  sed -i '' -e "s#{ _version_ }#$P_VERSION#" "k8s/workspace/kogito-process.yaml"
  sed -i '' -e "s#{ _image_ }#$imageUrl#" "k8s/workspace/kogito-process.yaml"
  cat k8s/workspace/kogito-process.yaml
  exit 0
done
