-module(cserver1).
-export([start/0, loop/0,calculate/1, my_spawn/3]).
start() -> my_spawn(cserver1, loop, []).	

calculate(What) ->
	rpc(What).

rpc(Request) ->
	cserver1 ! {self(), Request},
	receive
		{Pid, Response} ->
			io:format("rpc receive's Pid is ~p~n", [Pid]),
			Response;
		Other ->
		 	io:format("resceive other ~p", [Other])
    after 1000 ->
    	timeout
	end.

loop() ->
	receive			
		{From, {A, '+', B}} ->
			io:format("loop receive's Pid is ~p~n", [From]),
			From ! {self(), A + B}, 
			io:format("the add result is ~p~n", [A + B]),
			loop();
		{From, {A, '-', B}} ->
			From ! {self(), A - B},
			io:format("the sub result is ~p~n", [A - B]),
			loop();
		{From, {A, '*', B}} ->
			From ! {self(), A * B},
			io:format("the mul result is ~p~n", [A * B]),
			loop();
		{From, {A, '/', B}} ->
			io:format("loop receive's Pid is ~p~n", [From]),
				try From ! {self(), A div B} of
					_ -> 
			 			io:format("the division result is ~p~n", [A div B]),
						loop()
				catch
					 throw : X -> io:format("throw the Resson is ~p~n", [X]);   
					 error : X -> io:format("error the Resson is ~p~n", [X]),
					 	From ! {self(),{error, io:format("exit!!!")}},
					 	exit(X),
					 	loop();
 					 exit : X -> io:format("exit the Resson is ~p~n", [X])
				end;
		{From, Message} ->
			 From ! {self(),{error, Message}},
             exit(Message),
             loop()     											
	end.	

my_spawn(Mod, Func, Args) ->
	Pid = spawn(Mod, Func, Args),
	register(cserver1, Pid),
	spawn(fun() ->
			Ref = monitor(process, Pid),
			io:format("the monitor's Pid is: ~p~n",[Pid]),
			receive
				{'DOWN', Ref, process, Pid, Why} ->
					io:format("the my_spawn receive Pid is: ~p~n",[Pid]),
					io:format("died with:~p~n, now restart...",[Why]),
					my_spawn(Mod, Func, Args),
					process_flag(trap_exit,true),  
					io:format("restart complete ~n")
			end
		end),
		Pid.	






