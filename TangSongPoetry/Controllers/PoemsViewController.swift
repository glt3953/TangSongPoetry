import UIKit

class PoemsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var poems: [Poem] = []
    private var filteredPoems: [Poem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupSearchController()
        loadPoems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 刷新收藏状态
        tableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "唐诗宋词"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 添加分类按钮
        let categoryButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(showCategories))
        navigationItem.rightBarButtonItem = categoryButton
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(PoemTableViewCell.self, forCellReuseIdentifier: "PoemCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "搜索诗词、作者或内容"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Data Loading
    private func loadPoems() {
        // 这里应该从数据服务加载诗词数据
        // 暂时使用模拟数据
        let poemService = PoemService()
        poemService.fetchPoems { [weak self] poems in
            self?.poems = poems
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func showCategories() {
        let categoryVC = CategoryViewController()
        categoryVC.delegate = self
        let navController = UINavigationController(rootViewController: categoryVC)
        present(navController, animated: true)
    }
    
    // MARK: - Helper Methods
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPoems = poems.filter { poem in
            return poem.title.lowercased().contains(searchText.lowercased()) ||
                poem.author.name.lowercased().contains(searchText.lowercased()) ||
                poem.content.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension PoemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredPoems.count : poems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PoemCell", for: indexPath) as? PoemTableViewCell else {
            return UITableViewCell()
        }
        
        let poem = isSearching ? filteredPoems[indexPath.row] : poems[indexPath.row]
        cell.configure(with: poem)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PoemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let poem = isSearching ? filteredPoems[indexPath.row] : poems[indexPath.row]
        let detailVC = PoemDetailViewController(poem: poem)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension PoemsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
        }
    }
}

// MARK: - CategoryViewControllerDelegate
extension PoemsViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: PoemCategory) {
        // 根据选择的分类过滤诗词
        let poemService = PoemService()
        poemService.fetchPoems(byCategory: category) { [weak self] poems in
            self?.poems = poems
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.title = category.displayName
            }
        }
        dismiss(animated: true)
    }
}