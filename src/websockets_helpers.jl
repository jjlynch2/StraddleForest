
##############################################################################################################
##############################################Unsubs and resubs if new options are written#####################
###############################################################################################################
function check_available_options(optionsymbols)
    os = take!(optionsymbols).symbols
    if os != payload_subscribe[4][:parameters][:keys]
        #resplit into vectors
        s_os = split(os, ",")
        s_oso = split(payload_subscribe[4][:parameters][:keys], ",")
        new_options = Vector{String}()
        for i in s_os
            diff = true
            for j in s_oso
                if i == j
                    diff = false
                end
            end
            if diff
                push!(new_options, i)
            end
        end
        expired_options = Vector{String}()
        for i in s_oso
            diff = true
            for j in s_os
                if i == j
                    diff = false
                end
            end
            if diff
                deleteat!(s_oso, s_oso .== i)
            end
        end
        #payload_subscribe[4][:command] = "UNSUBS"
        #write(ws, JSON3.write(payload_subscribe[4])) #unsubscribe
        if length(new_options) > 0
            payload_subscribe[4][:parameters][:keys] = new_options #use new options
            write(ws, JSON3.write(payload_subscribe[4])) #resubscribe
            append!(s_oso, new_options)
            payload_subscribe[4][:parameters][:keys] = s_oso #update available options
        end
    end
end
###############################################################################################################
##############################################Unsubs and resubs if new options are written#####################
###############################################################################################################

##return call or put for option type
function optiontype(option)
    if contains(option, "C") "call" else "put" end
end

##return status code for response
function identify_data(data)
    if haskey(data, :response)
        if data.response[1][:service] == "ADMIN"
            if data.response[1][:command] == "LOGIN" && data.response[1][:content][:code] == 0
                @info "Websocket login successful"
                return 999
            elseif data.response[1][:command] == "LOGOUT" && data.response[1][:content][:code] == 0
                @info "Websocket logout successful"
                return 0
            elseif data.response[1][:command] == "QOS" && data.response[1][:content][:code] == 0
                qos = last(data.response[1][:content][:code], 1)
                @info "QOS updated to $qos"
                return nothing
            end
        elseif data.response[1][:service] == "NASDAQ_BOOK"
            if data.response[1][:content][:code] == 0
                @info "Subscription to level 2 NASDAQ_BOOK succeeded"
                return nothing
            end
        elseif data.response[1][:service]== "OPTIONS_BOOK"
            if data.response[1][:content][:code] == 0
                @info "Subscription to level 2 OPTIONS_BOOK succeeded"
                return nothing
            end
        elseif data.response[1][:service] == "TIMESALE_EQUITY"
            if data.response[1][:content][:code] == 0
                @info "Subscription to TIMESALE_EQUITY succeeded"
                return nothing
            end
        elseif data.response[1][:service] == "QUOTE"
            if data.response[1][:content][:code] == 0
                @info "Subscription to level 1 QUOTE succeeded"
                return nothing
            end
        elseif data.response[1][:service] == "OPTION"
            if data.response[1][:content][:code] == 0
                @info "Subscription to level 1 OPTION succeeded"
                return nothing
            end
        end
    elseif haskey(data, :notify)
        if  haskey(data[:notify][1], :heartbeat)
            @info "Heartbeat $(now())"
            return nothing
        end
    elseif haskey(data, :data)
        if data.data[1][:service] == "NASDAQ_BOOK"
            return 1
        elseif data.data[1][:service] == "OPTION_BOOK"
            return 2
        elseif data.data[1][:service] == "TIMESALE_EQUITY"
            return 3
        elseif data.data[1][:service] == "QUOTE"
            return 4
        elseif data.data[1][:service] == "OPTION"
            return 5
        end
    else
        return false #data received that we did not expect
    end
 end


##parse orderbook data
function parse_orderbook(data, orderbooktotal, orderbookexchange)
    timestamp = data.data[1][:content][1]["1"]
    ticker = data.data[1][:content][1][:key]
    ##################################
    ######higher level orderbook######
    ##################################
    for i in 1:size(data.data[1][:content][1]["2"],1)
        price = data.data[1][:content][1]["2"][i]["0"]
        total_volume = data.data[1][:content][1]["2"][i]["1"]
        num = data.data[1][:content][1]["2"][i]["2"]
        clean_data = OrderBookTotal(ticker, timestamp, price, total_volume, num, "bid")
        if !isempty(clean_data)
            put!(orderbooktotal, clean_data)
        end
        ##################################
        #######lower level orderbook######
        ##################################
        for j in 1:size(data.data[1][:content][1]["2"][i]["3"],1) #for each exchange per ask price
            exchange = data.data[1][:content][1]["2"][i]["3"][j]["0"] #exchange name
            volume = data.data[1][:content][1]["2"][i]["3"][j]["1"] #bid_volume
            sequence = data.data[1][:content][1]["2"][i]["3"][j]["2"] #sequence
            clean_data = OrderBookExchange(ticker, timestamp, exchange, price, volume, sequence, "bid")
            if !isempty(clean_data)
                put!(orderbookexchange, clean_data)
            end
        end
    end
    ##################################
    ######higher level orderbook######
    ##################################
    for i in 1:size(data.data[1][:content][1]["3"],1)
        price = data.data[1][:content][1]["3"][i]["0"]
        total_volume = data.data[1][:content][1]["3"][i]["1"]
        num = data.data[1][:content][1]["3"][i]["2"]
        clean_data = OrderBookTotal(ticker, timestamp, price, total_volume, num, "ask")
        if !isempty(clean_data)
            put!(orderbooktotal, clean_data)
        end
        ##################################
        #######lower level orderbook######
        ##################################
        for j in 1:size(data.data[1][:content][1]["3"][i]["3"],1) #for each exchange per ask price
            exchange = data.data[1][:content][1]["3"][i]["3"][j]["0"] #exchange name
            volume = data.data[1][:content][1]["3"][i]["3"][j]["1"] #ask_volume
            sequence = data.data[1][:content][1]["3"][i]["3"][j]["2"] #sequence
            clean_data = OrderBookExchange(ticker, timestamp, exchange, price, volume, sequence, "ask")
            if !isempty(clean_data)
                put!(orderbookexchange, clean_data)
            end
        end
    end
end


##parse timeofsales data
function parse_timeofsales(data, timeofsales)
    for i in 1:size(data.data[1][:content],1) #for each trade? does API aggregate?
        ticker = data.data[1][:content][i][:key]
        timestamp = data.data[1][:content][i]["1"]
        price = data.data[1][:content][i]["2"]
        trade_size = data.data[1][:content][i]["3"]
        bid_size = data.data[1][:content][i]["4"]
        sequence = data.data[1][:content][i][:seq]
        clean_data = TimeofSales(ticker, timestamp, price, trade_size, bid_size, sequence)
        println(clean_data)
        if !isempty(clean_data)
            put!(timeofsales, clean_data)
        end
    end
end


##parse options orderbook data
function parse_options_orberbook(data, optionsorderbooktotal, optionsorderbookexchange)
    for i in 1:size(data.data[1][:content],1)
        ticker_option = data.data[1][:content][i][:key]
        split_tic = split(ticker_option, "_")
        ticker = split_tic[1]
        option = split_tic[2]
        timestamp = data.data[1][:content][i]["1"]
        option_type = optiontype(option)
        ##########################################
        ######higher level options orderbook######
        ##########################################
        for j in 1:size(data.data[1][:content][i]["2"],1)
            clean_data = OptionsOrderBookTotal(ticker, option, option_type, ticker_option, timestamp, price, total_volume, num, "bid")
            if !isempty(clean_data)
               put!(optionsorderbooktotal, clean_data)
           end
            ##########################################
            #######lower level options orderbook######
            ##########################################
            for l in 1:size(data.data[1][:content][i]["2"][j]["3"],1)
                exchange = data.data[1][:content][i]["2"][j]["3"][l]["0"]
                volume = data.data[1][:content][i]["2"][j]["3"][l]["1"]
                sequence = data.data[1][:content][i]["2"][j]["3"][l]["2"]
                clean_data = OptionsOrderBookExchange(ticker, option, option_type, ticker_option, timestamp, exchange, price, volume, sequence, "bid")
                if !isempty(clean_data)
                    put!(optionsorderbookexchange, clean_data)
                end
            end
        end
        ##########################################
        ######higher level options orderbook######
        ##########################################
        for j in 1:size(data.data[1][:content][i]["3"],1)
            price = data.data[1][:content][i]["3"][j]["0"]
            total_volume = data.data[1][:content][i]["3"][j]["1"]
            num = data.data[1][:content][i]["3"][j]["2"]
            clean_data = OptionsOrderBookTotal(ticker, option, option_type, ticker_option, timestamp, price, total_volume, num, "ask")
            if !isempty(clean_data)
                put!(optionsorderbooktotal, clean_data)
            end
            ##########################################
            #######lower level options orderbook######
            ##########################################
            for l in 1:size(data.data[1][:content][i]["3"][j]["3"],1)
                exchange = data.data[1][:content][i]["3"][j]["3"][l]["0"]
                volume = data.data[1][:content][i]["3"][j]["3"][l]["1"]
                sequence = data.data[1][:content][i]["3"][j]["3"][l]["2"]
                clean_data = OptionsOrderBookExchange(ticker, option, option_type, ticker_option, timestamp, exchange, price, volume, sequence, "ask")
                if !isempty(clean_data)
                    put!(optionsorderbookexchange, clean_data)
                end
            end
        end
    end
end


##parse equity quote
function parse_equity_quote(data, equityquote)
    received_timestamp = data.data[1][:timestamp]
    for i in 1:size(data.data[1][:content],1)
        v1 = data.data[1][:content][i]
        #pull all keys/symbols
        key_strings = []
        for v2 in v1
            push!(key_strings, String(v2.first))
        end
        ticker = v1[key_strings[1]]
        data_start = [received_timestamp, ticker]
        data_build = [NaN, NaN, NaN, NaN, NaN, "", "", -2^63, NaN, -2^63, -2^63, NaN, NaN, "", NaN, "", "", "", -2^63, -2^63, NaN, "", "", -2^63, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, "", "", "", "", NaN, NaN, -2^63, -2^63, NaN, "", NaN, -2^63, -2^63, -2^63]
        for j in [1:18;22:34;37:52;]
            if any(key_strings .== "$j")
                if j >= 22 && j <= 34
                    jj = j - 3
                elseif j >= 37 && j <= 52
                    jj = j - 5
                else
                    jj = j
                end
                data_build[jj] = v1["$j"] #replace null with actual value if present
            end
        end
        appended_data = append!(data_start, data_build)
        clean_data = EquityQuote(appended_data[1],appended_data[2],appended_data[3],appended_data[4],appended_data[5],appended_data[6],appended_data[7],appended_data[8],appended_data[9],appended_data[10],appended_data[11],appended_data[12],appended_data[13],appended_data[14],appended_data[15],appended_data[16],appended_data[17],appended_data[18],appended_data[19],appended_data[20],appended_data[21],appended_data[22],appended_data[23],appended_data[24],appended_data[25],appended_data[26],appended_data[27],appended_data[28],appended_data[29],appended_data[30],appended_data[31],appended_data[32],appended_data[33],appended_data[34],appended_data[35],appended_data[36],appended_data[37],appended_data[38],appended_data[39],appended_data[40],appended_data[41],appended_data[42],appended_data[43],appended_data[44],appended_data[45],appended_data[46],appended_data[47],appended_data[48],appended_data[49])
        if !isempty(clean_data)
            put!(equityquote, clean_data) #push to buffer
        end
    end
end


##parse options quote
function parse_option_quote(data, optionquote)
    received_timestamp = data.data[1][:timestamp]
    for i in 1:size(data.data[1][:content],1)
        v1 = data.data[1][:content][i]
        #pull all keys/symbols
        key_strings = []
        for v2 in v1
            push!(key_strings, String(v2.first))
        end
        #pull key info
        ticker_option = v1[key_strings[1]]
        split_tic = split(ticker_option, "_")
        ticker = split_tic[1]
        option = split_tic[2]
        option_type = optiontype(option)
        #build out null data types for emptry values
        data_start = [ticker, option, option_type, ticker_option, received_timestamp]
        data_build = ["", NaN, NaN, NaN, NaN, NaN, NaN, -2^63, -2^63, NaN, -2^63, -2^63, NaN, -2^63, -2^63, -2^63, NaN, -2^63, NaN, NaN, NaN, NaN, NaN, NaN, "", "", -2^63, "", NaN, -2^63, -2^63, NaN, NaN, NaN, NaN, NaN, "", NaN, NaN, "", NaN]
        for j in 1:41
            if any(key_strings .== "$j")
                data_build[j] = v1["$j"] #replace null with actual value if present
            end
        end
        appended_data = append!(data_start, data_build)
        clean_data = OptionQuote(appended_data[1],appended_data[2],appended_data[3],appended_data[4],appended_data[5],appended_data[6],appended_data[7],appended_data[8],appended_data[9],appended_data[10],appended_data[11],appended_data[12],appended_data[13],appended_data[14],appended_data[15],appended_data[16],appended_data[17],appended_data[18],appended_data[19],appended_data[20],appended_data[21],appended_data[22],appended_data[23],appended_data[24],appended_data[25],appended_data[26],appended_data[27],appended_data[28],appended_data[29],appended_data[30],appended_data[31],appended_data[32],appended_data[33],appended_data[34],appended_data[35],appended_data[36],appended_data[37],appended_data[38],appended_data[39],appended_data[40],appended_data[41],appended_data[42],appended_data[43],appended_data[44],appended_data[45],appended_data[46])
        if !isempty(clean_data)
            put!(optionquote, clean_data) #push to buffer
        end
    end
end
