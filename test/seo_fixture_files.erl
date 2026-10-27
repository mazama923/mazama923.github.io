-module(seo_fixture_files).
-export([create_directory/1, create_directory_all/1, write/2, read/1, delete/1]).

create_directory(Path) ->
    result(file:make_dir(Path)).

create_directory_all(Path) ->
    result(filelib:ensure_dir(<<Path/binary, "/placeholder">>)).

write(Path, Content) ->
    result(file:write_file(Path, Content)).

read(Path) ->
    case file:read_file(Path) of
        {ok, Content} -> {ok, Content};
        {error, Reason} -> {error, error_message(Reason)}
    end.

delete(Path) ->
    result(file:del_dir_r(Path)).

result(ok) -> {ok, nil};
result({error, Reason}) -> {error, error_message(Reason)}.

error_message(Reason) ->
    unicode:characters_to_binary(file:format_error(Reason)).
