#!/bin/sh
# shellcheck disable=SC3057

export artifactType="${INPUT_TYPE}"
export url="${INPUT_URL}"
export fullname="${url##*/}"
export ghaPath="${GITHUB_WORKSPACE}/artifact-context"
export tplName=""
export filename=""
export shortname=""

case "${artifactType}" in
  sbom)
                    shortname="${fullname:0:63}"
                    tplName="/templates/auxcomponent.yaml"
                    filename="${ghaPath}/ac-${fullname}.yaml"
                ;;
  package)
                    tShortName="${fullname%%#*}"
                    shortname="${tShortName:0:63}"
                    tplName="/templates/codecomponent.yaml"
                    filename="${ghaPath}/cc-${shortname}.yaml"
                ;;
  container|image)  
                    if [ "$artifactType" = "container" ]; then
                      tShortName="${fullname%%:*}"
                      shortname="${tShortName:0:63}"
                      filename="${ghaPath}/pc-${shortname}.yam"
                    else
                      shortname="${fullname:0:63}"
                      filename="${ghaPath}/pc-${fullname}.yaml"
                    fi
                    tplName="/templates/platformcomponent.yaml"
                ;;
  *) echo "ERROR: Unknown artifact type!"
     exit 1
esac

export ghaRunUrl="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
export ghaRunTitle="GitHub Action Run ${GITHUB_RUN_ID}"
# remove [bot] from the end of GITHUB_ACTOR
export parsedGHActor="${GITHUB_ACTOR%%[bot*}"
export ghBotAvatar="https://github.com/identicons/app/app/${parsedGHActor}"

mkdir "$ghaPath"

# create artifact YAML
yq '.metadata.namespace = env(GITHUB_REPOSITORY_OWNER) | .metadata.name = env(shortname) | .metadata.title = env(fullname) | .metadata.links.[0].url = env(url) | .metadata.links.[0].title = env(fullname) |
    .metadata.links.[1].url = env(ghaRunUrl) | .metadata.links.[1].title = env(ghaRunTitle) | .metadata.annotations."github.com/project-slug" = env(GITHUB_REPOSITORY) | .spec.type = env(artifactType) | .spec.uri = env(url) |
    .spec.owner[0] = env(GITHUB_REPOSITORY_OWNER) + "/" + env(parsedGHActor) | .spec.dependsOn[0] = "codecomponent:" + env(GITHUB_REPOSITORY)' "${tplName}" > "${filename}"

# create YAML for bot
if [ "$GITHUB_ACTOR" != "$parsedGHActor" ]; then
  yq '.metadata.namespace = env(GITHUB_REPOSITORY_OWNER) | .metadata.name = env(parsedGHActor) | .metadata.annotations."github.com/project-slug" = env(GITHUB_REPOSITORY) | .spec.profile.picture = env(ghBotAvatar)' /templates/person.yaml > "${ghaPath}/${parsedGHActor}.yaml"
fi

# create tar-gzipped file of YAML generated
cd "${ghaPath}" || exit
tar cfz "${GITHUB_WORKSPACE}/artifact-context.tgz" .

# set GHA output filename to tar-gzipped file generated
echo "filename=artifact-context.tgz" >> "$GITHUB_OUTPUT"
# set GHA output directory to the directory where the YAML files were generated
echo "directory=${ghaPath##*/}" >> "$GITHUB_OUTPUT"
