import Foundation

protocol CountrySelectorViewInput: AlertPresentableView {
    func setupInitialState()
    func showLoading()
    func hideLoading()
    func endRefreshing()
    func showItems(items: [MarketCountryViewModel])
    func setContinueButtonEnabled()
    func setContinueButtonDisabled()
}
