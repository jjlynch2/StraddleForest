##StraddleForest
module StraddleForest
    #always start distributed first to load other libraries on all workers
    using Distributed

    #exports callable functions
    #export TD_auth, userprincipals, auto_refresh, start_collection, define_procs, option_symbols

    #load before defining procs?
    include("misc.jl") #only master process

    #specifies number of cores
    define_procs(7)

    #load after Distributed to all cores
    @everywhere using Pipe, HTTP, DelimitedFiles, WebSockets, Sockets, JSON3, Distributed, Dates, Printf

    include("structures.jl") #only master process (individual structs use @everywhere where needed)
    include("buffers.jl") #only master process
    include("auth.jl") #only master process
    include("rest.jl") #only master process
    #include("real_time_data.jl")

    @everywhere include("websockets.jl") #load on all processes
    @everywhere include("websockets_helpers.jl") #load on all processes
    @everywhere include("database.jl") #load on all processes

    #Enter parameters here
    auth_key.consumer_key = "" #TDA API Consumer Key
    db_info = database_info("192.168.0.2", 9009) #QuestDB details
    global equity_info = equity("NVDA") #Ticker



end
