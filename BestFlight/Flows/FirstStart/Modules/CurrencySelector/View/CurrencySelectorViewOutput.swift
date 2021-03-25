import Foundation

protocol CurrencySelectorViewOutput {
    func viewIsReady()
    func shouldRefresh()
    func didSelectCurrency(model: MarketCurrencyViewModel)
    func didContinueButtonPress()
}
