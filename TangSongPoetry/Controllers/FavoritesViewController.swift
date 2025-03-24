import UIKit

class FavoritesViewController: UIViewController {
    
    // MARK: - 属性
    
    private let tableView = UITableView()
    private var favoritePoems: [Poem] = []
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 每次视图出现时刷新收藏列表
        loadFavorites()
    }
    
    // MARK: - UI设置
    
    private func setupNavigationBar() {
        title = "收藏"
        navigationController?.navigationBar.prefersLargeTitles = true
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
        
        // 设置空状态视图
        setupEmptyStateView()
    }
    
    private func setupEmptyStateView() {
        let emptyStateView = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "heart.slash"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "暂无收藏"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = "您的收藏诗词将显示在这里"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .tertiaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        emptyStateView.addSubview(imageView)
        emptyStateView.addSubview(titleLabel)
        emptyStateView.addSubview(messageLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20)
        ])
        
        tableView.backgroundView = emptyStateView
    }
    
    // MARK: - 数据加载
    
    private func loadFavorites() {
        favoritePoems = DataService.shared.fetchFavorites()
        tableView.reloadData()
        
        // 更新空状态视图的可见性
        tableView.backgroundView?.isHidden = !favoritePoems.isEmpty
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePoems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PoemCell", for: indexPath) as! PoemTableViewCell
        let poem = favoritePoems[indexPath.row]
        cell.configure(with: poem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let poem = favoritePoems[indexPath.row]
        let detailVC = PoemDetailViewController(poem: poem)
        navigationController?.pushViewController(detailVC, animated: true)
        
        // 记录学习记录
        DataService.shared.recordPoemView(poem: poem)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let poem = favoritePoems[indexPath.row]
        
        let removeAction = UIContextualAction(style: .destructive, title: "取消收藏") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            // 取消收藏
            DataService.shared.toggleFavorite(for: poem)
            
            // 从列表中移除
            self.favoritePoems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // 更新空状态视图的可见性
            self.tableView.backgroundView?.isHidden = !self.favoritePoems.isEmpty
            
            completion(true)
        }
        
        removeAction.image = UIImage(systemName: "heart.slash.fill")
        removeAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [removeAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
} 