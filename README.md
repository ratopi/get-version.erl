# get-version

The get-version script writes a file containing
* the current git commit hash (from env GIT_COMMIT)
* the current git branch (from env GIT_BRANCH)
* the current git tag (from env GIT_TAG)
* the version from rebar.conf

And another text file containing all tags for tagging the Docker-container.

## Use

Just write the following to your Dockerfile

	RUN wget https://ratopi.github.io/get-version.erl/get-version.erl
	RUN chmod +x get-version.erl
	RUN ./get-version.erl rebar.config additional.config TAGS

Two files will be written:
* additional.config : Containing an erlang-term with version, git commit hash and git branch name
* TAGS : Containing docker image tag names to be used in a outer docker building script
