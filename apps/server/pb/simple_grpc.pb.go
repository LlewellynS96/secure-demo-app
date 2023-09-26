// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.3.0
// - protoc             v4.22.2
// source: simple.proto

package pb

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

const (
	RemoteProcedureCall_Bidirectional_FullMethodName = "/RemoteProcedureCall/Bidirectional"
)

// RemoteProcedureCallClient is the client API for RemoteProcedureCall service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type RemoteProcedureCallClient interface {
	Bidirectional(ctx context.Context, opts ...grpc.CallOption) (RemoteProcedureCall_BidirectionalClient, error)
}

type remoteProcedureCallClient struct {
	cc grpc.ClientConnInterface
}

func NewRemoteProcedureCallClient(cc grpc.ClientConnInterface) RemoteProcedureCallClient {
	return &remoteProcedureCallClient{cc}
}

func (c *remoteProcedureCallClient) Bidirectional(ctx context.Context, opts ...grpc.CallOption) (RemoteProcedureCall_BidirectionalClient, error) {
	stream, err := c.cc.NewStream(ctx, &RemoteProcedureCall_ServiceDesc.Streams[0], RemoteProcedureCall_Bidirectional_FullMethodName, opts...)
	if err != nil {
		return nil, err
	}
	x := &remoteProcedureCallBidirectionalClient{stream}
	return x, nil
}

type RemoteProcedureCall_BidirectionalClient interface {
	Send(*Request) error
	Recv() (*Reply, error)
	grpc.ClientStream
}

type remoteProcedureCallBidirectionalClient struct {
	grpc.ClientStream
}

func (x *remoteProcedureCallBidirectionalClient) Send(m *Request) error {
	return x.ClientStream.SendMsg(m)
}

func (x *remoteProcedureCallBidirectionalClient) Recv() (*Reply, error) {
	m := new(Reply)
	if err := x.ClientStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

// RemoteProcedureCallServer is the server API for RemoteProcedureCall service.
// All implementations must embed UnimplementedRemoteProcedureCallServer
// for forward compatibility
type RemoteProcedureCallServer interface {
	Bidirectional(RemoteProcedureCall_BidirectionalServer) error
	mustEmbedUnimplementedRemoteProcedureCallServer()
}

// UnimplementedRemoteProcedureCallServer must be embedded to have forward compatible implementations.
type UnimplementedRemoteProcedureCallServer struct {
}

func (UnimplementedRemoteProcedureCallServer) Bidirectional(RemoteProcedureCall_BidirectionalServer) error {
	return status.Errorf(codes.Unimplemented, "method Bidirectional not implemented")
}
func (UnimplementedRemoteProcedureCallServer) mustEmbedUnimplementedRemoteProcedureCallServer() {}

// UnsafeRemoteProcedureCallServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to RemoteProcedureCallServer will
// result in compilation errors.
type UnsafeRemoteProcedureCallServer interface {
	mustEmbedUnimplementedRemoteProcedureCallServer()
}

func RegisterRemoteProcedureCallServer(s grpc.ServiceRegistrar, srv RemoteProcedureCallServer) {
	s.RegisterService(&RemoteProcedureCall_ServiceDesc, srv)
}

func _RemoteProcedureCall_Bidirectional_Handler(srv interface{}, stream grpc.ServerStream) error {
	return srv.(RemoteProcedureCallServer).Bidirectional(&remoteProcedureCallBidirectionalServer{stream})
}

type RemoteProcedureCall_BidirectionalServer interface {
	Send(*Reply) error
	Recv() (*Request, error)
	grpc.ServerStream
}

type remoteProcedureCallBidirectionalServer struct {
	grpc.ServerStream
}

func (x *remoteProcedureCallBidirectionalServer) Send(m *Reply) error {
	return x.ServerStream.SendMsg(m)
}

func (x *remoteProcedureCallBidirectionalServer) Recv() (*Request, error) {
	m := new(Request)
	if err := x.ServerStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

// RemoteProcedureCall_ServiceDesc is the grpc.ServiceDesc for RemoteProcedureCall service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var RemoteProcedureCall_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "RemoteProcedureCall",
	HandlerType: (*RemoteProcedureCallServer)(nil),
	Methods:     []grpc.MethodDesc{},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "Bidirectional",
			Handler:       _RemoteProcedureCall_Bidirectional_Handler,
			ServerStreams: true,
			ClientStreams: true,
		},
	},
	Metadata: "simple.proto",
}