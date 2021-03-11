#!/bin/bash
[ -z "$KOGITO_PATH" ] && echo Missing registry param! && exit 1
##### get number of files
numberFiles=$(echo $( ls -l $KOGITO_PATH/*.{dmn,bpmn,bpmn2,pmml} | wc -l ))
echo "number of files $numberFiles"
[ $numberFiles -gt 1 ] && echo Wrong number of files! && exit 1
#####
cd wrapper
for f in $KOGITO_PATH/*.{dmn,bpmn,bpmn2,pmml}
do
  [ ! -f "$f" ] && continue
  echo "Processing $f file..."
  rm src/main/resources/*.{dmn,bpmn,bpmn2,pmml}
  cp "$f" src/main/resources/
  mvn clean install \
    -Dquarkus.container-image.push=false \
    -Dquarkus.container-image.build=false
  result=$(echo $?)
  echo "Maven build result: $result"
  [ $result -ne 0 ] && exit 1
  echo "Validated for $f file..."
  rm src/main/resources/*.{dmn,bpmn,bpmn2,pmml}
  mvn clean
done

