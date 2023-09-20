# artifact-context

A GitHub action to generate an OpenContext YAML definition for your artifacts in your pipeline. The following artifact types are supported:

- sbom
- package
- container
- image

**NOTE**: If the GITHUB_ACTOR for the pipeline is a bot, then a YAML definition will also be created for the bot.

## Usage

In general you will need to do the following to make use of this GitHub action:

- Generate artifact
- Upload artifact somewhere and make the location (URI/URL) of the artifact an output of a step
- Pass the location of the artifact to this GitHub action
- Optionally pass the directory to save the YAML files to
- Save OpenContext YAML to either:
  - the current repo or
  - to another GitHub repo
- Use the output `filename` for the path to oc-artifact-yaml.tgz _file_ containing all the generated YAML
- Use the output `directory` for the path to the _directory_ containing all the generated YAML

### Generate a YAML definition for a SBOM artifact

```
steps:
  - name: generate-sbom

  - id: upload-sbom-get-url
    name: Upload SBOM somewhere and make the url the output of this step

  - id: generate-artifact-context
    uses: opencontextinc/artifact-context@v1.0.0
    with:
      type: sbom
      url: ${{ steps.upload-sbom-get-url.outputs.url }}
      # save the YAML to sbom directory instead of the default oc-artifact-yaml uncomment the next line
      #directory: sbom

  - name: Save OpenContext YAML
    with:
      path: ${{ steps.generate-artifact-context.outputs.filename }}
      directory: ${{ steps.generate-artifact-context.outputs.directory }}
```

### Generate a YAML definition for a package artifact

This is meant for any kind of package that is generated as part of a build, such as NPM, pip, etc.

```
steps:
  - name: generate-package

  - id: upload-package-get-url
    name: Upload package somewhere and make the url the output of this step

  - id: generate-artifact-context
    uses: opencontextinc/artifact-context@v1.0.0
    with:
      type: package
      url: ${{ steps.upload-package-get-url.outputs.url }}

  - name: Save OpenContext YAML
    with:
      path: ${{ steps.generate-artifact-context.outputs.filename }}
      directory: ${{ steps.generate-artifact-context.outputs.directory }}
```

### Generate a YAML definition for a container artifact

```
steps:
  - name: generate-container

  - id: push-container-to-registry
    name: Push container to registry and make the container image location (registry/container_name:tag) the output of this step. For example,  opencontextinc/artifact-context:latest

  - id: generate-artifact-context
    uses: opencontextinc/artifact-context@v1.0.0
    with:
      type: container
      url: ${{ steps.push-container-to-registry.outputs.url }}

  - name: Save OpenContext YAML
    with:
      path: ${{ steps.generate-artifact-context.outputs.filename }}
      directory: ${{ steps.generate-artifact-context.outputs.directory }}
```

### Generate a YAML definition for an image artifact

This is meant for virtual machine images, AMIs, etc.

```
steps:
  - name: generate-image

  - id: upload-image-get-url
    name: Upload image somewhere and make the uri the output of this step

  - id: generate-artifact-context
    uses: opencontextinc/artifact-context@v1.0.0
    with:
      type: image
      url: ${{ steps.upload-image-get-url.outputs.url }}

  - name: Save OpenContext YAML
    with:
      path: ${{ steps.generate-artifact-context.outputs.filename }}
      directory: ${{ steps.generate-artifact-context.outputs.directory }}
```

### Using these YAML files with OpenContext

In order for OpenContext to process these files you will need to do the following:

- **De-duplicate the files generated**. If the same file is found multiple times then there will be a conflict, and the artifact or bot described in the YAML file will not appear in the catalog. This GitHub action will generate the same filename for the same artifact and bot. As long as the YAML generated is not modified after generation, you should be able to just replace the old file with a new one if a new one is generated.
- **Save these files to a locations known to OpenContext**:
  - Commit these files to a repository that is for OpenContext YAML. For example, see the [opencontext repository](https://github.com/scatter-ly/opencontext) or the [scatter.ly repository](https://github.com/scatter-ly/scatter.ly) in our demo GitHub organization [scatter-ly](https://github.com/scatter-ly).
  - Concatenate the contents of the files generated into an `oc-catalog.yaml` file and commit it to the root of your current repository. For example, see the [retail-app repository](https://github.com/scatter-ly/retail-app) in [scatter-ly](https://github.com/scatter-ly), our demo GitHub organization.
  - Upload these files to the catalog files location for your tenant. See our [docs](https://docs.opencontext.com/docs/getting-started/client-portal#catalog-files) for more information.
