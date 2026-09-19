module github.com/nivekalara237/ci-bridge-plugin-sdk

go 1.27.0

require (
	github.com/hashicorp/go-plugin v1.8.0
	google.golang.org/grpc v1.84.0
	google.golang.org/protobuf v1.36.12
)

require (
	github.com/fatih/color v1.13.0 // indirect
	github.com/golang/protobuf v1.5.4 // indirect
	github.com/hashicorp/go-hclog v1.6.3 // indirect
	github.com/hashicorp/yamux v0.1.2 // indirect
	github.com/mattn/go-colorable v0.1.12 // indirect
	github.com/mattn/go-isatty v0.0.17 // indirect
	github.com/oklog/run v1.1.0 // indirect
	golang.org/x/net v0.57.0 // indirect
	golang.org/x/sys v0.47.0 // indirect
	golang.org/x/text v0.40.0 // indirect
	google.golang.org/genproto v0.0.0-20200526211855-cb27e3aa2013 // indirect
)

//
//replace google.golang.org/grpc => github.com/grpc/grpc-go v1.38.0
//
//replace google.golang.org/protobuf => github.com/protocolbuffers/protobuf-go v1.28.2-0.20230222093303-bc1253ad3743
//
//replace golang.org/x/net => github.com/golang/net v0.17.0
//
//replace golang.org/x/sync => github.com/golang/sync v0.0.0-20220722155255-886fb9371eb4
//
//replace golang.org/x/sys => github.com/golang/sys v0.13.0
//
//replace golang.org/x/text => github.com/golang/text v0.13.0
//
//replace google.golang.org/genproto => github.com/googleapis/go-genproto v0.0.0-20200526211855-cb27e3aa2013
//
//replace golang.org/x/oauth2 => github.com/golang/oauth2 v0.0.0-20180821212333-d2e6202438be
//
//replace golang.org/x/xerrors => github.com/golang/xerrors v0.0.0-20191204190536-9bdfabe68543
//
//replace golang.org/x/crypto => github.com/golang/crypto v0.14.0
//
//replace golang.org/x/term => github.com/golang/term v0.13.0
//
//replace golang.org/x/lint => github.com/golang/lint v0.0.0-20190313153728-d0100b6bd8b3
//
//replace golang.org/x/tools => github.com/golang/tools v0.0.0-20190524140312-2c0ae7006135
//
//replace golang.org/x/mod => github.com/golang/mod v0.8.0
//
//replace honnef.co/go/tools => github.com/dominikh/go-tools v0.0.0-20190523083050-ea95bdfd59fc
//
//replace gopkg.in/yaml.v2 => github.com/go-yaml/yaml v0.0.0-20181115110504-51d6538a90f8
//
//replace gopkg.in/check.v1 => github.com/go-check/check v0.0.0-20161208181325-20d25e280405
