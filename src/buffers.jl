##database buffers
const equityquote = RemoteChannel(()->Channel{EquityQuote}(2000));
const optionquote = RemoteChannel(()->Channel{OptionQuote}(2000));
const orderbooktotal = RemoteChannel(()->Channel{OrderBookTotal}(2000));
const orderbookexchange = RemoteChannel(()->Channel{OrderBookExchange}(2000));
const optionsorderbooktotal = RemoteChannel(()->Channel{OptionsOrderBookTotal}(2000));
const optionsorderbookexchange = RemoteChannel(()->Channel{OptionsOrderBookExchange}(2000));
const timeofsales = RemoteChannel(()->Channel{TimeofSales}(2000));
const optionsymbols = RemoteChannel(()->Channel{OptionSymbols}(1));
