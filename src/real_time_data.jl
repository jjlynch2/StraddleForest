function StraddleForest()
    EQ = initialize_equity_quote(equity_info)
    OQ = initialize_option_quote(equity_info)
    TS = initialize_timesales(equity_info)
    OBT = initialize_orderbook_total(equity_info)
    OBE = initialize_orderbook_exchange(equity_info)
    OOBT = initialize_option_orderbook_total(equity_info)
    OOBE = initialize_option_orderbook_exchange(equity_info)

    while true
        #can these by async? im not sure
        EQ_entry = realtime_equityquote()
        OQ_entry = realtime_optionquote()
        OBT_entry, OBE_entry = realtime_orderbook()
        OOBT_entry, OOBE_entry = realtime_option_orderbook()
        TS_entry = realtime_timesales()



    end

end

function realtime_equityquote()
    connect to questDB and pull data
end

function realtime_optionquote()
    connect to questDB and pull data
end

function realtime_timesales()
    connect to questDB and pull data
end

function realtime_realtime_orderbook()
    connect to questDB and pull data
end

function realtime_option_orderbook()
    connect to questDB and pull data
end
