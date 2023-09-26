FROM cache as cache
FROM golang:1.18.3

RUN apt update &&\
    apt install -y protobuf-compiler

WORKDIR /src/app

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

COPY --from=cache protobuf protobuf

COPY go.* .
COPY main.go .

RUN mkdir -p pb
RUN protoc -I ./protobuf/ --go_out=./pb --go-grpc_out=./pb simple.proto

CMD ["go", "run", "main.go"]
