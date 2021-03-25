import Foundation

protocol CountrySelectorViewOutput {
    func viewIsReady()
    func shouldRefresh()
    func didContinueButtonPress()
    func didSelectCountry(model: MarketCountryViewModel)
}
