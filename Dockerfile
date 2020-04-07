FROM bdwyertech/skopeo as skopeo

FROM python:3.8-alpine

ARG BUILD_DATE
ARG VCS_REF

LABEL org.opencontainers.image.title="bfscloud/ecs-deploy" \
      org.opencontainers.image.version=$VCS_REF \
      org.opencontainers.image.description="For handling ECS deployments within a CI Environment" \
      org.opencontainers.image.authors="Broadridge - Cloud Platform Engineering <oss@broadridge.com>" \
      org.opencontainers.image.url="https://hub.docker.com/r/bfscloud/ecs-deploy" \
      org.opencontainers.image.source="https://github.com/broadridge/dkr-ecs-deploy.git" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE \
      org.label-schema.name="bfscloud/ecs-deploy" \
      org.label-schema.description="For handling ECS deployments within a CI Environment" \
      org.label-schema.url="https://hub.docker.com/r/bfscloud/ecs-deploy" \
      org.label-schema.vcs-url="https://github.com/broadridge/dkr-ecs-deploy.git"\
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE

COPY --from=skopeo /etc/containers/policy.json /etc/containers/policy.json
COPY --from=skopeo /usr/local/bin/skopeo /usr/local/bin/skopeo
COPY --from=skopeo /usr/local/bin/helper-utility /usr/local/bin/helper-utility

ENV PYTHONUNBUFFERED 1

ADD requirements.txt .
RUN apk add --no-cache bash ca-certificates device-mapper-libs gpgme \
    && apk add --no-cache --virtual .build-deps git libgit2 \
    && python -m pip install --upgrade pip \
    && python -m pip install -r requirements.txt \
    && apk del .build-deps \
    && rm requirements.txt \
    && rm -rf ~/.cache/pip \
    && adduser ecsdeploy -S -h /home/ecsdeploy

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

USER ecsdeploy
WORKDIR /home/ecsdeploy
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bash"]
