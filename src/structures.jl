###############################################################################################################
##############################################equity info######################################################
###############################################################################################################
##equity struct
mutable struct equity
    ticker::String
end

equity() = equity("","")
###############################################################################################################
##############################################equity info######################################################
###############################################################################################################


###############################################################################################################
##############################################database info####################################################
###############################################################################################################
##database struct
mutable struct database_info
    address::String
    port::Int64
end

database_info() = database_info("", 0)
###############################################################################################################
##############################################database info####################################################
###############################################################################################################


###############################################################################################################
##############################################equity quote#####################################################
###############################################################################################################
##Equity Quote struct
@everywhere struct EquityQuote
    received_timestamp::Int64             #timestamp for received from websocket not trade
    ticker::String                        #0
    bid_price::Float64                    #1
    ask_price::Float64                    #2
    last_price::Float64                   #3
    bid_size::Float64                     #4
    ask_size::Float64                     #5
    ask_exchange_id::String               #6
    bid_exchange_id::String               #7
    total_volume::Int64                   #8
    last_size::Float64                    #9
    trade_time::Int64                     #10
    quote_time::Int64                     #11
    high_price::Float64                   #12
    low_price::Float64                    #13
    bid_tick::String                      #14
    close_price::Float64                  #15
    exchange_id::String                   #16
    marginable::String                    #17
    shortable::String                     #18
    quote_day::Int64                      #22
    trade_day::Int64                      #23
    volatility::Float64                   #24
    description::String                   #25
    last_id::String                       #26
    digits::Int64                         #27
    open_price::Float64                   #28
    net_change::Float64                   #29
    high_52_week::Float64                 #30
    low_52_week::Float64                  #31
    pe_ratio::Float64                     #32
    dividend_amount::Float64              #33
    dividend_yield::Float64               #34
    NAV::Float64                          #37
    fund_price::Float64                   #38
    exchange_name::String                 #39
    dividend_date::String                 #40
    is_reg_market_quote::String           #41
    is_reg_market_trade::String           #42
    reg_market_last_price::Float64        #43
    reg_market_last_size::Float64         #44
    reg_market_trade_time::Int64          #45
    reg_market_trade_day::Int64           #46
    reg_market_net_change::Float64        #47
    security_status::String               #48
    mark_price::Float64                   #49
    quote_time_in_long::Int64             #50
    trade_time_in_long::Int64             #51
    reg_market_trade_time_in_long::Int64  #52
end

@everywhere EquityQuote() = EquityQuote(-2^63, "", NaN, NaN, NaN, NaN, NaN, "", "", -2^63, NaN, -2^63, -2^63, NaN, NaN, "", NaN, "", "", "", -2^63, -2^63, NaN, "", "", -2^63, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, "", "", "", "", NaN, NaN, -2^63, -2^63, NaN, "", NaN, -2^63, -2^63, -2^63)
@everywhere Base.isempty(x::EquityQuote) = x.ticker == ""
###############################################################################################################
##############################################equity quote#####################################################
###############################################################################################################

###############################################################################################################
##############################################option quote#####################################################
###############################################################################################################
##Option Quote struct
@everywhere struct OptionQuote
    ticker::String                    #0
    option::String                    #0 split
    option_type::String               #0 split
    ticker_option::String             #0 split
    received_timestamp::Int64         #timestamp for received from websocket not trade
    description::String               #1
    bid_price::Float64                #2
    ask_price::Float64                #3
    last_price::Float64               #4
    high_price::Float64               #5
    low_price::Float64                #6
    close_price::Float64              #7
    total_volume::Int64               #8
    open_interest::Int64              #9
    volatility::Float64               #10
    quote_time::Int64                 #11
    trade_time::Int64                 #12
    money_intrinsic_value::Float64    #13
    quote_day::Int64                  #14
    trade_day::Int64                  #15
    expiration_year::Int64            #16
    multiplier::Float64               #17
    digits::Int64                     #18
    open_price::Float64               #19
    bid_size::Float64                 #20
    ask_size::Float64                 #21
    last_size::Float64                #22
    net_change::Float64               #23
    strike_price::Float64             #24
    contract_type::String             #25
    underlying::String                #26
    expiration_month::Int64           #27
    deliverables::String              #28
    time_value::Float64               #29
    expiration_day::Int64             #30
    days_to_expiration::Int64         #31
    delta::Float64                    #32
    gamma::Float64                    #33
    theta::Float64                    #34
    vega::Float64                     #35
    rho::Float64                      #36
    security_status::String           #37
    theoretical_option_value::Float64 #38
    underlying_price::Float64         #39
    uv_expiration_type::String        #40
    mark_price::Float64               #41
end

#using -2^63 as the null type for storage in questdb
@everywhere OptionQuote() = OptionQuote("","","","",-2^63,"", NaN, NaN, NaN, NaN, NaN, NaN, -2^63, -2^63, NaN, -2^63, -2^63, NaN, -2^63, -2^63, -2^63, NaN, -2^63, NaN, NaN, NaN, NaN, NaN, NaN, "", "", -2^63, "", NaN, -2^63, -2^63, NaN, NaN, NaN, NaN, NaN, "", NaN, NaN, "", NaN)
@everywhere Base.isempty(x::OptionQuote) = x.ticker == ""
###############################################################################################################
##############################################option quote#####################################################
###############################################################################################################


###############################################################################################################
##############################################order book fields################################################
###############################################################################################################
##total level orderbook struct
@everywhere struct OrderBookTotal
    ticker::String
    timestamp::Int64
    price::Float64
    total_volume::Int64
    num::Int64
    side::String
end

##exchange level orderbook struct
@everywhere struct OrderBookExchange
    ticker::String
    timestamp::Int64
    exchange::String
    price::Float64
    volume::Int64
    sequence::Int64
    side::String
end

@everywhere OrderBookTotal() = OrderBookTotal("", 0, NaN, 0, 0, "")
@everywhere OrderBookExchange() = OrderBookExchange("", 0, "", NaN, 0, 0, "")
@everywhere Base.isempty(x::OrderBookTotal) = x.ticker == ""
@everywhere Base.isempty(x::OrderBookExchange) = x.ticker == ""
###############################################################################################################
##############################################order book fields################################################
###############################################################################################################


###############################################################################################################
##############################################options order book fields########################################
###############################################################################################################
##total level options orderbook struct
@everywhere struct OptionsOrderBookTotal
    ticker::String                    #0
    option::String                    #0 split
    option_type::String               #0 split
    ticker_option::String             #0 split
    timestamp::Int64
    price::Float64
    total_volume::Int64
    num::Int64
    side::String
end

##exchange level options orderbook struct
@everywhere struct OptionsOrderBookExchange
    ticker::String                    #0
    option::String                    #0 split
    option_type::String               #0 split
    ticker_option::String             #0 split
    timestamp::Int64
    exchange::String
    price::Float64
    volume::Int64
    sequence::Int64
    side::String
end

@everywhere OptionsOrderBookTotal() = OptionsOrderBookTotal("","","","", 0, NaN, 0, 0, "")
@everywhere OptionsOrderBookExchange() = OptionsOrderBookExchange("", "", "", "", 0, "", NaN, 0, 0, "")
@everywhere Base.isempty(x::OptionsOrderBookTotal) = x.ticker == ""
@everywhere Base.isempty(x::OptionsOrderBookExchange) = x.ticker == ""
###############################################################################################################
##############################################options order book fields########################################
###############################################################################################################



###############################################################################################################
##############################################Time of Sales####################################################
###############################################################################################################
##time of sales struct
@everywhere struct TimeofSales
    ticker::String
    timestamp::Int64
    price::Float64
    trade_size::Int64
    bid_size::Int64
    sequence::Int64
end

@everywhere TimeofSales() = TimeofSales("",0,NaN,0,0,0)
@everywhere Base.isempty(x::TimeofSales) = x.ticker == ""
###############################################################################################################
##############################################Time of Sales####################################################
###############################################################################################################


###############################################################################################################
##############################################option symbols###################################################
###############################################################################################################
@everywhere struct OptionSymbols
    symbols::String
end

@everywhere OptionSymbols() = OptionSymbols("")
###############################################################################################################
##############################################option symbols###################################################
###############################################################################################################


###############################################################################################################
##############################################authentication###################################################
###############################################################################################################
##credentisl for initial authentication and refresh
mutable struct credentials
    consumer_key::String
    code::String
    access_token::String
    refresh_token::String
    callback_url::String
    last_refresh::DateTime
end

##wss credentisl for initial authentication and refresh
mutable struct wss_credentials
    userid::String
    token::String
    company::String
    segment::String
    cddomain::String
    usergroup::String
    accesslevel::String
    authorized::String
    timestamp::String
    appid::String
    acl::String
    wss_url::String
    wss_key::String
end

credentials() = credentials("", "", "", "","http://localhost",now()-Hour(1))
wss_credentials() = wss_credentials("","","","","","","","","","","","","")
global auth_key = credentials() #create auth details
global wss_auth_key = wss_credentials() #create wss auth details
###############################################################################################################
##############################################authentication###################################################
###############################################################################################################
