#modified from the TDAmeritrade Julia package

##initial authentication
function initial_auth()
    @info "open the url in browser and copy the apikey back"
    auth_url = HTTP.URI(
        host="auth.tdameritrade.com",
        scheme="https",
        path="/auth",
        query = [
            "response_type" => "code",
            "redirect_uri" => auth_key.callback_url,
            "client_id"=>"$(auth_key.consumer_key)@AMER.OAUTHAP"
        ]
    )
end

##get access token
function access_token(code)
    url = "https://api.tdameritrade.com/v1/oauth2/token"
    params = HTTP.escapeuri([
        "grant_type" => "authorization_code",
        "refresh_token" => "",
        "access_type" => "offline",
        "code" => code,
        "client_id" => auth_key.consumer_key,
        "redirect_uri" => auth_key.callback_url
    ])
    json_result = HTTP.post(
        url,
        ["Content-Type"=>"application/x-www-form-urlencoded"],
        params
    ).body |> String |> JSON3.read
    json_result
end

##refrest access token
function refresh(refresh_token, force)
    if now() - auth_key.last_refresh < Minute(29) && !force
        @info "Refresh not needed"
        return auth_key.access_token
    end
    url = "https://api.tdameritrade.com/v1/oauth2/token"
    params = HTTP.escapeuri([
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token,
        "access_type" => "",
        "code" => "",
        "client_id" => auth_key.consumer_key,
        "redirect_uri" => ""
    ])
    json_result = HTTP.post(
        url,
        ["Content-Type"=>"application/x-www-form-urlencoded"],
        params
    ).body |> String |> JSON3.read
    auth_key.last_refresh = now()
    json_result[:access_token]
end

##call REST API userprincipals
function userprincipals()
    head = ["Authorization" => "Bearer "*auth_key.access_token]
    url = "https://api.tdameritrade.com/v1/userprincipals?fields=streamerSubscriptionKeys,streamerConnectionInfo"
    wss_data = @pipe HTTP.get(url, head).body |> JSON3.read
    wss_auth_key.userid = wss_data[:accounts][1][:accountId]
    wss_auth_key.token = wss_data[:streamerInfo][:token]
    wss_auth_key.company = wss_data[:accounts][1][:company]
    wss_auth_key.segment = wss_data[:accounts][1][:segment]
    wss_auth_key.cddomain = wss_data[:accounts][1][:accountCdDomainId]
    wss_auth_key.usergroup = wss_data[:streamerInfo][:userGroup]
    wss_auth_key.accesslevel = wss_data[:streamerInfo][:accessLevel]
    wss_auth_key.authorized = "Y"
    wss_auth_key.timestamp = parse_timestamp(wss_data[:streamerInfo][:tokenTimestamp], "+")
    wss_auth_key.appid = wss_data[:streamerInfo][:appId]
    wss_auth_key.acl = wss_data[:streamerInfo][:acl]
    urlt = wss_data[:streamerInfo][:streamerSocketUrl]
    wss_auth_key.wss_url = "wss://$urlt/ws"
    wss_auth_key.wss_key = wss_data[:streamerSubscriptionKeys][:keys][1][:key]
end

##auto refresh with 24 hour sleep
function auth_auto_refresh()
    while true
        if Date(auth_key.last_refresh) < today() - Day(89)
            refresh(auth_key.refresh_token, true)
            userprincipals()
            payload_subscribe, payload_login, payload_logout = build_payloads() #rebuilds payloads with new auth key(s)
            interrupt(workers()) #interupts current workings if refresh happens
            start_websocket_collection(payload_login, payload_subscribe, false) #restarts collection after interupt
        end
        sleep(86400) #24 hours
    end
end

##authenticate to TDA via HTTP
function TD_auth(force)
    cache_path = joinpath(homedir(), ".JL_TD_TOKENS_CACHE")
    if isfile(cache_path)
        last_refresh, last_date = readdlm(cache_path, ',')
        if Date(last_date) > today() - Day(89) # refresh token expires every 90 days
            auth_key.refresh_token = last_refresh
        else
            @info "Cached token is too old, getting new one"
        end
    end
    if auth_key.refresh_token == ""
        @info "First time auth needs manual invervention,"
        println(initial_auth())
        @info "extract code=<copy this> from address bar to here"
        print("code:")
        auth_key.code = readline() |> HTTP.URIs.unescapeuri
        token = access_token(auth_key.code)
        auth_key.access_token, auth_key.refresh_token = token[:access_token], token[:refresh_token]
        auth_key.last_refresh = now()
        @info "creating cache at $cache_path for tokens"
        open(cache_path, "w") do io
            writedlm(io, [auth_key.refresh_token today()], ',')
        end
        @info "Retrieving userprincipal data from API"
    else
        @info "REFRESH_TOKEN found, refreshing ACCESS_TOKEN"
        auth_key.access_token = refresh(auth_key.refresh_token, force)
    end
    @info "Authentication completed."
    nothing
end
