//
//  UserTableViewCell.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/2/25.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    private var user: User?
    
    private let containerStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let detailsStackView = UIStackView()
    private let nameLabel = UILabel()
    private let reputationLabel = UILabel()
    private let followButton = UIButton(configuration: .borderedProminent())
    
    private var imageLoaderTask: Task<UIImage?, Never>?
    private var followButtonTapHandler: ItemClosure<String>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String? = "cell") {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoaderTask?.cancel()
    }
    
    // MARK: - Private
    private func configure() {
        configureIconImageView()
        configureContainerStackView()
        configureDetailsStackView()
        configureLabels()
        configureFollowButton()
    }
    
    private func configureContainerStackView() {
        contentView.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.spacing = 10
        
        [iconImageView, detailsStackView, followButton].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            containerStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func configureIconImageView() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        iconImageView.layer.cornerRadius = 10
        iconImageView.clipsToBounds = true
    }
    
    private func configureDetailsStackView() {
        detailsStackView.axis = .vertical
        detailsStackView.alignment = .leading
        
        detailsStackView.addArrangedSubview(nameLabel)
        detailsStackView.addArrangedSubview(reputationLabel)
    }
    
    private func configureLabels() {
        [nameLabel, reputationLabel].forEach {
            $0.numberOfLines = 0
            $0.textAlignment = .left
            $0.font = .preferredFont(forTextStyle: .headline)
        }
    }
    
    private func configureFollowButton() {
        followButton.setContentHuggingPriority(.required, for: .horizontal)
        followButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let action = UIAction { [weak self] (_) in
            guard let self, let id = user?.id else { return }
            followButtonTapHandler?(id)
        }
        
        followButton.setTitle("Follow", for: .normal)
        followButton.addAction(action, for: .touchUpInside)
    }
    
    // MARK: - Public
    func configure(
        with user: User,
        imageTask: Task<UIImage?, Never>?,
        tapHandler: @escaping ItemClosure<String>
    ) {
        self.user = user
        nameLabel.text = user.name
        reputationLabel.text = "Reputation: " + user.reputation
        
        followButton.setTitle(user.isFollowing ? "Unfollow" : "Follow", for: .normal)
        self.followButtonTapHandler = tapHandler
        
        imageLoaderTask?.cancel()
        guard let imageTask else { return }
        
        imageLoaderTask = imageTask
        
        Task { [weak self] in
            let image = await self?.imageLoaderTask?.result.get()
            
            guard let image else { return }
            
            await MainActor.run {
                self?.iconImageView.image = image
            }
        }
    }
}
