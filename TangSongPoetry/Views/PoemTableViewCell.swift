import UIKit

class PoemTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let contentPreviewLabel = UILabel()
    private let authorLabel = UILabel()
    private let favoriteIndicator = UIImageView()
    
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
        
        // 设置内容预览标签
        contentPreviewLabel.font = UIFont.systemFont(ofSize: 14)
        contentPreviewLabel.textColor = .secondaryLabel
        contentPreviewLabel.numberOfLines = 2
        
        // 设置作者标签
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        authorLabel.textColor = .tertiaryLabel
        authorLabel.textAlignment = .right
        
        // 设置收藏指示器
        favoriteIndicator.image = UIImage(systemName: "heart.fill")
        favoriteIndicator.tintColor = .systemRed
        favoriteIndicator.contentMode = .scaleAspectFit
        favoriteIndicator.isHidden = true
        
        // 添加组件到容器
        containerView.addSubview(titleLabel)
        containerView.addSubview(contentPreviewLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(favoriteIndicator)
        
        // 设置约束
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteIndicator.leadingAnchor, constant: -8),
            
            contentPreviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            contentPreviewLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentPreviewLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: contentPreviewLabel.bottomAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            authorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            favoriteIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            favoriteIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            favoriteIndicator.widthAnchor.constraint(equalToConstant: 20),
            favoriteIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // 设置指示箭头
        accessoryType = .disclosureIndicator
    }
    
    func configure(with poem: Poem) {
        // 设置标题
        titleLabel.text = poem.title
        
        // 设置内容预览
        if let content = poem.content {
            let firstTwoLines = content.components(separatedBy: "\n").prefix(2).joined(separator: "，")
            contentPreviewLabel.text = firstTwoLines
        } else {
            contentPreviewLabel.text = "无内容"
        }
        
        // 设置作者
        if let author = poem.author?.name, let dynasty = poem.dynasty {
            authorLabel.text = "[\(dynasty)] \(author)"
        } else if let author = poem.author?.name {
            authorLabel.text = author
        } else {
            authorLabel.text = "佚名"
        }
        
        // 设置收藏状态
        favoriteIndicator.isHidden = !DataService.shared.isFavorite(poem: poem)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        contentPreviewLabel.text = nil
        authorLabel.text = nil
        favoriteIndicator.isHidden = true
    }
} 