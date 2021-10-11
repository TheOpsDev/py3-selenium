ARG IMAGE_VERSION=3.11.0a1-alpine
FROM python:${IMAGE_VERSION}

LABEL image.os="alpine"
LABEL image.name="py3-selenium"
LABEL owner="Chris Herrera"
LABEL maintainer="christian@christian-herrera.com"
LABEL license="MIT"

# Packages required to support a headless Firefox
# ttf-dejavu required for Firefox page rendering
RUN apk upgrade --update-cache --available \
    && apk update \
    && apk add --no-cache xvfb firefox dbus ttf-dejavu ca-certificates curl

# Virual Display Server
RUN mkdir -p /etc/local.d/
COPY --chown=root:root ./bash/Xvfb.start /etc/local.d/Xvfb.start
RUN chmod 755 /etc/local.d/Xvfb.start

# Install pip3 packages
COPY requirements.txt /tmp/
RUN pip3 install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r /tmp/requirements.txt

# pip3 cleanup
RUN find -type d -name __pycache__ -prune -exec rm -rf {} \; && \
    rm -rf ~/.cache/pip

# Download geckodriver to support Firefox webdriver
WORKDIR /usr/local/bin/
RUN curl -L https://github.com/mozilla/geckodriver/releases/download/v0.30.0/geckodriver-v0.30.0-linux64.tar.gz \
    -s -o geckodriver_v30.tar.gz \
    && tar -xzf geckodriver_v30.tar.gz
RUN rm -rf geckodriver_v30.tar.gz

ENV PYTHONUNBUFFERED 1

WORKDIR /home

CMD ['python', '-h']
