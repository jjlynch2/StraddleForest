##starts the stream and database collection on separate processes
#function start_websocket_collection(equity_info, payload_login, payload_subscribe, url, equity_info, payload_login, payload_subscribe, orderbooktotal, orderbookexchange, timeofsales, optionsorderbooktotal, optionsorderbookexchange, equityquote, optionquote, optionsymbols, restart, db_info)
#    @info "Starting websockets stream on worker 2  ..."
#    remotecall(open_websocket, 2, url, equity_info, payload_login, payload_subscribe, orderbooktotal, orderbookexchange, timeofsales, optionsorderbooktotal, optionsorderbookexchange, equityquote, optionquote, optionsymbols, restart)
#    @info "Started."
#
#    @info "Starting level 2 orderbook database write on worker 3 ..."
#    remotecall(save_orderbook, 3, orderbooktotal, orderbookexchange, db_info, equity_info)
#    @info "Started."
#
#    @info "Starting time of sales database write on worker 4 ..."
#    remotecall(save_timeofsales, 4, timeofsales, db_info)
#    @info "Started."
#
#    @info "Starting level 2 options orderbook database write on worker 5 ..."
#    remotecall(save_options_orderbook, 5, optionsorderbooktotal, optionsorderbookexchange, db_info, equity_info)
#    @info "Started."
#
#    @info "Starting level 1 equity quote database write on worker 6 ..."
#    remotecall(save_equity_quote, 6, equityquote, db_info, equity_info)
#    @info "Started."
#
#    @info "Starting level 1 option quote database write on worker 7 ..."
#    remotecall(save_option_quote, 7, optionquote, db_info, equity_info)
#    @info "Started."
#end

##Open websocket, login, subscribe, and call appropriate functions for data parsing
function open_websocket(url, equity_info, payload_login, payload_subscribe, orderbooktotal, orderbookexchange, timeofsales, optionsorderbooktotal, optionsorderbookexchange, equityquote, optionquote, optionsymbols, restart)
    WebSockets.open(url) do ws
        #send login and subscribe payloads
        if isopen(ws)
            write(ws, JSON3.write(payload_login)) #login
        end
        #loop over websocket to update
        while isopen(ws)
            #@async check_available_options(optionsymbols) #not sure how much this will slow things down
            #will async help this call? perhaps.
            data, success = readguarded(ws)
            if success
                data = JSON3.read(String(data)) #parse JSON response
                which_data = identify_data(data)
                if which_data == 999
                    for i in 1:length(payload_subscribe) #reverse so QOS runs first. Not sure if that is actually needed
                        write(ws, JSON3.write(payload_subscribe[i])) #subscribe if login is successful
                    end
                elseif which_data == 1
                    parse_orderbook(data, orderbooktotal, orderbookexchange)
                elseif which_data == 2
                    parse_options_orderbook(data, optionsorderbooktotal, optionsorderbookexchange)
                elseif which_data == 3
                    parse_timeofsales(data, timeofsales)
                elseif which_data == 4
                    parse_equity_quote(data, equityquote)
                elseif which_data == 5
                     parse_option_quote(data, optionquote)
                elseif which_data == 0 #succesful logout
                    return nothing
                end
            end
        end
        #restart if websocket closes using optional switch
        if restart && !isopen(ws)
            open_websocket(url, equity_info, payload_login, payload_subscribe, orderbooktotal, orderbookexchange, timeofsales, optionsorderbooktotal, optionsorderbookexchange, equityquote, optionquote, optionsymbols, restart)
        end
    end
end #open_websocket
