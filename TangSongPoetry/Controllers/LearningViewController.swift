import UIKit

class LearningViewController: UIViewController {
    
    // MARK: - 属性
    
    private let tableView = UITableView()
    private var learningRecords: [LearningRecord] = []
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 每次视图出现时刷新学习记录
        loadLearningRecords()
    }
    
    // MARK: - UI设置
    
    private func setupNavigationBar() {
        title = "学习"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 添加清空按钮
        let clearButton = UIBarButtonItem(
            title: "清空记录",
            style: .plain,
            target: self,
            action: #selector(clearLearningRecords)
        )
        navigationItem.rightBarButtonItem = clearButton
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
        tableView.register(LearningRecordCell.self, forCellReuseIdentifier: "LearningRecordCell")
        
        // 设置表格样式
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        
        // 设置空状态视图
        setupEmptyStateView()
    }
    
    private func setupEmptyStateView() {
        let emptyStateView = UIView()
        
        let imageView = UIImageView(image: UIImage(systemName: "book.closed"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "暂无学习记录"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = "您阅读过的诗词将显示在这里"
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
    
    private func loadLearningRecords() {
        learningRecords = DataService.shared.fetchLearningRecords()
        tableView.reloadData()
        
        // 更新空状态视图的可见性
        tableView.backgroundView?.isHidden = !learningRecords.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !learningRecords.isEmpty
    }
    
    // MARK: - 操作方法
    
    @objc private func clearLearningRecords() {
        let alertController = UIAlertController(
            title: "确认清空",
            message: "确定要清空所有学习记录吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "清空", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // 实现清空记录的逻辑
            // 由于我们还没有实现这个方法，这里暂时简单地清空数组并刷新UI
            self.learningRecords = []
            self.tableView.reloadData()
            
            // 更新空状态视图的可见性
            self.tableView.backgroundView?.isHidden = !self.learningRecords.isEmpty
            self.navigationItem.rightBarButtonItem?.isEnabled = !self.learningRecords.isEmpty
            
            // 显示提示
            self.showToast(message: "学习记录已清空")
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        toastLabel.center = CGPoint(x: view.center.x, y: view.frame.height - 100)
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LearningViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return learningRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LearningRecordCell", for: indexPath) as! LearningRecordCell
        let record = learningRecords[indexPath.row]
        
        if let poem = record.poem, let date = record.dateViewed {
            cell.configure(
                title: poem.title ?? "未知标题",
                author: poem.author?.name ?? "佚名",
                dynasty: poem.dynasty ?? "",
                date: dateFormatter.string(from: date),
                isMemorized: record.isMemorized
            )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let poem = learningRecords[indexPath.row].poem {
            let detailVC = PoemDetailViewController(poem: poem)
            navigationController?.pushViewController(detailVC, animated: true)
            
            // 更新学习记录
            DataService.shared.recordPoemView(poem: poem)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let record = learningRecords[indexPath.row]
        
        // 创建"标记为已记忆"或"取消标记"的操作
        let memorizeActionTitle = record.isMemorized ? "取消标记" : "标记为已记忆"
        let memorizeActionImage = record.isMemorized ? "xmark.circle.fill" : "checkmark.circle.fill"
        
        let memorizeAction = UIContextualAction(style: .normal, title: memorizeActionTitle) { [weak self] (_, _, completion) in
            guard let self = self, let poem = record.poem else {
                completion(false)
                return
            }
            
            // 切换记忆状态
            let newMemorizedState = !record.isMemorized
            DataService.shared.recordPoemView(poem: poem, isMemorized: newMemorizedState, notes: record.notes ?? "")
            
            // 重新加载数据
            self.loadLearningRecords()
            
            completion(true)
        }
        
        memorizeAction.image = UIImage(systemName: memorizeActionImage)
        memorizeAction.backgroundColor = record.isMemorized ? .systemGray : .systemGreen
        
        // 删除操作
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            // 删除记录
            // 由于我们还没有实现删除单个记录的方法，这里暂时从数组中删除并刷新UI
            self.learningRecords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // 更新空状态视图的可见性
            self.tableView.backgroundView?.isHidden = !self.learningRecords.isEmpty
            self.navigationItem.rightBarButtonItem?.isEnabled = !self.learningRecords.isEmpty
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, memorizeAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: - LearningRecordCell

class LearningRecordCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let memorizedBadge = UIView()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 设置容器视图
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // 设置标题标签
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // 设置作者标签
        authorLabel.font = UIFont.systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel
        
        // 设置日期标签
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.textAlignment = .right
        
        // 设置已记忆标记
        memorizedBadge.backgroundColor = .systemGreen
        memorizedBadge.layer.cornerRadius = 8
        memorizedBadge.isHidden = true
        
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmarkImageView.tintColor = .white
        checkmarkImageView.contentMode = .scaleAspectFit
        
        memorizedBadge.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: memorizedBadge.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: memorizedBadge.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 10),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        // 添加组件到容器
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(memorizedBadge)
        
        // 设置约束
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        memorizedBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            memorizedBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            memorizedBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            memorizedBadge.widthAnchor.constraint(equalToConstant: 18),
            memorizedBadge.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        // 设置指示箭头
        accessoryType = .disclosureIndicator
    }
    
    func configure(title: String, author: String, dynasty: String, date: String, isMemorized: Bool) {
        titleLabel.text = title
        authorLabel.text = "[\(dynasty)] \(author)"
        dateLabel.text = date
        memorizedBadge.isHidden = !isMemorized
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        memorizedBadge.isHidden = true
    }
} 