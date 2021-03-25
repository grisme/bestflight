import UIKit

// MARK: - CountrySelectorViewController implementation 

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// TODO: Move button and tableview implementation onto some Base class
// To prevent code doubling
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

final class CountrySelectorViewController: UIViewController {

    // MARK: Appearance

    struct Appearance {
        let backgroundColor: UIColor = .normalBackground

        let continueInsets: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
    }
    private let appearance = Appearance()

    // MARK: Properties

    private let presenter: CountrySelectorViewOutput
    private let textManager: CountrySelectorTextManagerProtocol
    private var items: [MarketCountryViewModel] = []

    private lazy var loaderView: LoaderView = {
        let view = LoaderView(frame: .zero)
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(frame: .zero)
        refresh.addTarget(self, action: #selector(shouldRefresh), for: .valueChanged)
        return refresh
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: CountryTableViewCell.self)
        return tableView
    }()

    private lazy var bottomContainer: UIView = {
        UIView(frame: .zero)
    }()

    private lazy var continueButton: SimpleButton = {
        let button = SimpleButton(frame: .zero)
        button.addTarget(self, action: #selector(continueButtonPress), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    // MARK: Life cycle

    init(presenter: CountrySelectorViewOutput, textManager: CountrySelectorTextManagerProtocol) {
        self.presenter = presenter
        self.textManager = textManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        languageChanged()
        presenter.viewIsReady()
    }

    private func setupUI() {
        view.backgroundColor = appearance.backgroundColor
        addSubviews()
        makeConstraints()
    }

    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        view.addSubview(loaderView)
        bottomContainer.addSubview(continueButton)
    }

    private func makeConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.topMargin.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainer.snp.top)
        }
        bottomContainer.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
        }
        continueButton.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(appearance.continueInsets)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(appearance.continueInsets)
        }
        loaderView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(LoaderView.defaultSize)
        }
    }
}

private extension CountrySelectorViewController {
    @objc func continueButtonPress() {
        presenter.didContinueButtonPress()
    }

    @objc func shouldRefresh() {
        presenter.shouldRefresh()
    }
}

// MARK: - CountrySelectorViewInput implementation

extension CountrySelectorViewController: CountrySelectorViewInput {
    func setupInitialState() {
    }

    func showLoading() {
        loaderView.startAnimating()
    }

    func hideLoading() {
        loaderView.stopAnimating()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    func showItems(items: [MarketCountryViewModel]) {
        self.items = items
        tableView.reloadData()
    }

    func setContinueButtonEnabled() {
        continueButton.isEnabled = true
    }

    func setContinueButtonDisabled() {
        continueButton.isEnabled = false
    }
}

extension CountrySelectorViewController: LanguageObservable {
    func languageChanged() {
        title = textManager.title
        continueButton.setTitle(textManager.continueButton, for: .normal)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource implementation

extension CountrySelectorViewController: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeue(cellClass: CountryTableViewCell.self, forIndexPath: indexPath)
        let contract = CountryTableViewCellContract(
            checked: item.selected,
            title: item.title
        )
        cell.selectionStyle = .none
        cell.configure(with: contract)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        presenter.didSelectCountry(model: item)
    }
}
