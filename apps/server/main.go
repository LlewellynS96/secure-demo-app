package main

import (
	"fmt"
	"io"
	"log"
	"net"

	"google.golang.org/grpc"
	"github.com/llewellyns96/secure-demo-app/apps/server/pb"
	)

func main() {
	lis, err := net.Listen("tcp", ":4000")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	var opts []grpc.ServerOption

	grpcServer := grpc.NewServer(opts...)
	pb.RegisterRemoteProcedureCallServer(grpcServer, &Server{})

	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}


type Server struct {
        pb.UnimplementedRemoteProcedureCallServer
}

func (s *Server) Bidirectional(srv pb.RemoteProcedureCall_BidirectionalServer) error  {
	ctx := srv.Context()
	count := 0
        for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}

                _, err := srv.Recv()
                if err == io.EOF {
                        log.Println("eof error")
			return nil
                }
                if err != nil {
			log.Printf("receive error %v", err)
                        continue
                }
                if err := srv.Send(&pb.Reply{Data: fmt.Sprintf("Received %d.", count)}); err != nil {
                        log.Printf("send error %v", err)
                }

		count++
        }
}
