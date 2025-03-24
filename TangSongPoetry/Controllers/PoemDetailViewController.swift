import UIKit

class PoemDetailViewController: UIViewController {
    
    // MARK: - 属性
    
    private let poem: Poem
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // UI组件
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let contentLabel = UILabel()
    private let translationTitleLabel = UILabel()
    private let translationLabel = UILabel()
    private let analysisTitleLabel = UILabel()
    private let analysisLabel = UILabel()
    private let favoriteButton = UIButton()
    
    // MARK: - 初始化
    
    init(poem: Poem) {
        self.poem = poem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    // MARK: - UI设置
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置滚动视图和内容视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 设置导航栏
        setupNavigationBar()
        
        // 添加所有标签
        setupLabels()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        // 添加收藏按钮
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        
        let favoriteBarButton = UIBarButtonItem(customView: favoriteButton)
        
        // 添加分享按钮
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(sharePoem)
        )
        
        navigationItem.rightBarButtonItems = [favoriteBarButton, shareButton]
    }
    
    private func setupLabels() {
        // 标题标签
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // 作者标签
        contentView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        authorLabel.textAlignment = .center
        authorLabel.textColor = .secondaryLabel
        
        // 内容标签
        contentView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = UIFont.systemFont(ofSize: 18)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        
        // 翻译标题
        contentView.addSubview(translationTitleLabel)
        translationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        translationTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        translationTitleLabel.text = "译文"
        
        // 翻译内容
        contentView.addSubview(translationLabel)
        translationLabel.translatesAutoresizingMaskIntoConstraints = false
        translationLabel.font = UIFont.systemFont(ofSize: 16)
        translationLabel.textAlignment = .left
        translationLabel.numberOfLines = 0
        
        // 赏析标题
        contentView.addSubview(analysisTitleLabel)
        analysisTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        analysisTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        analysisTitleLabel.text = "赏析"
        
        // 赏析内容
        contentView.addSubview(analysisLabel)
        analysisLabel.translatesAutoresizingMaskIntoConstraints = false
        analysisLabel.font = UIFont.systemFont(ofSize: 16)
        analysisLabel.textAlignment = .left
        analysisLabel.numberOfLines = 0
        
        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 24),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            translationTitleLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 32),
            translationTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            translationTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            translationLabel.topAnchor.constraint(equalTo: translationTitleLabel.bottomAnchor, constant: 8),
            translationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            translationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            analysisTitleLabel.topAnchor.constraint(equalTo: translationLabel.bottomAnchor, constant: 32),
            analysisTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            analysisTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            analysisLabel.topAnchor.constraint(equalTo: analysisTitleLabel.bottomAnchor, constant: 8),
            analysisLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            analysisLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            analysisLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - 数据配置
    
    private func configureUI() {
        // 设置标题
        title = poem.title
        titleLabel.text = poem.title
        
        // 设置作者和朝代
        if let author = poem.author?.name, let dynasty = poem.dynasty {
            authorLabel.text = "[\(dynasty)] \(author)"
        } else if let author = poem.author?.name {
            authorLabel.text = author
        }
        
        // 设置内容
        contentLabel.text = poem.content
        
        // 设置翻译
        if let translation = poem.translation, !translation.isEmpty {
            translationLabel.text = translation
            translationTitleLabel.isHidden = false
            translationLabel.isHidden = false
        } else {
            translationTitleLabel.isHidden = true
            translationLabel.isHidden = true
        }
        
        // 设置赏析
        if let analysis = poem.analysis, !analysis.isEmpty {
            analysisLabel.text = analysis
            analysisTitleLabel.isHidden = false
            analysisLabel.isHidden = false
        } else {
            analysisTitleLabel.isHidden = true
            analysisLabel.isHidden = true
        }
        
        // 更新收藏按钮
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let isFavorite = DataService.shared.isFavorite(poem: poem)
        favoriteButton.isSelected = isFavorite
        favoriteButton.tintColor = isFavorite ? .systemRed : .systemBlue
    }
    
    // MARK: - 交互方法
    
    @objc private func toggleFavorite() {
        let isFavorited = DataService.shared.toggleFavorite(for: poem)
        
        // 更新UI
        favoriteButton.isSelected = isFavorited
        favoriteButton.tintColor = isFavorited ? .systemRed : .systemBlue
        
        // 添加反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // 显示提示
        let message = isFavorited ? "已添加到收藏" : "已从收藏中移除"
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
    
    @objc private func sharePoem() {
        var shareText = ""
        
        if let title = poem.title {
            shareText += "《\(title)》\n"
        }
        
        if let author = poem.author?.name, let dynasty = poem.dynasty {
            shareText += "[\(dynasty)] \(author)\n\n"
        } else if let author = poem.author?.name {
            shareText += author + "\n\n"
        }
        
        if let content = poem.content {
            shareText += content + "\n\n"
        }
        
        shareText += "——来自「唐诗宋词」App"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // 适配iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItems?[1]
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
}
