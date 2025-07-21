# docker-yt-dlp

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/docker-yt-dlp/badge)](https://www.codefactor.io/repository/github/jim60105/docker-yt-dlp) [![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/jim60105/docker-yt-dlp/scan.yml?label=IMAGE%20SCAN)](https://github.com/jim60105/docker-yt-dlp/actions/workflows/scan.yml)

This is the docker image for [yt-dlp/yt-dlp: A youtube-dl fork with additional features and fixes](https://github.com/yt-dlp/yt-dlp) from the community.

Get the Dockerfile at [GitHub](https://github.com/jim60105/docker-yt-dlp), or pull the image from [ghcr.io](https://ghcr.io/jim60105/yt-dlp) or [quay.io](https://quay.io/repository/jim60105/yt-dlp?tab=tags).

## Usage Command

Mount the current directory as `/download` and run yt-dlp with additional input arguments.  
The downloaded files will be saved to where you run the command.

```bash
docker run -it -v ".:/download" ghcr.io/jim60105/yt-dlp [OPTIONS] [--] URL [URL...]
```

The `[OPTIONS]`, `[URL...]` placeholder should be replaced with the options and arguments for yt-dlp. Check the [yt-dlp README](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#usage-and-options) for more information.

You can find all available tags at [ghcr.io](https://github.com/jim60105/yt-dlp/pkgs/container/yt-dlp/versions?filters%5Bversion_type%5D=tagged) or [quay.io](https://quay.io/repository/jim60105/yt-dlp?tab=tags).

## Building the Docker Image

### Dockerfiles

This repository contains five Dockerfiles for building Docker images based on different base images:

| Dockerfile                                     | Base Image                                                                                                                         |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [Dockerfile](Dockerfile)                       | [Alpine official image](https://hub.docker.com/_/alpine/)                                                                          |
| [alpine.Dockerfile](alpine.Dockerfile)         | [Python official image 3.12-alpine](https://hub.docker.com/_/python/)                                                              |
| [ubi.Dockerfile](ubi.Dockerfile)               | [Red Hat Universal Base Image 9 Minimal](https://catalog.redhat.com/software/containers/ubi9/ubi-minimal/615bd9b4075b022acc111bf5) |
| [distroless.Dockerfile](distroless.Dockerfile) | [distroless-python](https://github.com/alexdmoss/distroless-python)                                                                |
| [pot.Dockerfile](pot.Dockerfile)               | [bgutil-ytdlp-pot-provider](https://hub.docker.com/r/brainicism/bgutil-ytdlp-pot-provider)                                          |

### Build Arguments

The [alpine.Dockerfile](alpine.Dockerfile), [ubi.Dockerfile](ubi.Dockerfile), [distroless.Dockerfile](distroless.Dockerfile), and [pot.Dockerfile](pot.Dockerfile) are built using a build argument called `BUILD_VERSION`. This argument represents [the release version of yt-dlp](https://github.com/yt-dlp/yt-dlp/tags), such as `2025.06.30` or `2025.06.25`.

The [pot.Dockerfile](pot.Dockerfile) also uses an additional `POT_PROVIDER_VERSION` argument to specify the version of the bgutil-ytdlp-pot-provider.

It is important to note that the [Dockerfile](Dockerfile) always builds with [the latest apk package source](https://pkgs.alpinelinux.org/package/edge/community/aarch64/yt-dlp), so it can't set the build version explicitly.

> [!NOTE]
>
> - The apk edge branch follows the latest release of yt-dlp.
> - The `alpine.Dockerfile` installs yt-dlp from pip source, so the image size may slightly different compared to the `Dockerfile` even when they have the same version.

### Build Command

```bash
docker build -t yt-dlp .
docker build --build-arg BUILD_VERSION=2025.06.30 -f ./alpine.Dockerfile -t yt-dlp:alpine .
docker build --build-arg BUILD_VERSION=2025.06.30 -f ./ubi.Dockerfile -t yt-dlp:ubi .
docker build --build-arg BUILD_VERSION=2025.06.30 -f ./distroless.Dockerfile -t yt-dlp:distroless .
docker build --build-arg BUILD_VERSION=2025.06.30 --build-arg POT_PROVIDER_VERSION=1.1.0 -f ./pot.Dockerfile -t yt-dlp:pot .
```

> [!TIP]
> I've notice that that both the UBI version and the Distroless version offer no advantages over the Alpine version. So _**please use the Alpine version**_ unless you have specific reasons not to. All of these base images are great, some of them were simply not that suitable for our project.
>
> If you're experiencing YouTube bot detection issues (HTTP 403 errors, "Sign in to confirm you're not a bot" messages), consider using the _**POT provider version**_ which includes automatic token generation to help bypass these restrictions.

> [!NOTE]  
> If you are using an earlier version of the docker client, it is necessary to [enable the BuildKit mode](https://docs.docker.com/build/buildkit/#getting-started) when building the image. This is because I used the `COPY --link` feature which enhances the build performance and was introduced in Buildx v0.8.  
> With the Docker Engine 23.0 and Docker Desktop 4.19, Buildx has become the default build client. So you won't have to worry about this when using the latest version.

## POT Provider Variant

The POT (Proof of Origin Token) provider variant is designed to help bypass YouTube's bot detection mechanisms. This variant includes the [bgutil-ytdlp-pot-provider](https://github.com/Brainicism/bgutil-ytdlp-pot-provider) which automatically generates POT tokens to make your yt-dlp requests appear more legitimate to YouTube's servers.

### Why Use POT Provider?

YouTube has implemented bot detection that may block download requests, resulting in:

- HTTP 403 errors during video downloads
- "Sign in to confirm you're not a bot" messages
- IP address or account blocking

The POT provider helps simulate a genuine client by generating proof-of-origin tokens that YouTube's servers expect from legitimate browser-based requests.

> [!WARNING]
> Providing a PO token does not guarantee bypassing 403 errors or bot checks, but it may help your traffic seem more legitimate to YouTube's servers.

### Usage with POT Provider

Use the POT variant with the `:pot` tag:

```bash
docker run -it -v ".:/download" ghcr.io/jim60105/yt-dlp:pot [OPTIONS] [--] URL [URL...]
```

The POT provider runs as a background service within the container and automatically provides tokens to yt-dlp when needed. No additional configuration is required for basic usage.

## LICENSE

> [!NOTE]  
> The main program, [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp), is distributed under [Unlicense license](https://github.com/yt-dlp/yt-dlp/blob/master/LICENSE).  
> Please consult their repository for access to the source code and licenses.  
> The following is the license for the Dockerfiles and CI workflows in this repository.

> [!CAUTION]  
> A GPLv3 licensed Containerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute an image that uses code from this repository.
> - Or **distribute an image based on this image**. (`FROM ghcr.io/jim60105/yt-dlp` in your Containerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.

<img src="https://github.com/jim60105/docker-yt-dlp/assets/16995691/f33f8175-af23-4a8a-ad69-efd17a7625f4" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

Copyright (C) 2024 Jim Chen <Jim@ChenJ.im>.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
