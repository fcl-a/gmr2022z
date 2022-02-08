#FROM nginx:1.19.3-alpine
FROM python:3.8-alpine

ENV TZ=Asia/Shanghai
ENV APP_ROOT /code
ENV APP_VERSION 0.29.4

RUN apk add --no-cache --virtual .build-deps ca-certificates bash curl unzip php7
RUN apk add --update --no-cache curl python3-dev gcc g++ libc-dev \
    && rm -rf /var/cache/apk/*
    
RUN curl -sL https://github.com/aploium/zmirror/archive/v${APP_VERSION}.tar.gz | tar -xz -C / \
    && mkdir -p ${APP_ROOT} \
    && mv /zmirror-${APP_VERSION} ${APP_ROOT}/zmirror \
    && cd ${APP_ROOT}/zmirror \
    # && pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install gunicorn \
    && cat more_configs/config_google_and_zhwikipedia.py > config.py
    
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/static-html /usr/share/nginx/html/index
COPY nginx/h5-speedtest /usr/share/nginx/html/speedtest
COPY configure.sh /configure.sh
COPY v2ray_config /
RUN chmod +x /configure.sh

WORKDIR ${APP_ROOT}/zmirror

ENTRYPOINT ["sh", "/configure.sh"]

