import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - 属性
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private enum SearchScope: Int {
        case poems = 0
        case authors = 1
    }
    
    private var currentScope: SearchScope = .poems
    private var searchResults: [Any] = []
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupSearchController()
        setupTableView()
    }
    
    // MARK: - 初始化方法
    
    private func setupNavigationBar() {
        title = "搜索"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "输入诗词名、内容或作者名"
        
        searchController.searchBar.scopeButtonTitles = ["诗词", "作者"]
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // 初始状态下就显示搜索栏
        navigationItem.hidesSearchBarWhenScrolling = false
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
        tableView.register(AuthorTableViewCell.self, forCellReuseIdentifier: "AuthorCell")
        
        // 设置表格背景视图
        let noResultsLabel = UILabel()
        noResultsLabel.text = "请输入关键词搜索"
        noResultsLabel.textAlignment = .center
        noResultsLabel.textColor = .secondaryLabel
        noResultsLabel.font = UIFont.systemFont(ofSize: 16)
        tableView.backgroundView = noResultsLabel
    }
    
    // MARK: - 搜索方法
    
    private func performSearch(with searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            updateBackgroundLabel(text: "请输入关键词搜索")
        } else {
            switch currentScope {
            case .poems:
                let poems = DataService.shared.fetchPoems(matching: searchText)
                searchResults = poems
                updateBackgroundLabel(text: poems.isEmpty ? "未找到匹配的诗词" : nil)
            case .authors:
                let authors = DataService.shared.fetchAuthors(matching: searchText)
                searchResults = authors
                updateBackgroundLabel(text: authors.isEmpty ? "未找到匹配的作者" : nil)
            }
        }
        
        tableView.reloadData()
    }
    
    private func updateBackgroundLabel(text: String?) {
        if let label = tableView.backgroundView as? UILabel {
            label.text = text
        }
        tableView.backgroundView?.isHidden = (text == nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentScope {
        case .poems:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PoemCell", for: indexPath) as! PoemTableViewCell
            if let poem = searchResults[indexPath.row] as? Poem {
                cell.configure(with: poem)
            }
            return cell
            
        case .authors:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorCell", for: indexPath) as! AuthorTableViewCell
            if let author = searchResults[indexPath.row] as? Author {
                cell.configure(with: author)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return currentScope == .poems ? 100 : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentScope {
        case .poems:
            if let poem = searchResults[indexPath.row] as? Poem {
                let detailVC = PoemDetailViewController(poem: poem)
                navigationController?.pushViewController(detailVC, animated: true)
                
                // 记录学习记录
                DataService.shared.recordPoemView(poem: poem)
            }
            
        case .authors:
            if let author = searchResults[indexPath.row] as? Author {
                let authorDetailVC = AuthorPoemsViewController(author: author)
                navigationController?.pushViewController(authorDetailVC, animated: true)
            }
        }
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        performSearch(with: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let scope = SearchScope(rawValue: selectedScope) else { return }
        currentScope = scope
        
        // 执行新的搜索
        if let searchText = searchBar.text {
            performSearch(with: searchText)
        }
    }
}

// MARK: - AuthorTableViewCell

class AuthorTableViewCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let dynastyLabel = UILabel()
    private let poemCountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 创建容器视图
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        // 设置名称标签
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .label
        
        // 设置朝代标签
        dynastyLabel.font = UIFont.systemFont(ofSize: 14)
        dynastyLabel.textColor = .secondaryLabel
        
        // 设置作品数量标签
        poemCountLabel.font = UIFont.systemFont(ofSize: 14)
        poemCountLabel.textColor = .tertiaryLabel
        poemCountLabel.textAlignment = .right
        
        // 添加到容器视图
        containerView.addSubview(nameLabel)
        containerView.addSubview(dynastyLabel)
        containerView.addSubview(poemCountLabel)
        
        // 设置约束
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dynastyLabel.translatesAutoresizingMaskIntoConstraints = false
        poemCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            dynastyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dynastyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            dynastyLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            poemCountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            poemCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            poemCountLabel.leadingAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        // 设置指示箭头
        accessoryType = .disclosureIndicator
    }
    
    func configure(with author: Author) {
        nameLabel.text = author.name
        dynastyLabel.text = author.dynasty
        
        // 获取作品数量
        if let poems = author.poems, poems.count > 0 {
            poemCountLabel.text = "作品: \(poems.count)首"
        } else {
            poemCountLabel.text = "无作品"
        }
    }
}

// MARK: - AuthorPoemsViewController

class AuthorPoemsViewController: UIViewController {
    
    private let author: Author
    private let tableView = UITableView()
    private var poems: [Poem] = []
    
    init(author: Author) {
        self.author = author
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadPoems()
    }
    
    private func setupUI() {
        // 设置标题
        if let name = author.name {
            title = name
        }
        
        view.backgroundColor = .systemBackground
        
        // 设置表格视图
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
        
        // 添加作者简介头部视图
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.text = author.name
        
        let dynastyLabel = UILabel()
        dynastyLabel.font = UIFont.systemFont(ofSize: 16)
        dynastyLabel.textColor = .secondaryLabel
        dynastyLabel.text = author.dynasty
        
        let introLabel = UILabel()
        introLabel.font = UIFont.systemFont(ofSize: 14)
        introLabel.textColor = .secondaryLabel
        introLabel.numberOfLines = 0
        
        if let introduction = author.introduction, !introduction.isEmpty {
            introLabel.text = introduction
        } else {
            introLabel.text = "暂无作者简介"
        }
        
        headerView.addSubview(nameLabel)
        headerView.addSubview(dynastyLabel)
        headerView.addSubview(introLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dynastyLabel.translatesAutoresizingMaskIntoConstraints = false
        introLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            dynastyLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            dynastyLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            
            introLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            introLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            introLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            introLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        // 调整headerView的高度以适应内容
        let introHeight = introLabel.text?.height(withConstrainedWidth: view.bounds.width - 32, font: introLabel.font) ?? 0
        headerView.frame.size.height = 60 + introHeight
        
        tableView.tableHeaderView = headerView
    }
    
    private func loadPoems() {
        poems = DataService.shared.fetchPoemsByAuthor(author)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AuthorPoemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PoemCell", for: indexPath) as! PoemTableViewCell
        let poem = poems[indexPath.row]
        cell.configure(with: poem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let poem = poems[indexPath.row]
        let detailVC = PoemDetailViewController(poem: poem)
        navigationController?.pushViewController(detailVC, animated: true)
        
        // 记录学习记录
        DataService.shared.recordPoemView(poem: poem)
    }
}

// MARK: - String Extension 计算文本高度

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
} 