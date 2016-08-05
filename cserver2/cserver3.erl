-module(cserver3).
-export([calculate/1]).	

calculate(What) ->
%	rpc:call(l@debian,cserver3,calculate,[What]),
	rpc(What).

rpc(Request) ->
	cserver2 ! {self(), Request},
	receive
		{Pid, Response} ->
			io:format("rpc receive's Pid is ~p~n", [Pid]),
			Response;
		Other ->
			io:format("resceive other ~p", [Other])
    after 1000 ->
    	timeout
	end.