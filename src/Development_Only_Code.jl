    using Distributed
    include("misc.jl") #only master process
    @everywhere using Pipe, HTTP, DelimitedFiles, WebSockets, Sockets, JSON3, Distributed, Dates, Printf

    include("structures.jl")
    include("buffers.jl")
    include("auth.jl")
    include("rest.jl")
    @everywhere include("websockets.jl") #load on all processes
    @everywhere include("websockets_helpers.jl") #load on all processes
    @everywhere include("database.jl") #load on all processes
    auth_key.consumer_key = "" #TDA API Consumer Key
    db_info = database_info("192.168.0.1", 9009) #QuestDB details
    global equity_info = equity("INTC") #Ticker

    TD_auth(true)
    userprincipals()
    option_symbols(optionsymbols, 0)
    payload_subscribe, payload_login, payload_logout = build_payloads()

    #@async save_orderbook(orderbooktotal, orderbookexchange, db_info)
    #@async save_timeofsales(timeofsales, db_info)
    #@async save_options_orderbook(optionsorderbooktotal, optionsorderbookexchange, db_info)
    #@async save_equity_quote(equityquote, db_info)

    ps = payload_subscribe[[1,5]]

    @async open_websocket(wss_auth_key.wss_url, equity_info, payload_login, ps, orderbooktotal, orderbookexchange, timeofsales, optionsorderbooktotal, optionsorderbookexchange, equityquote, optionquote, optionsymbols, false)


    @async save_option_quote(optionquote, db_info, equity_info, ps[2])
