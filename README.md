# artifact-context

A GitHub action to generate an OpenContext YAML definition for your artifacts in your pipeline. The following artifact types are supported:
* sbom
* package
* container
* image

## Usage
In general you will need to do the following to make use of this GitHub action:

* Generate artifact
* Upload artifact somewhere and make the location (URI/URL) of the artifact an output of a step
* Pass the location of the artifact to this GitHub action
* Save OpenContext YAML to the current repo or to another GitHub repo
  * Use the output `filename` for the path to tar-gzipped file containing all the YAML generated
  * Use the output `directory` for the path to the directory containing all the YAML generated

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

  - name: Save OpenContext YAML
    with:
      path: ${{ steps.generate-artifact-context.outputs.filename }}
      directory: ${{ steps.generate-artifact-context.outputs.directory }}
```

### Generate a YAML definition for a package artifact
This is mean for any kind of package that is generated as part of a build. For instance, NPM, pip, etc.
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
