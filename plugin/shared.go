// Package pluginshared holds the go-plugin wiring shared between the
// sonar bridge host and every VCS plugin binary: the transport handshake
// config and the GRPCPlugin bridge for the PluginInfo service. Both
// sides must agree on this exact content or the handshake fails — which
// is the whole point of it living in this SDK module rather than being
// duplicated (and drifting) between sonarbridge-go and each plugin repo.
package plugin

import (
	"context"

	goplugin "github.com/hashicorp/go-plugin"
	"google.golang.org/grpc"

	pluginv1 "github.com/nivekalara237/ci-bridge-plugin-sdk/plugin/v1"
)

// Handshake is go-plugin's transport-level handshake: a coarse sanity
// check (right binary, compatible wire protocol) performed before any
// business handshake (GetInfo). Its ProtocolVersion is independent of
// InfoResponse.protocol_version in the proto contract — bump this only
// on a breaking wire-format change.
var Handshake = goplugin.HandshakeConfig{
	ProtocolVersion:  1,
	MagicCookieKey:   "CI_BRIDGE_PLUGIN",
	MagicCookieValue: "vcs",
}

// PluginKey is the name both sides Dispense/register under.
const PluginKey = "vcs"

// InfoGRPCPlugin bridges the generated PluginInfo gRPC service
// into go-plugin's plugin.GRPCPlugin interface. The same type serves
// both sides: Impl is nil on the host (only GRPCClient is ever invoked
// there) and set to a real implementation on the plugin binary (only
// GRPCServer is ever invoked there).
type InfoGRPCPlugin struct {
	goplugin.NetRPCUnsupportedPlugin
	Impl pluginv1.PluginInfoServer
}

func (p *InfoGRPCPlugin) GRPCServer(broker *goplugin.GRPCBroker, s *grpc.Server) error {
	pluginv1.RegisterPluginInfoServer(s, p.Impl)
	return nil
}

func (p *InfoGRPCPlugin) GRPCClient(ctx context.Context, broker *goplugin.GRPCBroker, c *grpc.ClientConn) (interface{}, error) {
	return pluginv1.NewPluginInfoClient(c), nil
}

// Map is the plugin map passed to both plugin.ClientConfig (host side,
// impl left nil) and plugin.ServeConfig (plugin binary, impl set).
func Map(impl pluginv1.PluginInfoServer) map[string]goplugin.Plugin {
	return map[string]goplugin.Plugin{
		PluginKey: &InfoGRPCPlugin{Impl: impl},
	}
}
