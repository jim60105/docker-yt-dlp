# docker-yt-dlp

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/docker-yt-dlp/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/docker-yt-dlp) [![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/jim60105/docker-yt-dlp/scan.yml?label=IMAGE%20SCAN&style=for-the-badge)](https://github.com/jim60105/docker-yt-dlp/actions/workflows/scan.yml)

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

## Available tags

This repository contains three Dockerfiles for building Docker images based on different base images:

| Dockerfile                                     | Base Image                                                                                                                         |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [alpine.Dockerfile](alpine.Dockerfile)         | [Python official image 3.12-alpine](https://hub.docker.com/_/python/)                                                              |
| [ubi.Dockerfile](ubi.Dockerfile)               | [Red Hat Universal Base Image 9 Minimal](https://catalog.redhat.com/software/containers/ubi9/ubi-minimal/615bd9b4075b022acc111bf5) |
| [distroless.Dockerfile](distroless.Dockerfile) | [Google Distroless python3-debian12](https://github.com/GoogleContainerTools/distroless)                                           |

And, built with the following code version of yt-dlp: 2023.12.30, 2023.11.16, 2023.10.13.

| Code Version                                                                | Alpine                    | UBI          | Distroless          |
| --------------------------------------------------------------------------- | ------------------------- | ------------ | ------------------- |
| [2023.12.30](https://github.com/yt-dlp/yt-dlp/releases/tag/2023.12.30) | `2023.12.30`, `2023.12.30-alpine` | `2023.12.30-ubi` | `2023.12.30-distroless` |
| [2023.11.16](https://github.com/yt-dlp/yt-dlp/releases/tag/2023.11.16) | `2023.11.16`, `2023.11.16-alpine` | `2023.11.16-ubi` | `2023.11.16-distroless` |
| [2023.10.13](https://github.com/yt-dlp/yt-dlp/releases/tag/2023.10.13) | `2023.10.13`, `2023.10.13-alpine` | `2023.10.13-ubi` | `2023.10.13-distroless` |

> [!TIP]
> I've notice that that both the UBI version and the Distroless version offer no advantages over the Alpine version. So _**please use the Alpine version**_ unless you have specific reasons not to. All of these base images are great, some of them were simply not that suitable for our project.

### Build Command

> [!NOTE]  
> If you are using an earlier version of the docker client, it is necessary to [enable the BuildKit mode](https://docs.docker.com/build/buildkit/#getting-started) when building the image. This is because I used the `COPY --link` feature which enhances the build performance and was introduced in Buildx v0.8.  
> With the Docker Engine 23.0 and Docker Desktop 4.19, Buildx has become the default build client. So you won't have to worry about this when using the latest version.

For example, if you want to build the alpine image:

```bash
docker build -f alpine.Dockerfile -t yt-dlp:alpine .
```

## LICENSE

> [!NOTE]  
> The main program, [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp), is distributed under [Unlicense license](https://github.com/yt-dlp/yt-dlp/blob/master/LICENSE).  
> Please consult their repository for access to the source code and licenses.  
> The following is the license for the Dockerfiles and CI workflows in this repository.

> [!CAUTION]
> A GPLv3 licensed Dockerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute a image that uses code from this repository.
> - Or **distribute a image based on this image**. (`FROM ghcr.io/jim60105/yt-dlp` in your Dockerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.

<img src="https://github.com/jim60105/docker-yt-dlp/assets/16995691/f33f8175-af23-4a8a-ad69-efd17a7625f4" alt="gplv3" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
