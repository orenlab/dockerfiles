#############################################################
# Dockerfile (based on Alpine)
# https://github.com/orenlab/dockerfiles
#
# To run the application in a specific mode:
# docker --target production build -t name/image:tag .
# docker --target development build -t name/image:tag .
#############################################################

# Set Alpine tag version for all stage
ARG IMAGE_VERSION_FIRST=3.12.3-alpine3.19
ARG IMAGE_VERSION_SECOND=3.19.1

# Zero stage - setup base image
FROM alpine:$IMAGE_VERSION_SECOND AS base

# Update base os components
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
# Add Timezone support in Alpine image
    apk --no-cache add tzdata

# App workdir
WORKDIR /path/to/app

# Setup env var
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH=/path/to/app
ENV PATH=/venv/bin:$PATH

# Copy app
COPY ./app ./app/

# Copy lisence
COPY LICENSE /path/to/app

# First stage - build Python deps
FROM python:$IMAGE_VERSION_FIRST AS builder

# Python version
ARG PYTHON_VERSION=3.12

COPY requirements.txt .

# Installing dependencies to build Python packages. An example for psutil:
RUN apk --no-cache add gcc python3-dev musl-dev linux-headers

# Install dependencies to the venv path
RUN python$PYTHON_VERSION -m venv --without-pip venv
RUN pip install --no-cache-dir --target="/venv/lib/python${PYTHON_VERSION}/site-packages" \
    -r requirements.txt

# As a general rule, it is best to remove anything that is not essential for the operation of an application. 
# This reduces the surface area of a potential attack.
RUN python -m pip uninstall pip setuptools python3-wheel python3-dev musl-dev -y

# Second stage - based on the base stage.
FROM base AS production

# Python version
ARG PYTHON_VERSION=3.12

# Сopy only the necessary python files and directories from first stage
COPY --from=builder /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=builder /usr/local/bin/python$PYTHON_VERSION /usr/local/bin/python$PYTHON_VERSION
COPY --from=builder /usr/local/lib/python$PYTHON_VERSION /usr/local/lib/python$PYTHON_VERSION
COPY --from=builder /usr/local/lib/libpython$PYTHON_VERSION.so.1.0 /usr/local/lib/libpython$PYTHON_VERSION.so.1.0
COPY --from=builder /usr/local/lib/libpython3.so /usr/local/lib/libpython3.so

# Copy only the dependencies installation from the first stage image
COPY --from=builder /venv /venv

# activate venv
RUN source /venv/bin/activate && \
# forward logs to Docker's log collector
    ln -sf /dev/stdout /path/to/app/logs && \
    ln -sf /dev/stderr /path/to/app/logs

CMD [ "/venv/bin/python3", "app/main.py", "-args ...", "--kargs ..." ]

# Third stage - based on the base stage.
FROM base AS development

# Python version
ARG PYTHON_VERSION=3.12

# Сopy only the necessary python files and directories from first stage
COPY --from=builder /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=builder /usr/local/bin/python$PYTHON_VERSION /usr/local/bin/python$PYTHON_VERSION
COPY --from=builder /usr/local/lib/python$PYTHON_VERSION /usr/local/lib/python$PYTHON_VERSION
COPY --from=builder /usr/local/lib/libpython$PYTHON_VERSION.so.1.0 /usr/local/lib/libpython$PYTHON_VERSION.so.1.0
COPY --from=builder /usr/local/lib/libpython3.so /usr/local/lib/libpython3.so

# Copy only the dependencies installation from the first stage image
COPY --from=builder /venv /venv

# activate venv
RUN source /venv/bin/activate && \
# forward logs to Docker's log collector
    ln -sf /dev/stdout /path/to/app/logs && \
    ln -sf /dev/stderr /path/to/app/logs

CMD [ "/venv/bin/python3", "app/main.py", "-args ...", "--kargs ..." ]
