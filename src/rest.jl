###############################################################################################################
##############################################option symbols###################################################
###############################################################################################################
##pulls the option chain from REST API
function option_chain(optionsymbols)
    head = ["Authorization" => "Bearer "*auth_key.access_token]
    url = "https://api.tdameritrade.com/v1/marketdata/chains?"
    total_ocd = Vector{String}()
    tickers = split(equity_info.ticker, ",") #split tickers from string
    for i in 1:size(tickers,1)
        params = HTTP.escapeuri([
            "symbol" => tickers[i]
        ])
        option_chain_data = @pipe HTTP.get("$url$params", head).body |> JSON3.read
        ocd = option_symbols_parse(option_chain_data)
        append!(total_ocd, ocd)
    end
    put!(optionsymbols, OptionSymbols(join(total_ocd,",")))
end

##parses symbol_option format used by TDA from the option chain
function option_symbols_parse(option_chain_data)
    ocd = Vector{String}()
    for (k1, v1) in option_chain_data[:callExpDateMap]
        for(k2, v2) in v1
            push!(ocd, v2[1][:symbol]) #push as string
        end
    end
    for (k1, v1) in option_chain_data[:putExpDateMap]
        for(k2, v2) in v1
            push!(ocd, v2[1][:symbol])
        end
    end
    return ocd
end

##main function to obtain option symbols; timer = 0 indicates one time pull; timer = 1440 indicates once per day
function option_symbols(optionsymbols, timer)
    if timer == 0
        option_chain(optionsymbols)
    elseif timer > 0
        while timer > 0
            @info "Updating options from option chain.."
            option_chain(optionsymbols)
            @info "Completed"
            sleep(timer)
        end
    end
end
###############################################################################################################
##############################################option symbols###################################################
###############################################################################################################
