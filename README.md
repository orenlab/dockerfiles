
# Dockerfiles

Simple, clear, and working Dockerfile templates for Python applications based on Alpine image.

## Features

- Multi-stage
- Targets
- Minimum image size

## Installation

Simple and intuitive installation and setup:

```bash
git clone https://github.com/orenlab/dockerfiles.git
```

Then open the `Dockerfile` in your preferred editor and make the necessary changes to the `paths` and `dependencies`.

## Usage/Examples

Dockerfile is configured to use two targets:
- For a `production` system

```bash
docker --target production build -t name/image:tag .
```

- For `development` system

```bash
docker --target development build -t name/image:tag .
```

## Authors

- [@orenlab](https://github.com/orenlab/dockerfiles)


## License

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/orenlab/dockerfiles/blob/main/LICENSE)


