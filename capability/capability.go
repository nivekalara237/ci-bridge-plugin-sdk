// Package capability lists the well-known VCS capability strings a
// plugin can declare in its InfoResponse.capabilities. Using these
// constants instead of free-form strings catches typos at compile time
// on both the host and plugin sides — but a plugin is free to declare
// any string; the host must never assume a capability exists just
// because these constants exist (see l'architecture, §Capabilities).
package capability

const (
	Repository               = "repository"
	Branch                   = "branch"
	PullRequest              = "pull_request"
	PullRequestCreateComment = "pull_request_create_comment"
	PullRequestUpdateComment = "pull_request_update_comment"
	PullRequestDeleteComment = "pull_request_delete_comment"
	Webhook                  = "webhook"
	Issue                    = "issue"
	Pipeline                 = "pipeline"
	Artifact                 = "artifact"
	User                     = "user"
	Organization             = "organization"
)
