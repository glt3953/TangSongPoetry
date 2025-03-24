# 唐诗宋词 iOS 应用

这是一个用Swift开发的iOS应用，专注于中国古典文学中的唐诗宋词。应用提供丰富的诗词内容，优雅的用户界面，以及便捷的搜索和收藏功能。

## 功能特点

- 丰富的唐诗宋词数据库
- 按朝代、作者、主题分类浏览
- 强大的搜索功能
- 收藏喜爱的诗词
- 学习进度追踪
- 优雅的用户界面设计
- 诗词详情页面，包含注释和赏析

## 技术栈

- Swift 5.0+
- UIKit/SwiftUI
- Core Data 用于本地数据存储
- 可能使用的第三方库：Alamofire（网络请求）、SnapKit（UI布局）

## 开发环境

- Xcode 12.0+
- iOS 14.0+

## 项目结构

```
TangSongPoetry/
├── TangSongPoetry/          # 主项目目录
│   ├── AppDelegate.swift     # 应用代理
│   ├── SceneDelegate.swift   # 场景代理
│   ├── Models/               # 数据模型
│   ├── Views/                # 视图组件
│   ├── Controllers/          # 控制器
│   ├── Services/             # 服务层
│   ├── Resources/            # 资源文件
│   │   ├── Assets.xcassets   # 图片资源
│   │   ├── Database/         # 诗词数据库
│   │   └── Fonts/            # 自定义字体
│   └── Supporting Files/     # 支持文件
└── TangSongPoetryTests/      # 测试目录
```

## 数据结构设计

应用将包含以下核心数据模型：

- 诗词（Poem）：包含标题、内容、作者、朝代等信息
- 作者（Author）：包含姓名、朝代、简介等信息
- 收藏（Favorite）：用户收藏的诗词
- 学习记录（LearningRecord）：用户的学习进度和历史

## 未来计划

- 添加诗词朗读功能
- 集成AI赏析功能
- 添加社区分享功能
- 支持自定义主题和字体