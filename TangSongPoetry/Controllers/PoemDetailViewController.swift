import UIKit
import AVFoundation

class PoemDetailViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    // MARK: - 属性
    
    private let poem: Poem
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // UI组件
    private let titleLabel = UILabel()
    private let titlePinyinLabel = UILabel()
    private let authorLabel = UILabel()
    private let poemStackView = UIStackView()
    private let translationTitleLabel = UILabel()
    private let translationLabel = UILabel()
    private let analysisTitleLabel = UILabel()
    private let analysisLabel = UILabel()
    private let favoriteButton = UIButton()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let speakButton = UIButton()
    private var isSpeaking = false
    
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
        speechSynthesizer.delegate = self // 设置代理
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSpeaking()
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
        
        // 添加朗读按钮
        speakButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        speakButton.addTarget(self, action: #selector(toggleSpeaking), for: .touchUpInside)
        
        let favoriteBarButton = UIBarButtonItem(customView: favoriteButton)
        let speakBarButton = UIBarButtonItem(customView: speakButton)
        
        // 添加分享按钮
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(sharePoem)
        )
        
        navigationItem.rightBarButtonItems = [favoriteBarButton, shareButton, speakBarButton]
    }
    
    private func setupLabels() {
        // 标题标签
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // 标题拼音标签
        contentView.addSubview(titlePinyinLabel)
        titlePinyinLabel.translatesAutoresizingMaskIntoConstraints = false
        titlePinyinLabel.font = UIFont.systemFont(ofSize: 14)
        titlePinyinLabel.textAlignment = .center
        titlePinyinLabel.textColor = .systemGray
        titlePinyinLabel.numberOfLines = 0
        
        // 作者标签
        contentView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        authorLabel.textAlignment = .center
        authorLabel.textColor = .secondaryLabel
        
        // 拼音栈视图
        contentView.addSubview(poemStackView)
        poemStackView.translatesAutoresizingMaskIntoConstraints = false
        poemStackView.axis = .vertical
        poemStackView.spacing = 4
        poemStackView.alignment = .fill
        poemStackView.distribution = .fill
        
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
            titlePinyinLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titlePinyinLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titlePinyinLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: titlePinyinLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            poemStackView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 24),
            poemStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            poemStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            translationTitleLabel.topAnchor.constraint(equalTo: poemStackView.bottomAnchor, constant: 32),
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
        
        // 设置标题拼音
        if let poemTitle = poem.title {
            titlePinyinLabel.text = simulatePinyin(for: poemTitle)
        }
        
        // 设置作者和朝代
        if let author = poem.author?.name, let dynasty = poem.dynasty {
            authorLabel.text = "[\(dynasty)] \(author)"
        } else if let author = poem.author?.name {
            authorLabel.text = author
        }
        
        // 清空栈视图
        poemStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 设置诗句和拼音
        if let content = poem.content {
            let lines = content.components(separatedBy: "\n")
            
            for line in lines {
                if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // 处理长行
                    let (pinyinText, lineText) = processLongLine(line)
                    
                    // 创建拼音标签
                    let pinyinLabel = UILabel()
                    pinyinLabel.font = UIFont.systemFont(ofSize: 14)
                    pinyinLabel.textAlignment = .center
                    pinyinLabel.textColor = .systemGray
                    pinyinLabel.numberOfLines = 0
                    pinyinLabel.text = pinyinText
                    pinyinLabel.lineBreakMode = .byCharWrapping
                    
                    // 创建诗句标签
                    let lineLabel = UILabel()
                    lineLabel.font = UIFont.systemFont(ofSize: 18)
                    lineLabel.textAlignment = .center
                    lineLabel.numberOfLines = 0
                    lineLabel.text = lineText
                    lineLabel.lineBreakMode = .byCharWrapping
                    
                    // 添加到栈视图
                    poemStackView.addArrangedSubview(pinyinLabel)
                    poemStackView.addArrangedSubview(lineLabel)
                    
                    // 添加诗句间的间距（如果不是最后一行）
                    if line != lines.last {
                        let spacerView = UIView()
                        spacerView.heightAnchor.constraint(equalToConstant: 16).isActive = true
                        poemStackView.addArrangedSubview(spacerView)
                    }
                }
            }
        }
        
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
    
    @objc private func toggleSpeaking() {
        if isSpeaking {
            stopSpeaking()
        } else {
            startSpeaking()
        }
    }
    
    private func startSpeaking() {
        // 构建朗读文本
        var textToSpeak = ""
        
        if let title = poem.title {
            textToSpeak += title + "。"
        }
        
        if let dynasty = poem.dynasty {
            textToSpeak += dynasty + "。"
        }
        
        if let author = poem.author?.name {
            textToSpeak += author + "。"
        }
        
        if let content = poem.content {
            textToSpeak += content.replacingOccurrences(of: "\n", with: "。")
        }
        
        // 创建朗读配置
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN") // 使用中文声音
        utterance.rate = 0.5 // 调整语速
        utterance.pitchMultiplier = 1.0 // 音调
        utterance.volume = 1.0 // 音量
        
        // 开始朗读
        speechSynthesizer.speak(utterance)
        isSpeaking = true
        
        // 更新按钮状态
        speakButton.setImage(UIImage(systemName: "speaker.slash"), for: .normal)
        speakButton.tintColor = .systemRed
    }
    
    private func resetSpeakingState() {
        isSpeaking = false
        speakButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        speakButton.tintColor = .systemBlue
    }
    
    private func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        resetSpeakingState()
    }
    
    // 模拟拼音转换，实际应用中应替换为真实的拼音服务
    private func simulatePinyin(for text: String) -> String {
        // 使用CoreFoundation的拼音转换功能
        let mutableString = NSMutableString(string: text) as CFMutableString
            // 将汉字转换为拼音
            CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
            print("把\"\(text)\"转为拼音: \(mutableString)")
            
        //    // 去掉拼音的音标
        //    CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        //    print("去掉拼音的音标: \(mutableString)")
            
            let pinyin = mutableString as String
            
        //    // 去掉空格
        //    let cleanedPinyin = pinyin.replacingOccurrences(of: " ", with: "")
        //    print("去掉空格: \(cleanedPinyin)")
            
            return pinyin
    }
    
    // 为长诗句处理换行和拼音对齐
    private func processLongLine(_ line: String) -> (String, String) {
        // 获取拼音
        let pinyin = simulatePinyin(for: line)
        
        // 检查是否需要拆分行
        if line.count > 15 { // 可以根据具体情况调整这个阈值
            // 可以在这里实现自动拆分长行的逻辑
            // 例如，在适当的位置添加换行符
            
            // 这个简单示例每15个字符换一次行
            var wrappedText = ""
            var index = 0
            
            for char in line {
                wrappedText.append(char)
                index += 1
                
                if index % 15 == 0 && index < line.count {
                    wrappedText.append("\n")
                }
            }
            
            // 同样处理拼音
            var wrappedPinyin = ""
            let pinyinComponents = pinyin.components(separatedBy: " ")
            index = 0
            
            for component in pinyinComponents {
                if index > 0 {
                    wrappedPinyin.append(" ")
                }
                wrappedPinyin.append(component)
                index += 1
                
                if index % 15 == 0 && index < pinyinComponents.count {
                    wrappedPinyin.append("\n")
                }
            }
            
            return (wrappedPinyin, wrappedText)
        }
        
        return (pinyin, line)
    }
    
    // 修改代理方法
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 朗读完成时重置状态
        DispatchQueue.main.async { [weak self] in
            self?.resetSpeakingState()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // 朗读被取消时重置状态
        DispatchQueue.main.async { [weak self] in
            self?.resetSpeakingState()
        }
    }
}
