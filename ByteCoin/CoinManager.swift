

import Foundation
protocol coinManagerDelegate{
    func didUpdate(coin: CoinModel)
    func didFailedWithError(error: Error)
}
struct CoinManager {
    var delegate: coinManagerDelegate?
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "234A1CF6-FAE8-4086-B60F-60BC501891A9"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String){
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print(urlString)
        performRequest(url: urlString)
    }
    
    func performRequest(url: String){
        if let url = URL(string: url){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, responce, error in
                if error != nil{
                    delegate?.didFailedWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    print(safeData)
                    if let coin =  self.parseJSON(coinData: safeData) {
                        self.delegate?.didUpdate(coin: coin)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(coinData: Data) -> CoinModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            let asset_id_quote = decodedData.asset_id_quote
            print(rate)
            print(asset_id_quote)
            let coin = CoinModel(rate: rate, asset_id_quote: asset_id_quote)
            return coin
        } catch {
            delegate?.didFailedWithError(error: error)
            print(error)
            return nil
        }
    }
}
