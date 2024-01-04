# Dockerfile template

This Dockerfile repository serves as a template for me to conveniently copy and paste, enabling me to quickly start new projects. These files are extracted from my previous projects, and they cannot be used directly. They preserve the unique configurations of the original projects, along with my personal preferences and coding style. Kindly exercise caution when using them.

> [!WARNING]  
> Please be aware that this repository is fully licensed under the GPLv3.

The following is a README template that can be copied for use. It is not intended to describe the specific template repository. Please search for `jim60105/Dockerfile-template` and `source/Dockerfile-template` and replace them with the name of the new repository.

> [!NOTE]  
> Highlights information that users should take into account, even when skimming.

> [!TIP]
> Optional information to help a user be more successful.

> [!IMPORTANT]  
> Crucial information necessary for users to succeed.

> [!WARNING]  
> Critical content demanding immediate user attention due to potential risks.

> [!CAUTION]
> Negative potential consequences of an action.

# Project Name

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/Dockerfile-template/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/Dockerfile-template) [![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/jim60105/Dockerfile-template/scan.yml?label=IMAGE%20SCAN&style=for-the-badge)](https://github.com/jim60105/Dockerfile-template/actions/workflows/scan.yml)

This is the docker image for [Source/Project: Project details.](https://github.com/source/Dockerfile-template) from the community.

Get the Dockerfile at [GitHub](https://github.com/jim60105/Dockerfile-template), or pull the image from [ghcr.io](https://ghcr.io/jim60105/Dockerfile-template) or [quay.io](https://quay.io/repository/jim60105/Dockerfile-template?tab=tags).

## Usage Command

Mount the current directory as `/output` and run Dockerfile-template with additional input arguments.  
The downloaded files will be saved to where you run the command.

```bash
docker run -it -v ".:/output" ghcr.io/jim60105/Dockerfile-template [options] [url]
```

The `[options]`, `[url]` placeholder should be replaced with the options and arguments for Dockerfile-template. Check the [Dockerfile-template README](https://github.com/source/Dockerfile-template?tab=readme-ov-file#usage) for more information.

You can find all available tags at [ghcr.io](https://github.com/jim60105/Dockerfile-template/pkgs/container/Dockerfile-template/versions?filters%5Bversion_type%5D=tagged) or [quay.io](https://quay.io/repository/jim60105/Dockerfile-template?tab=tags).

## Available tags

This repository contains three Dockerfiles for building Docker images based on different base images:

| Dockerfile                                     | Base Image                                                                                                                         |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [alpine.Dockerfile](alpine.Dockerfile)         | [Python official image 3.11-alpine](https://hub.docker.com/_/python/)                                                              |
| [ubi.Dockerfile](ubi.Dockerfile)               | [Red Hat Universal Base Image 9 Minimal](https://catalog.redhat.com/software/containers/ubi9/ubi-minimal/615bd9b4075b022acc111bf5) |
| [distroless.Dockerfile](distroless.Dockerfile) | [Google Distroless python3-debian12](https://github.com/GoogleContainerTools/distroless)                                           |

And, built with the following code version of Dockerfile-template: main branch, v2.2.0, v2.1.3.

| Code Version                                                                | Alpine                    | UBI          | Distroless          |
| --------------------------------------------------------------------------- | ------------------------- | ------------ | ------------------- |
| [main branch](https://github.com/source/Dockerfile-template)                | `alpine`, `latest`        | `ubi`        | `distroless`        |
| [v2.2.0](https://github.com/source/Dockerfile-template/releases/tag/v2.2.0) | `v2.2.0`, `v2.2.0-alpine` | `v2.2.0-ubi` | `v2.2.0-distroless` |
| [v2.1.3](https://github.com/source/Dockerfile-template/releases/tag/v2.1.3) | `v2.1.3`, `v2.1.3-alpine` | `v2.1.3-ubi` | `v2.1.3-distroless` |

> [!TIP]
> I've notice that that both the UBI version and the Distroless version offer no advantages over the Alpine version. So _**please use the Alpine version**_ unless you have specific reasons not to. All of these base images are great, some of them were simply not that suitable for our project.

### Build Command

> [!IMPORTANT]  
> Clone the Git repository recursively to include submodules:  
> `git clone --recursive https://github.com/jim60105/Dockerfile-template.git`

> [!NOTE]  
> If you are using an earlier version of the docker client, it is necessary to [enable the BuildKit mode](https://docs.docker.com/build/buildkit/#getting-started) when building the image. This is because I used the `COPY --link` feature which enhances the build performance and was introduced in Buildx v0.8.  
> With the Docker Engine 23.0 and Docker Desktop 4.19, Buildx has become the default build client. So you won't have to worry about this when using the latest version.

For example, if you want to build the alpine image:

```bash
docker build -f alpine.Dockerfile -t Dockerfile-template:alpine .
```

## LICENSE

> [!NOTE]  
> The main program, [source/Dockerfile-template](https://github.com/source/Dockerfile-template), is distributed under [MIT](https://github.com/source/Dockerfile-template/blob/main/LICENSE).  
> Please consult their repository for access to the source code and licenses.  
> The following is the license for the Dockerfiles and CI workflows in this repository.

> [!CAUTION]
> A GPLv3 licensed Dockerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute a image that uses code from this repository.
> - Or **distribute a image based on this image**. (`FROM ghcr.io/jim60105/Dockerfile-template` in your Dockerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.

<img src="https://github.com/jim60105/Dockerfile-template/assets/16995691/ea799bbb-d531-4514-baee-13874322ec48" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
