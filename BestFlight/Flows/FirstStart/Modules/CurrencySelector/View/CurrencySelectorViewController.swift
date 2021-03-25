import UIKit

// MARK: - CurrencySelectorViewController implementation 

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// TODO: Move button and tableview implementation onto some Base class
// To prevent code doubling
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

final class CurrencySelectorViewController: UIViewController {

    // MARK: Appearance

    struct Appearance {
        let backgroundColor: UIColor = .normalBackground
        let continueInsets: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
    }
    private let appearance = Appearance()

    // MARK: Properties

    private let presenter: CurrencySelectorViewOutput
    private let textManager: CurrencySelectorTextManagerProtocol

    private var items: [MarketCurrencyViewModel] = []

    // MARK: UI properties

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
        tableView.register(cellClass: CurrencyTableViewCell.self)
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

    init(presenter: CurrencySelectorViewOutput, textManager: CurrencySelectorTextManagerProtocol) {
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

// MARK: - Handlers

private extension CurrencySelectorViewController {
    @objc func continueButtonPress() {
        presenter.didContinueButtonPress()
    }

    @objc func shouldRefresh() {
        presenter.shouldRefresh()
    }
}

// MARK: - CurrencySelectorViewInput implementation

extension CurrencySelectorViewController: CurrencySelectorViewInput {
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

    func showItems(items: [MarketCurrencyViewModel]) {
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

// MARK: - LanguageObservable implementation

extension CurrencySelectorViewController: LanguageObservable {
    func languageChanged() {
        title = textManager.title
        continueButton.setTitle(textManager.continueButton, for: .normal)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource implementation

extension CurrencySelectorViewController: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeue(cellClass: CurrencyTableViewCell.self, forIndexPath: indexPath)
        let contract = CurrencyTableViewCellContract(
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
        presenter.didSelectCurrency(model: item)
    }
}
