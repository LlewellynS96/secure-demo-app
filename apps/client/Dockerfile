FROM cache as cache
FROM python:3.11-slim

RUN apt update &&\
    apt install -y build-essential curl

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH=/root/.local/bin:$PATH

WORKDIR /src/app

COPY poetry.lock .
COPY pyproject.toml .
RUN poetry install

COPY --from=cache protobuf protobuf

RUN poetry run python -m grpc_tools.protoc -I ./protobuf/ --python_out=. --grpc_python_out=. simple.proto

COPY main.py .

CMD ["poetry", "run", "python", "main.py"]

