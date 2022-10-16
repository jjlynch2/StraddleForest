##initialize empty structs per n tickers
function save_orderbook_total_snapshot(OBT, db_info)
    conn = LibPQ.Connection("""dbname=qdb host=$(db_info.address) port=8812 password=quest user=admin""")
    execute(conn, """DROP TABLE IF EXISTS 'TDA_orderbook_total_snapshot_$ticker';""")
    close(conn)
    cs = connect(db_info.address, db_info.port)
    for t in keys(OBT)
        for s in keys(OBT["$t"])
            for p in keys(OBT["t"]["$s"])
                payload = build_payload_orderbook_total(OBT["$t"]["$s"]["$p"])
                write(cs, (payload))
            end
        end
    end
    close(cs)
end

function save_orderbook_exchange_snapshot(OBE, db_info)
    conn = LibPQ.Connection("""dbname=qdb host=$(db_info.address) port=8812 password=quest user=admin""")
    execute(conn, """DROP TABLE IF EXISTS 'TDA_orderbook_exchange_snapshot_$ticker';""")
    close(conn)
    cs = connect(db_info.address, db_info.port)
    for t in keys(OBE)
        for s in keys(OBE["$t"])
            for p in keys(OBE["t"]["$s"])
                payload = build_payload_orderbook_exchange(OBE["$t"]["$s"]["$p"])
                write(cs, (payload))
            end
        end
    end
    close(cs)
end

function save_options_orderbook_exchange_snapshot(OOBE, db_info)
    conn = LibPQ.Connection("""dbname=qdb host=$(db_info.address) port=8812 password=quest user=admin""")
    execute(conn, """DROP TABLE IF EXISTS 'TDA_options_orderbook_exchange_snapshot_$ticker';""")
    close(conn)
    cs = connect(db_info.address, db_info.port)
    for t in keys(OOBE)
        for o in keys(OOBE["$t"])
            payload = build_payload_options_orderbook_exchange(OOBE["$t"]["$o"])
            write(cs, (payload))
        end
    end
    close(cs)
end

function save_options_orderbook_total_snapshot(OOBT, db_info)
    conn = LibPQ.Connection("""dbname=qdb host=$(db_info.address) port=8812 password=quest user=admin""")
    execute(conn, """DROP TABLE IF EXISTS 'TDA_options_orderbook_total_snapshot_$ticker';""")
    close(conn)
    cs = connect(db_info.address, db_info.port)
    for t in keys(OOBT)
        for o in keys(OOBT["$t"])
            payload = build_payload_options_orderbook_total(OOBT["$t"]["$o"])
            write(cs, (payload))
        end
    end
    close(cs)
end

##equity quote
function initialize_equity_quote(equity_info)
    tickers = split(equity_info.ticker, ",")
    n_tickers = length(tickers)
    EQ = EquityQuote(-2^63, "", NaN, NaN, NaN, NaN, NaN, "", "", -2^63, NaN, -2^63, -2^63, NaN, NaN, "", NaN, "", "", "", -2^63, -2^63, NaN, "", "", -2^63, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, "", "", "", "", NaN, NaN, -2^63, -2^63, NaN, "", NaN, -2^63, -2^63, -2^63)
    EQ_dict = Dict()
    for i in 1:length(tickers)
        tic = tickers[i]
        EQ_dict["$tic"] = EQ
    end
    return EQ_dict
end

##equity orderbook total
function initialize_orderbook_total(equity_info)
    tickers = split(equity_info.ticker, ",")
    n_tickers = length(tickers)
    OBT = OrderBookTotal("", 0, NaN, 0, 0, "")
    OB_dict = Dict()
    for i in 1:length(tickers)
        tic = tickers[i]
        OB_dict["$tic"]["ask"]["0"] = OBT
        OB_dict["$tic"]["bid"]["0"]  = OBT
    end
    return OB_dict
end


##equity orderbook exchange
function initialize_orderbook_exchange(equity_info)
    tickers = split(equity_info.ticker, ",")
    n_tickers = length(tickers)
    OBE = OrderBookExchange("", 0, "", NaN, 0, 0, "")
    OB_dict = Dict()
    for i in 1:length(tickers)
        tic = tickers[i]
        OB_dict["$tic"]["ask"]["0"] = OBE
        OB_dict["$tic"]["bid"]["0"]  = OBE
    end
    return OB_dict
end

##equity option quote
function initialize_option_quote(equity_info, payload_option)
    tickers = split(equity_info.ticker, ",")
    n_tickers = length(tickers)
    options = split(payload_option[:parameters][:keys],",")
    OQ = OptionQuote("","","","",-2^63,"", NaN, NaN, NaN, NaN, NaN, NaN, -2^63, -2^63, NaN, -2^63, -2^63, NaN, -2^63, -2^63, -2^63, NaN, -2^63, NaN, NaN, NaN, NaN, NaN, NaN, "", "", -2^63, "", NaN, -2^63, -2^63, NaN, NaN, NaN, NaN, NaN, "", NaN, NaN, "", NaN)
    OQ_dict = Dict()
    for i in 1:length(tickers)
        tic = tickers[i]
        otmp = options[contains.(options, tickers[i])]
        OQ_temp = Dict()
        for j in 1:length(otmp)
            opt = otmp[j]
            OQ_temp["$opt"] = OQ
        end
        OQ_dict["$tic"] = OQ_temp
    end
    return OQ_dict
end

##options orderbook total
function initialize_option_orderbook_total(equity_info, payload_option)
    tickers = split(equity_info.ticker, ",")
    n_tickers = length(tickers)
    options = split(payload_option[:parameters][:keys],",")
    OOBT = OptionsOrderBookTotal("","","","", 0, NaN, 0, 0, "")
    OOB_dict = Dict()
    for i in 1:length(tickers)
        tic = tickers[i]
        otmp = options[contains.(options, tickers[i])]
        OOB_temp = Dict()
        for j in 1:length(otmp)
            opt = otmp[j]
            OOB_temp["$opt"] = OOBT
        end
        OOB_dict["$tic"] = OOB_temp
    end
    return OOB_dict
end


##options orderbook exchange
function initialize_option_orderbook_exchange(equity_info, payload_option)
    tickers = split(equity_info.ticker, ",")
    n_tickers = length(tickers)
    options = split(payload_option[:parameters][:keys],",")
    OOBE = OptionsOrderBookExchange("", "", "", "", 0, "", NaN, 0, 0, "")
    OOB_dict = Dict()
    for i in 1:length(tickers)
        tic = tickers[i]
        otmp = options[contains.(options, tickers[i])]
        OOB_temp = Dict()
        for j in 1:length(otmp)
            opt = otmp[j]
            OOB_temp["$opt"] = OOBE
        end
        OOB_dict["$tic"] = OOB_temp
    end
    return OOB_dict
end


##replace our temporary "null" value with null value used in questdb
function questdb_int64_null(x::Int64)
    if x == -2^63 "0x8000000000000000L" else x end
end

##format time for subscribing payload
function parse_timestamp(ts::String, delim::String)
    p1, p2 = split(ts, delim)
    ut = datetime2unix(DateTime(p1)) * 1e3 #convert from seconds to miliseconds
    ms = parse(Float64, p2) #convert string to float
    @sprintf "%.0f" ut + ms #add miliseconds epoch with original miliseconds
end

##format time for milisecond epoch to nano for questdb
function parse_mili_to_nano(ts::Int64)
    @sprintf "%.0f" ts * 1e6
end

##write orderbook data to database
function save_orderbook_total(orderbooktotal, db_info, equity_info)
    OBT = initialize_orderbook_total(equity_info)
    cs = connect(db_info.address, db_info.port)
    snapshot_time = DateTime(1)
    while true
        OBT_entry = take!(orderbooktotal)
        if haskey(OBT[OBT_entry.ticker][OBT_entry.side], OBT_entry.price)
            for f in fieldnames(typeof(OBT_entry))
                t1 = OBT[OBT_entry.ticker][OBT_entry.side][OBT_entry.price][f]
                if t1 != OBE_entry[f] && t1 != NaN && t1 != "" && t1 != -2^63
                    OBT[OBT_entry.ticker][OBT_entry.side][OBT_entry.price][f] = OBT_entry[f]
                end
            end
        else
            OBT[OBT_entry.ticker][OBT_entry.side][OBT_entry.price] = OBT_entry
        end
        payload = build_payload_orderbook_total(OBT[OBT_entry.ticker][OBT_entry.side][OBT_entry.price])
        write(cs, (payload))
        if now() - snapshot_time >= Millisecond(300000) #5 minutes
            save_orderbook_total_snapshot(OBT, db_info) #save snapshot to separate table
            snapshot_time = now()
        end
    end
    close(cs)
end

function save_orderbook_exchange(orderbookexchange, db_info, equity_info)
    OBE = initialize_orderbook_exchange(equity_info)
    cs = connect(db_info.address, db_info.port)
    snapshot_time = DateTime(1)
    while true
        if !isopen(cs)
            cs = connect(db_info.address, db_info.port)
        end
        OBE_entry = take!(orderbookexchange)
        if haskey(OOBT[OBE_entry.ticker][OBE_entry.side], OBE_entry.price)
            for f in fieldnames(typeof(OBE_entry))
                t1 = OBE[OBE_entry.ticker][OBE_entry.side][OBE_entry.price][f]
                if t1 != OBE_entry[f] && t1 != NaN && t1 != "" && t1 != -2^63
                    OBE[OBE_entry.ticker][OBE_entry.side][OBE_entry.price][f] = OBE_entry[f]
                end
            end
        else
            OBE[OBE_entry.ticker][OBE_entry.side][OBE_entry.price] = OBE_entry
        end
        payload = build_payload_orderbook_exchange(OBE[OBE_entry.ticker][OBE_entry.side][OBE_entry.price])
        write(cs, (payload))
        if now() - snapshot_time >= Millisecond(300000) #5 minutes
            save_orderbook_exchange_snapshot(OBE, db_info) #save snapshot to separate table
            snapshot_time = now()
        end
    end
    close(cs)
end

#start both async within a single proc
function save_orderbook(orderbooktotal, orderbookexchange, db_info)
    @async save_orderbook_total(orderbooktotal, db_info)
    @async save_orderbook_exchange(orderbookexchange, db_info)
end

##write time of sales data to database
function save_timeofsales(timeofsales, db_info)
    cs = connect(db_info.address, db_info.port)
    while true
        if !isopen(cs)
            cs = connect(db_info.address, db_info.port)
        end
        payload = build_payload_timeofsales(take!(timeofsales))
        write(cs, (payload))
    end
    close(cs)
end



##write option orderbook data to database
function save_options_orderbook_total(optionsorderbooktotal, db_info, equity_info)
    OOBT = initialize_option_orderbook_total(equity_info)
    cs = connect(db_info.address, db_info.port)
    snapshot_time = DateTime(1)
    while true
        if !isopen(cs)
            cs = connect(db_info.address, db_info.port)
        end
        OOBT_entry = take!(optionsorderbooktotal)
        if haskey(OOBT[OOBT_entry.ticker], OOBT_entry.ticker_option)
            for f in fieldnames(typeof(OOBT_entry))
                t1 = OOBT[OOBT_entry.ticker][OOBT_entry.ticker_option][f]
                if t1 != OOBT_entry[f] && t1 != NaN && t1 != "" && t1 != -2^63
                    OOBT[OOBT_entry.ticker][OOBT_entry.ticker_option][f] = OOBT_entry[f]
                end
            end
        else
            OOBT[OOBT_entry.ticker][OOBT_entry.ticker_option] = OOBT_entry
        end
        payload = build_payload_options_orderbook_total(OOBT[OOBT_entry.ticker][OOBT_entry.ticker_option])
        write(cs, (payload))
        if now() - snapshot_time >= Millisecond(300000) #5 minutes
            save_options_orderbook_total_snapshot(OOBT, db_info) #save snapshot to separate table
            snapshot_time = now()
        end
    end
    close(cs)
end

function save_options_orderbook_exchange(optionsorderbookexchange, db_info, equity_info)
    OOBE = initialize_option_orderbook_exchange(equity_info)
    cs = connect(db_info.address, db_info.port)
    snapshot_time = DateTime(1)
    while true
        if !isopen(cs)
            cs = connect(db_info.address, db_info.port)
        end
        OOBE_entry = take!(optionsorderbookexchange)
        if haskey(OOBE[OOBE_entry.ticker], OOBE_entry.ticker_option)
            for f in fieldnames(typeof(OOBT_entry))
                t1 = OOBE[OOBE_entry.ticker][OOBE_entry.ticker_option][f]
                if t1 != OOBE_entry[f] && t1 != NaN && t1 != "" && t1 != -2^63
                    OOBE[OOBE_entry.ticker][OOBE_entry.ticker_option][f] = OOBE_entry[f]
                end
            end
        else
            OOBE[OOBE_entry.ticker][OOBE_entry.ticker_option] = OOBE_entry
        end
        payload = build_payload_options_orderbook_exchange(OOBE[OOBE_entry.ticker][OOBE_entry.ticker_option])
        write(cs, (payload))
        if now() - snapshot_time >= Millisecond(300000) #5 minutes
            save_options_orderbook_exchange_snapshot(OOBE, db_info) #save snapshot to separate table
            snapshot_time = now()
        end
    end
    close(cs)
end

#start both async within a single proc
function save_options_orderbook(optionsorderbooktotal, optionsorderbookexchange, db_info)
    @async save_options_orderbook_total(optionsorderbooktotal, db_info)
    @async save_options_orderbook_exchange(optionsorderbookexchange, db_info)
end


##take option quote from remote buffer
function save_option_quote(optionquote, db_info, equity_info, payload_option)
    OQ = initialize_option_quote(equity_info, payload_option)
    cs = connect(db_info.address, db_info.port)
    while true
        if !isopen(cs)
            cs = connect(db_info.address, db_info.port)
        end
        OQ_entry = take!(optionquote)
        if haskey(OQ[OQ_entry.ticker], OQ_entry.ticker_option)
            data_build = ["","","","",-2^63,"", NaN, NaN, NaN, NaN, NaN, NaN, -2^63, -2^63, NaN, -2^63, -2^63, NaN, -2^63, -2^63, -2^63, NaN, -2^63, NaN, NaN, NaN, NaN, NaN, NaN, "", "", -2^63, "", NaN, -2^63, -2^63, NaN, NaN, NaN, NaN, NaN, "", NaN, NaN, "", NaN]
            i = 1
            for f in fieldnames(typeof(OQ_entry)) #update local dictionary
                t1 = getfield(OQ_entry, f)
                t2 = getfield(OQ[OQ_entry.ticker][OQ_entry.ticker_option], f)
                if t1 != t2 && t1 != NaN && t1 != "" && t1 != -2^63
                    data_build[i] = t1
                else
                    data_build[i] = t2
                end
                i = i + 1
            end
            clean_data = OptionQuote(data_build[1],data_build[2],data_build[3],data_build[4],data_build[5],data_build[6],data_build[7],data_build[8],data_build[9],data_build[10],data_build[11],data_build[12],data_build[13],data_build[14],data_build[15],data_build[16],data_build[17],data_build[18],data_build[19],data_build[20],data_build[21],data_build[22],data_build[23],data_build[24],data_build[25],data_build[26],data_build[27],data_build[28],data_build[29],data_build[30],data_build[31],data_build[32],data_build[33],data_build[34],data_build[35],data_build[36],data_build[37],data_build[38],data_build[39],data_build[40],data_build[41],data_build[42],data_build[43],data_build[44],data_build[45],data_build[46])
            OQ[OQ_entry.ticker][OQ_entry.ticker_option] = clean_data
        else
            OQ[OQ_entry.ticker][OQ_entry.ticker_option] = OQ_entry
        end
        payload = build_payload_option_quote(OQ[OQ_entry.ticker][OQ_entry.ticker_option])
        write(cs, (payload))
    end
    close(cs)
end

##take equity quote from remote buffer
function save_equity_quote(equityquote, db_info, equity_info)
    EQ = initialize_equity_quote(equity_info)
    cs = connect(db_info.address, db_info.port)
    while true
        if !isopen(cs)
            cs = connect(db_info.address, db_info.port)
        end
        EQ_entry = take!(equityquote)
        for f in fieldnames(typeof(EQ_entry)) #update local dictionary
            t1 = EQ[EQ_entry.ticker][f]
            if t1 != EQ_entry[f] && t1 != NaN && t1 != "" && t1 != -2^63
                EQ[EQ_entry.ticker][f] = EQ_entry[f]
            end
        end
        payload = build_payload_equity_quote(EQ[EQ_entry.ticker])
        write(cs, (payload))
    end
    close(cs)
end

##builds payload to save equity quotes to database
function build_payload_equity_quote(x::EquityQuote)
    buff = IOBuffer()
    write(buff, "TDA_equity_quote_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "bid_price=$(getfield(x, :bid_price)),")
    write(buff, "ask_price=$(getfield(x, :ask_price)),")
    write(buff, "last_price=$(getfield(x, :last_price)),")
    write(buff, "bid_size=$(getfield(x, :bid_size)),")
    write(buff, "ask_size=$(getfield(x, :ask_size)),")
    write(buff, "ask_exchange_id=$(getfield(x, :ask_exchange_id)),")
    write(buff, "bid_exchange_id=$(getfield(x, :bid_exchange_id)),")
    write(buff, "total_volume=$(questdb_int64_null(getfield(x, :total_volume))),")
    write(buff, "last_size=$(getfield(x, :last_size)),")
    write(buff, "trade_time=$(questdb_int64_null(getfield(x, :trade_time))),")
    write(buff, "quote_time=$(questdb_int64_null(getfield(x, :quote_time))),")
    write(buff, "high_price=$(getfield(x, :high_price)),")
    write(buff, "low_price=$(getfield(x, :low_price)),")
    write(buff, "bid_tick=$(getfield(x, :bid_tick)),")
    write(buff, "close_price=$(getfield(x, :close_price)),")
    write(buff, "exchange_id=$(getfield(x, :exchange_id)),")
    write(buff, "marginable=$(getfield(x, :marginable)),")
    write(buff, "shortable=$(getfield(x, :shortable)),")
    write(buff, "quote_day=$(questdb_int64_null(getfield(x, :quote_day))),")
    write(buff, "trade_day=$(questdb_int64_null(getfield(x, :trade_day))),")
    write(buff, "volatility=$(getfield(x, :volatility)),")
    write(buff, "description=$(replace(getfield(x, :description), r"[']" => "")),")
    write(buff, "last_id=$(getfield(x, :last_id)),")
    write(buff, "digits=$(questdb_int64_null(getfield(x, :digits))),")
    write(buff, "open_price=$(getfield(x, :open_price)),")
    write(buff, "net_change=$(getfield(x, :net_change)),")
    write(buff, "high_52_week=$(getfield(x, :high_52_week)),")
    write(buff, "low_52_week=$(getfield(x, :low_52_week)),")
    write(buff, "pe_ratio=$(getfield(x, :pe_ratio)),")
    write(buff, "dividend_amount=$(getfield(x, :dividend_amount)),")
    write(buff, "dividend_yield=$(getfield(x, :dividend_yield)),")
    write(buff, "NAV=$(getfield(x, :NAV)),")
    write(buff, "fund_price=$(getfield(x, :fund_price)),")
    write(buff, "exchange_name=$(getfield(x, :exchange_name)),")
    write(buff, "dividend_date=$(getfield(x, :dividend_date)),")
    write(buff, "is_reg_market_quote=$(getfield(x, :is_reg_market_quote)),")
    write(buff, "is_reg_market_trade=$(getfield(x, :is_reg_market_trade)),")
    write(buff, "reg_market_last_price=$(getfield(x, :reg_market_last_price)),")
    write(buff, "reg_market_last_size=$(getfield(x, :reg_market_last_size)),")
    write(buff, "reg_market_trade_time=$(questdb_int64_null(getfield(x, :reg_market_trade_time))),")
    write(buff, "reg_market_trade_day=$(questdb_int64_null(getfield(x, :reg_market_trade_day))),")
    write(buff, "reg_market_net_change=$(getfield(x, :reg_market_net_change)),")
    write(buff, "security_status=$(getfield(x, :security_status)),")
    write(buff, "mark_price=$(getfield(x, :mark_price)),")
    write(buff, "quote_time_in_long=$(questdb_int64_null(getfield(x, :quote_time_in_long))),")
    write(buff, "trade_time_in_long=$(questdb_int64_null(getfield(x, :trade_time_in_long))),")
    write(buff, "reg_market_trade_time_in_long=$(questdb_int64_null(getfield(x, :reg_market_trade_time_in_long))) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end

##builds payload to save option quotes to database
function build_payload_option_quote(x::OptionQuote)
    buff = IOBuffer()
    write(buff, "TDA_option_quote_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "option=$(getfield(x, :option)),")
    write(buff, "option_type=$(getfield(x, :option_type)),")
    write(buff, "ticker_option=$(getfield(x, :ticker_option)),")
    write(buff, "description=$(replace(getfield(x, :description), r"[']" => "")),")
    write(buff, "bid_price=$(getfield(x, :bid_price)),")
    write(buff, "ask_price=$(getfield(x, :ask_price)),")
    write(buff, "last_price=$(getfield(x, :last_price)),")
    write(buff, "high_price=$(getfield(x, :high_price)),")
    write(buff, "low_price=$(getfield(x, :low_price)),")
    write(buff, "close_price=$(getfield(x, :close_price)),")
    write(buff, "total_volume=$(questdb_int64_null(getfield(x, :total_volume))),")
    write(buff, "open_interest=$(questdb_int64_null(getfield(x, :open_interest))),")
    write(buff, "volatility=$(getfield(x, :volatility)),")
    write(buff, "quote_time=$(getfield(x, :quote_time)),")
    write(buff, "trade_time=$(getfield(x, :trade_time)),")
    write(buff, "money_intrinsic_value=$(getfield(x, :money_intrinsic_value)),")
    write(buff, "quote_day=$(questdb_int64_null(getfield(x, :quote_day))),")
    write(buff, "trade_day=$(questdb_int64_null(getfield(x, :trade_day))),")
    write(buff, "expiration_year=$(questdb_int64_null(getfield(x, :expiration_year))),")
    write(buff, "multiplier=$(getfield(x, :multiplier)),")
    write(buff, "digits=$(questdb_int64_null(getfield(x, :digits))),")
    write(buff, "open_price=$(getfield(x, :open_price)),")
    write(buff, "bid_size=$(getfield(x, :bid_size)),")
    write(buff, "ask_size=$(getfield(x, :ask_size)),")
    write(buff, "last_size=$(getfield(x, :last_size)),")
    write(buff, "net_change=$(getfield(x, :net_change)),")
    write(buff, "strike_price=$(getfield(x, :strike_price)),")
    write(buff, "contract_type=$(getfield(x, :contract_type)),")
    write(buff, "underlying=$(getfield(x, :underlying)),")
    write(buff, "expiration_month=$(questdb_int64_null(getfield(x, :expiration_month))),")
    write(buff, "deliverables=$(getfield(x, :deliverables)),")
    write(buff, "time_value=$(getfield(x, :time_value)),")
    write(buff, "expiration_day=$(questdb_int64_null(getfield(x, :expiration_day))),")
    write(buff, "days_to_expiration=$(questdb_int64_null(getfield(x, :days_to_expiration))),")
    write(buff, "delta=$(getfield(x, :delta)),")
    write(buff, "gamma=$(getfield(x, :gamma)),")
    write(buff, "theta=$(getfield(x, :theta)),")
    write(buff, "vega=$(getfield(x, :vega)),")
    write(buff, "rho=$(getfield(x, :rho)),")
    write(buff, "security_status=$(getfield(x, :security_status)),")
    write(buff, "theoretical_option_value=$(getfield(x, :theoretical_option_value)),")
    write(buff, "underlying_price=$(getfield(x, :underlying_price)),")
    write(buff, "uv_expiration_type=$(getfield(x, :uv_expiration_type)),")
    write(buff, "mark_price=$(getfield(x, :mark_price)) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end

##builds payload to save orderbook data to database
function build_payload_orderbook_total(x::OrderBookTotal)
    buff = IOBuffer()
    write(buff, "TDA_orderbook_total_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "price=$(getfield(x, :price)),")
    write(buff, "total_volume=$(questdb_int64_null(getfield(x, :total_volume))),")
    write(buff, "num=$(questdb_int64_null(getfield(x, :num))),")
    write(buff, "side=$(getfield(x, :side)) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end

##builds payload to save orderbook data to database
function build_payload_orderbook_exchange(x::OrderBookExchange)
    buff = IOBuffer()
    write(buff, "TDA_orderbook_exchange_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "exchange=$(getfield(x, :exchange)),")
    write(buff, "price=$(getfield(x, :price)),")
    write(buff, "volume=$(questdb_int64_null(getfield(x, :volume))),")
    write(buff, "sequence=$(questdb_int64_null(getfield(x, :sequence))),")
    write(buff, "side=$(getfield(x, :side)) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end

##builds payload to save time of sales data to database
function build_payload_timeofsales(x::TimeofSales)
    buff = IOBuffer()
    write(buff, "TDA_timeofsales_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "price=$(getfield(x, :price)),")
    write(buff, "trade_size=$(questdb_int64_null(getfield(x, :trade_size))),")
    write(buff, "bid_size=$(questdb_int64_null(getfield(x, :bid_size))),")
    write(buff, "sequence=$(questdb_int64_null(getfield(x, :sequence))) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end

##builds payload to save orderbook data to database
function build_payload_options_orderbook_total(x::OptionsOrderBookTotal)
    buff = IOBuffer()
    write(buff, "TDA_options_orderbook_total_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "option=$(getfield(x, :option)),")
    write(buff, "option_type=$(getfield(x, :option_type)),")
    write(buff, "ticker_option=$(getfield(x, :ticker_option)),")
    write(buff, "price=$(getfield(x, :price)),")
    write(buff, "total_volume=$(questdb_int64_null(getfield(x, :total_volume))),")
    write(buff, "num=$(questdb_int64_null(getfield(x, :num))),")
    write(buff, "side=$(getfield(x, :side)) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end

##builds payload to save orderbook data to database
function build_payload_options_orderbook_exchange(x::OptionsOrderBookExchange)
    buff = IOBuffer()
    write(buff, "TDA_options_orderbook_exchange_$(getfield(x, :ticker)),")
    write(buff, "ticker=$(getfield(x, :ticker)),")
    write(buff, "option=$(getfield(x, :option)),")
    write(buff, "option_type=$(getfield(x, :option_type)),")
    write(buff, "ticker_option=$(getfield(x, :ticker_option)),")
    write(buff, "exchange=$(getfield(x, :exchange)),")
    write(buff, "price=$(getfield(x, :price)),")
    write(buff, "volume=$(questdb_int64_null(getfield(x, :volume))),")
    write(buff, "sequence=$(questdb_int64_null(getfield(x, :sequence))),")
    write(buff, "side=$(getfield(x, :side)) ")
    write(buff, "$(parse_mili_to_nano(questdb_int64_null(getfield(x, :received_timestamp))))")
    write(buff, "\n")
    String(take!(buff))
end
