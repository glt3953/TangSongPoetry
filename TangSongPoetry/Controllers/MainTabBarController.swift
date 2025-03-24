import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupAppearance()
    }
    
    private func setupViewControllers() {
        // 诗词浏览页面
        let poemsVC = UINavigationController(rootViewController: PoemsViewController())
        poemsVC.tabBarItem = UITabBarItem(title: "诗词", image: UIImage(systemName: "book"), tag: 0)
        
        // 作者页面
        let authorsVC = UINavigationController(rootViewController: AuthorsViewController())
        authorsVC.tabBarItem = UITabBarItem(title: "作者", image: UIImage(systemName: "person.2"), tag: 1)
        
        // 收藏页面
        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
        favoritesVC.tabBarItem = UITabBarItem(title: "收藏", image: UIImage(systemName: "heart"), tag: 2)
        
        // 我的页面
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "我的", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [poemsVC, authorsVC, favoritesVC, profileVC]
    }
    
    private func setupAppearance() {
        // 设置标签栏外观
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // 设置标签栏选中颜色
        tabBar.tintColor = .systemBrown
    }
}