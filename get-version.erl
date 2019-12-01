#!/usr/bin/env escript

main([RebarConfigFile, ConfigFile, TagsFile]) ->
	{ok, RebarConfig} = file:consult(RebarConfigFile),
	[{release, {_AppName, Version}, _} | _] = proplists:get_value(relx, RebarConfig),

	PropList =
		[
			{git_hash, (os:getenv("GIT_HASH"))},
			{git_branch, (os:getenv("GIT_BRANCH"))},
			{git_tag, (os:getenv("GIT_TAG"))},
			{version, Version}
		],

	write_config_file(ConfigFile, PropList),
	write_tags_file(TagsFile, Version, os:getenv("GIT_HASH"), os:getenv("GIT_BRANCH"));

main(_) ->
	io:fwrite("usage: get-version.erl <rebar.config-file> <output config file> <tags file>~n"),
	exit(1).



write_config_file(ConfigFile, PropList) ->

	FilteredPropList =
		lists:filter(
			fun
				({_, false}) -> false;
				(_) -> true
			end,
			PropList
		),

	Result = {env, FilteredPropList},

	Content = io_lib:format("~p.~n", [Result]),

	file:write_file(ConfigFile, Content).




write_tags_file(FileName, Version, GitHash, GitBranch) ->
	Tags =
		add_hash_tag(GitHash,
			add_branch_tag(GitBranch,
				get_tags(Version)
			)
		),

	Content =
		lists:foldl(
			fun(E, Acc) ->
				Acc ++ E ++ [$\n]
			end,
			"",
			Tags
		),
	file:write_file(FileName, Content).



add_hash_tag(false, Tags) ->
	Tags;

add_hash_tag(GitHash, Tags) ->
	["git-" ++ GitHash | Tags].



add_branch_tag(false, Tags) ->
	Tags;
add_branch_tag(GitBranch, Tags) ->
	Tag =
		lists:flatten([
			"branch-",
			string:replace(GitBranch, "/", "_", all)
		]),
	[Tag | Tags].



get_tags(Version) ->
	case is_productive_version(Version) of
		false ->
			["dev", Version];

		true ->
			["latest" | get_versions(Version)]
	end.



get_versions(Version) ->
	Parts = string:split(Version, ".", all),
	combine(Parts, []).



combine([], Acc) ->
	lists:reverse(Acc);

combine([H | T], []) ->
	combine(T, [H]);

combine([H | T], Acc = [Last | _]) ->
	combine(T, [Last ++ "." ++ H | Acc]).



is_productive_version([$0 | _]) ->
	false;
is_productive_version(Version) ->
	is_productive_version_loop(Version).



is_productive_version_loop([]) ->
	true;
is_productive_version_loop(_Version = [Digit | T]) when Digit >= $0, Digit =< $9 ->
	is_productive_version_loop(T);
is_productive_version_loop(_Version = [$., $. | _]) ->
	false;
is_productive_version_loop(_Version = [$. | T]) ->
	is_productive_version_loop(T);
is_productive_version_loop(_) ->
	false.
