//
//  ViewController.swift
//
//  Created by Home on 2019.
//  Copyright 2017-2018 NoStoryboardsAtAll Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class ViewController: UIViewController {

    enum State: Int {
        case idle, loading
    }
    
    var state: State = .idle
    
    // Refrech control for tableView
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        
        control.tintColor = .gray
        control.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
        return control
    }()
    
    var tableView: UITableView!
    let repoCellIP = "repoCellIP"
    
    // search repositories keyword
    var keyword: String? {
        didSet {
            guard let keyword = keyword else { return }
            // will execute search only if keyword is not empty and keyword has a different value
            if ( keyword != oldValue && !keyword.isEmpty ) {
                fetch()
            }
        }
    }
    
    public func fetch() {
        if ( state == .idle ) {
            state = .loading
            GithubAPIManager.shared.fetchRepositories(by: keyword!) { [unowned self] ( result ) in
                self.state = .idle
                switch result {
                case .failure( let error ):
                    print(error.localizedDescription)
                case .success( let json ):
                    print(json["total_count"] ?? "No Items")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func loadView() {
        super.loadView()
        // ToDo - Add comment
        registerTableView()
        prepareView()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = .white
        
        // Setup the search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search repositeries..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Setup the navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Repositories"
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }

    fileprivate func prepareView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor), // UIRefreshControl Bug - connect it NOT to safeArea
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    fileprivate func registerTableView() {
        // Setting up the appearance of tableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        
        // register class for tableView cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: repoCellIP)
        
        // Setting up the delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add refresh control to the tableView
        tableView.refreshControl = refreshControl
    }
}

// UISearchBarDelegate stuff
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        keyword = searchBar.text
    }
}
