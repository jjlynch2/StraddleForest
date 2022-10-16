## StraddleForest 0.0.1
Just uploading this to store the code. This isn't working yet. I'll get back to finishing it eventually.

Multi-core Julia platform for storing data from TD Aperitrade API in QuestDB for random forest modeling of options strategies.

#Authenticate to TDAmeritrade API
```javascript
TD_auth(true) #true to force access token refresh
```

#Call REST API to obtain websocket details from userprincipals
```javascript
userprincipals() #Requires TD_auth to succeed prior to calling
```

#Auto refresh access_token every 90 days
#Recalls userprincipals, interupts workers, rebuilds JSON payloads, and starts data collection on workers
```javascript
@async auth_auto_refresh() #Requires TD_auth to succeed prior
```

#Start auto refresh of option symbols per timer in minutes
```javascript
@async option_symbols(optionsymbols, timer = 9)
```

#Build payloads for websocket login, logout, orderbook subscribe, time of sales subscribe
```javascript
payload_subscribe, payload_login, payload_logout = build_payloads()
```

#Starts distributed data collection
```javascript
start_websocket_collection(payload_login, payload_subscribe, payload_login, subscribe_payloads, orderbook_total, orderbook_exchange, timeofsales, options_orderbook_total, options_orderbook_exchange, equityquote, optionquote, restart, db_info, false)
```
