import Foundation

protocol CurrencySelectorViewInput: AlertPresentableView {
    func setupInitialState()
    func showLoading()
    func hideLoading()
    func endRefreshing()
    func showItems(items: [MarketCurrencyViewModel])
    func setContinueButtonEnabled()
    func setContinueButtonDisabled()
}
