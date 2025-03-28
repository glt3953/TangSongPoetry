import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // 创建主页TabBarController
        let tabBarController = UITabBarController()
        
        // 1. 主页 - 浏览诗词
        let browseVC = UINavigationController(rootViewController: PoemBrowseViewController())
        browseVC.tabBarItem = UITabBarItem(title: "浏览", image: UIImage(systemName: "book.fill"), tag: 0)
        
        // 2. 搜索页
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "搜索", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        // 3. 收藏页
        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
        favoritesVC.tabBarItem = UITabBarItem(title: "收藏", image: UIImage(systemName: "heart.fill"), tag: 2)
        
        // 4. 学习页
        let learningVC = UINavigationController(rootViewController: LearningViewController())
        learningVC.tabBarItem = UITabBarItem(title: "学习", image: UIImage(systemName: "graduationcap.fill"), tag: 3)
        
        // 设置TabBar控制器
        tabBarController.viewControllers = [browseVC, searchVC, favoritesVC, learningVC]
        
        // 设置根视图控制器
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // 保存数据
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}