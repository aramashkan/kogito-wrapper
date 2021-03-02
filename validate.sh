#!/bin/bash
[ -z "$KOGITO_PATH" ] && echo Missing registry param! && exit 1
##### get number of files
numberFiles=$(echo $( ls -l $KOGITO_PATH/*.{dmn,bpmn,bpmn2,pmml} | wc -l ))
echo "number of files $numberFiles"
[ $numberFiles -gt 1 ] && echo Wrong number of files! && exit 1
#####
rm validatedMetaInf
for f in $KOGITO_PATH/*.{dmn,bpmn,bpmn2,pmml}
do
  [ ! -f "$f" ] && continue
  echo "Processing $f file..."
  rm src/main/resources/kogito/*
  cp "$f" src/main/resources/kogito/
  mvn clean install \
    -Dquarkus.container-image.push=false
  [ -f "target/.*jar" ] && echo Failed build! && exit 1
  echo "Validated for $f file..."
done
echo "SUCCESS" >> "validatedMetaInf"

