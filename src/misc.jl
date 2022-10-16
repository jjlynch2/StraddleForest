###############################################################################################################
##############################################helper functions#################################################
###############################################################################################################
##setup procs helper function
function define_procs(procs)
    if nprocs() < procs
        addprocs(procs - nprocs())
    end
end

##build payloads for websockets
function build_payloads()
    ##pull ticker from buffer
    ticker_symbols = take!(optionsymbols).symbols
    ##QOS websocket payload
    payload_qos = Dict(
        :service => "ADMIN",
        :command => "QOS",
        :requestid => "1",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :qoslevel => 0 #0 = 500ms, 1 = 750ms, 2 = 1000ms, 3 = 1500ms, 4 = 3000ms, 5 = 5000ms
        )
    )
    ##login websocket payload
    payload_login = Dict(
        :service => "ADMIN",
        :command => "LOGIN",
        :requestid => "1",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :credential => HTTP.escapeuri([
                :userid => wss_auth_key.userid,
                :token => wss_auth_key.token,
                :company => wss_auth_key.company,
                :segment => wss_auth_key.segment,
                :cddomain => wss_auth_key.cddomain,
                :usergroup => wss_auth_key.usergroup,
                :accesslevel => wss_auth_key.accesslevel,
                :authorized => wss_auth_key.authorized,
                :timestamp => wss_auth_key.timestamp,
                :appid => wss_auth_key.appid,
                :acl => wss_auth_key.acl
            ]),
            :token => wss_auth_key.token,
            :version => "1.0"
        )
    )
    ##logout websocket payload
    payload_logout = Dict(
        :service => "ADMIN",
        :requestid => "1",
        :command => "LOGOUT",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => ""
    )
    ##level 1 equity quote websocket payload
    payload_quote = Dict(
        :service => "QUOTE",
        :requestid => "1",
        :command => "SUBS",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :keys => equity_info.ticker,
            :fields => join([0:18;22:34;37:52;], ",")
        )
    )
    ##level 1 option quote websocket payload
    payload_option = Dict(
        :service => "OPTION",
        :requestid => "1",
        :command => "SUBS",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :keys => ticker_symbols, #pull symbols from buffer
            :fields => join([0:41;], ",")
        )
    )
    ##orderbook websocket payload
    payload_orderbook = Dict(
        :service => "NASDAQ_BOOK",
        :requestid => "1",
        :command => "SUBS",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :keys => equity_info.ticker,
            :fields => "0,1,2,3"
        )
    )
    ##time of sales websocket payload
    payload_timeofsales = Dict(
        :service => "TIMESALE_EQUITY",
        :requestid => "1",
        :command => "SUBS",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :keys => equity_info.ticker,
            :fields => "0,1,2,3,4"
        )
    )
    ##orderbook websocket payload
    payload_optionsorderbook = Dict(
        :service => "OPTIONS_BOOK",
        :requestid => "1",
        :command => "SUBS",
        :account => wss_auth_key.userid,
        :source => wss_auth_key.appid,
        :parameters => Dict(
            :keys => ticker_symbols,
            :fields => "0,1,2,3"
        )
    )
    payload_subscribe = [payload_qos, payload_orderbook, payload_timeofsales, payload_optionsorderbook, payload_option, payload_quote]
    return payload_subscribe, payload_login, payload_logout
end
###############################################################################################################
##############################################helper functions#################################################
###############################################################################################################
