import UIKit

class PoemBrowseViewController: UIViewController {
    
    // MARK: - 属性
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections: [(title: String, poems: [Poem])] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupSearchController()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 刷新表格以更新收藏状态
        tableView.reloadData()
    }
    
    // MARK: - 初始化方法
    
    private func setupNavigationBar() {
        title = "唐诗宋词"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 设置导航栏按钮
        let dynastyFilterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showDynastyFilter)
        )
        
        navigationItem.rightBarButtonItem = dynastyFilterButton
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PoemTableViewCell.self, forCellReuseIdentifier: "PoemCell")
        
        // 设置表格样式
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "搜索诗词、作者"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        definesPresentationContext = true
    }
    
    // MARK: - 数据加载方法
    
    private func loadData() {
        // 按朝代分组加载数据
        let tangPoems = DataService.shared.fetchPoemsByDynasty("唐")
        let songPoems = DataService.shared.fetchPoemsByDynasty("宋")
        
        sections = [
            ("唐诗", tangPoems),
            ("宋词", songPoems)
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - 操作方法
    
    @objc private func showDynastyFilter() {
        let alertController = UIAlertController(title: "按朝代筛选", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "全部", style: .default) { [weak self] _ in
            self?.loadData()
        })
        
        alertController.addAction(UIAlertAction(title: "唐诗", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let tangPoems = DataService.shared.fetchPoemsByDynasty("唐")
            self.sections = [("唐诗", tangPoems)]
            self.tableView.reloadData()
        })
        
        alertController.addAction(UIAlertAction(title: "宋词", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let songPoems = DataService.shared.fetchPoemsByDynasty("宋")
            self.sections = [("宋词", songPoems)]
            self.tableView.reloadData()
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        // 适配iPad
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension PoemBrowseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].poems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PoemCell", for: indexPath) as! PoemTableViewCell
        
        let poem = sections[indexPath.section].poems[indexPath.row]
        cell.configure(with: poem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let poem = sections[indexPath.section].poems[indexPath.row]
        let detailVC = PoemDetailViewController(poem: poem)
        navigationController?.pushViewController(detailVC, animated: true)
        
        // 记录学习记录
        DataService.shared.recordPoemView(poem: poem)
    }
}

// MARK: - UISearchResultsUpdating

extension PoemBrowseViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            loadData()
            return
        }
        
        // 搜索诗词
        let searchResults = DataService.shared.fetchPoems(matching: searchText)
        
        // 按朝代分组
        let tangResults = searchResults.filter { $0.dynasty == "唐" }
        let songResults = searchResults.filter { $0.dynasty == "宋" }
        
        sections = []
        
        if !tangResults.isEmpty {
            sections.append(("唐诗", tangResults))
        }
        
        if !songResults.isEmpty {
            sections.append(("宋词", songResults))
        }
        
        tableView.reloadData()
    }
} 