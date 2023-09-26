import sys
from time import sleep

import grpc
from google.protobuf.json_format import MessageToJson

import simple_pb2, simple_pb2_grpc


def requests():
    while True:
        sleep(1_000_000)
        yield simple_pb2.Request()

def main():
    # channel = grpc.insecure_channel('localhost:30073')
    channel = grpc.insecure_channel('server:4000')
    stub = simple_pb2_grpc.RemoteProcedureCallStub(channel=channel)
    for message in stub.Bidirectional(requests()):
        print(MessageToJson(message), flush=True)


if __name__ == "__main__":
    main()
