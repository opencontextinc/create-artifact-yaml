#!/bin/sh

export artifactType="${INPUT_TYPE}"
export url="${INPUT_URL}"
export fullname="${url##*/}"
export shortname="${fullname:0:63}"
export tplName=""
export filename=""

env
jq . $GITHUB_EVENT_PATH

case "${artifactType}" in
  sbom|SBOM|package)
                    tplName="/templates/cc.yaml"
                    filename="${GITHUB_WORKSPACE}/cc-${fullname}.yaml"
                ;;
  container|image)  
                    tplName="/templates/pc.yaml"
                    filename="${GITHUB_WORKSPACE}/pc-${fullname}.yaml"
                ;;
  *) echo "ERROR: Unknown artifact type!"
     exit 1
esac

export ghaRunUrl="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
export ghaRunTitle="GitHub Action Run ${GITHUB_RUN_ID}"

yq '.metadata.namespace = env(GITHUB_REPOSITORY_OWNER) | .metadata.name = env(shortname) | .metadata.title = env(fullname) | .metadata.links.[0].url = env(url) | .metadata.links.[0].title = env(fullname) |
    .metadata.links.[1].url = env(ghaRunUrl) | .metadata.links.[1].title = env(ghaRunTitle) | .metadata.annotations."github.com/project-slug" = env(GITHUB_REPOSITORY) | .spec.type = env(artifactType) | .spec.uri = env(url) |
    .spec.owner[0] = env(GITHUB_REPOSITORY_OWNER) + "/" + env(GITHUB_ACTOR) | .spec.dependsOn[0] = "codecomponent:" + env(GITHUB_REPOSITORY)' "${tplName}" > "${filename}"

echo "filename=${filename}" >> "$GITHUB_OUTPUT"
