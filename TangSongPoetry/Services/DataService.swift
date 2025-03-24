import UIKit
import CoreData

class DataService {
    static let shared = DataService()
    
    private init() {
        loadInitialDataIfNeeded()
    }
    
    // MARK: - 核心数据相关
    
    var viewContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - 数据加载方法
    
    private func loadInitialDataIfNeeded() {
        // 检查是否已经加载过数据
        let fetchRequest: NSFetchRequest<Poem> = Poem.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            if count == 0 {
                // 数据库为空，加载初始数据
                loadInitialData()
            }
        } catch {
            print("检查数据库状态出错: \(error)")
        }
    }
    
    private func loadInitialData() {
        // 这里将从JSON文件加载初始诗词数据
        guard let url = Bundle.main.url(forResource: "poems", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("无法加载初始诗词数据")
            return
        }
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                for poemDict in jsonArray {
                    addPoem(from: poemDict)
                }
                
                // 保存上下文
                try viewContext.save()
                print("成功加载初始诗词数据")
            }
        } catch {
            print("解析诗词数据出错: \(error)")
        }
    }
    
    private func addPoem(from dict: [String: Any]) {
        // 先查找或创建作者
        let authorName = dict["author"] as? String ?? "佚名"
        let authorDynasty = dict["dynasty"] as? String ?? ""
        
        let author = findOrCreateAuthor(name: authorName, dynasty: authorDynasty)
        
        // 创建诗词
        let poem = Poem(context: viewContext)
        poem.id = UUID()
        poem.title = dict["title"] as? String
        poem.content = dict["content"] as? String
        poem.dynasty = dict["dynasty"] as? String
        poem.translation = dict["translation"] as? String
        poem.analysis = dict["analysis"] as? String
        
        // 设置作者关系
        poem.author = author
        
        // 设置标签
        if let tags = dict["tags"] as? [String] {
            poem.tags = tags as NSObject
        }
    }
    
    private func findOrCreateAuthor(name: String, dynasty: String) -> Author {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND dynasty == %@", name, dynasty)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let existingAuthor = results.first {
                return existingAuthor
            }
        } catch {
            print("查询作者出错: \(error)")
        }
        
        // 创建新作者
        let author = Author(context: viewContext)
        author.id = UUID()
        author.name = name
        author.dynasty = dynasty
        return author
    }
    
    // MARK: - 诗词查询方法
    
    func fetchPoems(matching query: String? = nil, limit: Int = 50) -> [Poem] {
        let fetchRequest: NSFetchRequest<Poem> = Poem.fetchRequest()
        
        // 设置查询条件
        if let query = query, !query.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@ OR author.name CONTAINS[cd] %@", query, query, query)
        }
        
        // 设置排序
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // 设置限制
        fetchRequest.fetchLimit = limit
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("查询诗词出错: \(error)")
            return []
        }
    }
    
    func fetchAuthors(matching query: String? = nil) -> [Author] {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        
        // 设置查询条件
        if let query = query, !query.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        
        // 设置排序
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("查询作者出错: \(error)")
            return []
        }
    }
    
    func fetchPoemsByDynasty(_ dynasty: String) -> [Poem] {
        let fetchRequest: NSFetchRequest<Poem> = Poem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dynasty == %@", dynasty)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("按朝代查询诗词出错: \(error)")
            return []
        }
    }
    
    func fetchPoemsByAuthor(_ author: Author) -> [Poem] {
        let fetchRequest: NSFetchRequest<Poem> = Poem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "author == %@", author)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("按作者查询诗词出错: \(error)")
            return []
        }
    }
    
    // MARK: - 收藏相关方法
    
    func toggleFavorite(for poem: Poem) -> Bool {
        // 检查是否已经收藏
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "poem == %@", poem)
        
        do {
            let existingFavorites = try viewContext.fetch(fetchRequest)
            
            if let existingFavorite = existingFavorites.first {
                // 已收藏，取消收藏
                viewContext.delete(existingFavorite)
                try viewContext.save()
                return false
            } else {
                // 未收藏，添加收藏
                let favorite = Favorite(context: viewContext)
                favorite.id = UUID()
                favorite.dateAdded = Date()
                favorite.poem = poem
                try viewContext.save()
                return true
            }
        } catch {
            print("操作收藏出错: \(error)")
            return false
        }
    }
    
    func fetchFavorites() -> [Poem] {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let favorites = try viewContext.fetch(fetchRequest)
            return favorites.compactMap { $0.poem }
        } catch {
            print("查询收藏出错: \(error)")
            return []
        }
    }
    
    func isFavorite(poem: Poem) -> Bool {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "poem == %@", poem)
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("检查收藏状态出错: \(error)")
            return false
        }
    }
    
    // MARK: - 学习记录相关方法
    
    func recordPoemView(poem: Poem, isMemorized: Bool = false, notes: String = "") {
        // 检查是否存在记录
        let fetchRequest: NSFetchRequest<LearningRecord> = LearningRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "poem == %@", poem)
        
        do {
            let existingRecords = try viewContext.fetch(fetchRequest)
            
            let record: LearningRecord
            
            if let existingRecord = existingRecords.first {
                // 更新现有记录
                record = existingRecord
            } else {
                // 创建新记录
                record = LearningRecord(context: viewContext)
                record.id = UUID()
                record.poem = poem
            }
            
            // 更新记录
            record.dateViewed = Date()
            record.isMemorized = isMemorized
            
            if !notes.isEmpty {
                record.notes = notes
            }
            
            try viewContext.save()
        } catch {
            print("记录学习状态出错: \(error)")
        }
    }
    
    func fetchLearningRecords() -> [LearningRecord] {
        let fetchRequest: NSFetchRequest<LearningRecord> = LearningRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateViewed", ascending: false)]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("查询学习记录出错: \(error)")
            return []
        }
    }
} 