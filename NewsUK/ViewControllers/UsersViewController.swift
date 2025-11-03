//
//  UsersViewController.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//


import UIKit

final class UsersViewController: UIViewController, UITableViewDelegate {
    private let source: String
    private let viewModel: BaseUsersViewModel
    
    private let containerStackView = UIStackView()
    
    private let loadingView = UIView()
    private let errorView = UILabel() // just a label with a message
    private let noDataView = UILabel() // just a label with a message
    
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Int, User>!
    
    init(viewModel: BaseUsersViewModel, source: String) {
        self.viewModel = viewModel
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        configure()
        fetchUsers()
    }
    
    // MARK: - Private
    private func configure() {
        title = "Users"
        
        configureContainerStackView()
        configureLoadingView()
        configureErrorView()
        configureNoDataView()
        configureTableView()
    }
    
    
    private func configureContainerStackView() {
        containerStackView.axis = .vertical
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        [loadingView, errorView, noDataView, tableView].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        view.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureLoadingView() {
        let indicator = UIActivityIndicatorView(style: .medium)
        let messageLabel = UILabel()
        messageLabel.text = "Sit tight, we are fetching the users for you..."
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        let stackView = UIStackView(
            arrangedSubviews: [
                indicator,
                messageLabel
            ]
        )
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        loadingView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
        
        indicator.startAnimating()
    }
    
    private func configureErrorView() {
        errorView.text = "Something went wrong, please try again later"
        errorView.numberOfLines = 0
        errorView.textAlignment = .center
        
        errorView.isHidden = true
    }
    
    private func configureNoDataView() {
        noDataView.text = "We couldn't find any users, please try again later"
        noDataView.numberOfLines = 0
        noDataView.textAlignment = .center
        
        noDataView.isHidden = true
    }
    
    private func configureTableView() {
        tableView.allowsSelection = false
        tableView.isHidden = true
        tableView.delegate = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "cell")
        
        dataSource = UITableViewDiffableDataSource<Int, User>(tableView: tableView) { [weak self] (tableView, indexPath, user) -> UITableViewCell? in
            guard let self else { return  nil }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UserTableViewCell else {
                return nil
            }
            
            let imageTask = viewModel.fetchUserImage(for: indexPath.row)
            
            cell.configure(
                with: user,
                imageTask: imageTask,
            ) { [weak self] (id) in
                guard let self else { return }
                
                viewModel.didTapUserActionButton(userId: id)
                applySnapshot(with: viewModel.fetchDataShapshot())
            }
            
            return cell
        }
    }
    
    private func applySnapshot(with users: [User]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(users)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @MainActor
    private func updateUI() {
        let users = viewModel.fetchDataShapshot()
        
        guard users.isEmpty == false else {
            showNoUsersView()
            return
        }
        
        loadingView.isHidden = true
        tableView.isHidden = false
        applySnapshot(with: users)
    }
    
    @MainActor
    private func showErrorView() {
        loadingView.isHidden = true
        errorView.isHidden = false
    }
    
    @MainActor
    private func showNoUsersView() {
        loadingView.isHidden = true
        noDataView.isHidden = false
    }
    
    func fetchUsers() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await viewModel.fetchUsers(from: source)
                updateUI()
            } catch {
                showErrorView()
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        viewModel.cancellImageTask(for: indexPath.row)
    }
}
