FROM python:3.12 AS base

ENV  PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"


FROM base as builder
RUN --mount=type=cache,target=/root/.cache \
    pip install poetry
WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN --mount=type=cache,target=$POETRY_HOME/pypoetry/cache \
    poetry install --no-root

FROM base as production
WORKDIR /usr/src/app

COPY --from=builder $VENV_PATH $VENV_PATH

COPY . .

ENV PYTHONUNBUFFERED=1

EXPOSE 5006

USER nobody:nogroup

CMD ["bash", "start_server.sh"]