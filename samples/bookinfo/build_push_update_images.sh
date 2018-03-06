#!/bin/bash
#
# Copyright 2018 Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

set -o errexit

if [ "$#" -ne 1 ]; then
    echo Missing version parameter
    echo Usage: build-services.sh \<version\>
    exit 1
fi

VERSION=$1
echo "Building images"
src/build-services.sh $VERSION
IMAGES=$(docker images -f reference=istio/examples-bookinfo*:$VERSION --format "{{.Repository}}:$VERSION")
REMOTES=`echo ${IMAGES} | sed "s/istio\///g"`
echo "Tagging and pushing to repo $HUB"
for IMAGE in $IMAGES; do
    remote=`echo $IMAGE | sed "s/istio\///"`
    docker tag $IMAGE $HUB/$remote
    docker push $HUB/$remote
done
echo "Modifying image location (${HUB}) in YAML files"
sed -i "s/istio\(\/examples-bookinfo-.*\):[[:digit:]]\.[[:digit:]]\.[[:digit:]]/docker.io\/$GITHUB_USER\1:$VERSION/g" */bookinfo*.yaml

