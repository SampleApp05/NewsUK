//
//  ViewController.swift
//  NewsUK
//
//  Created by Daniel Velikov on 11/1/25.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let viewModel = UsersViewModel(
            networkService: HTTPClient(service: URLSession.shared),
            decoder: .snakeCase,
            followService: FollowListService()
        )
        
        let controller = UsersViewController(
            viewModel: viewModel,
            source: "http://api.stackexchange.com/2.2/users?page=1&pagesize=20&order=desc&sort=reputation&site=stackoverflow"
        )
        
        present(controller, animated: true)
    }
}

