import AppKit
import SceneKit

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var mainViewController: MainWindowController!
    private var languageManager = LanguageManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMainMenu()
        setupMainWindow()

        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ notification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func setupMainWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 1200, height: 800)

        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = languageManager.localizedString(for: "app_title")
        window.center()
        window.minSize = NSSize(width: 800, height: 600)

        mainViewController = MainWindowController()
        window.contentViewController = mainViewController

        window.makeKeyAndOrderFront(nil)

        // 监听语言变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: .languageChanged,
            object: nil
        )
    }

    @objc private func languageDidChange() {
        // 更新窗口标题
        window.title = languageManager.localizedString(for: "app_title")

        // 重建菜单
        setupMainMenu()
    }

    private func setupMainMenu() {
        // 移除旧的监听器
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)

        let mainMenu = NSMenu()

        // 应用菜单
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        let appName = ProcessInfo.processInfo.processName
        appMenu.addItem(NSMenuItem(title: "\(languageManager.localizedString(for: "about")) \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "\(languageManager.localizedString(for: "quit")) \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // 游戏菜单
        let gameMenuItem = NSMenuItem()
        mainMenu.addItem(gameMenuItem)

        let gameMenu = NSMenu(title: languageManager.localizedString(for: "game_menu"))
        gameMenuItem.submenu = gameMenu

        gameMenu.addItem(NSMenuItem(title: languageManager.localizedString(for: "new_game"), action: #selector(MainWindowController.newGame), keyEquivalent: "n"))
        gameMenu.addItem(NSMenuItem.separator())
        gameMenu.addItem(NSMenuItem(title: languageManager.localizedString(for: "close_window"), action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))

        // 视图菜单
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)

        let viewMenu = NSMenu(title: languageManager.localizedString(for: "view_menu"))
        viewMenuItem.submenu = viewMenu

        viewMenu.addItem(NSMenuItem(title: languageManager.localizedString(for: "reset_camera"), action: #selector(MainWindowController.resetCamera), keyEquivalent: "r"))

        // 设置菜单
        let settingsMenuItem = NSMenuItem()
        mainMenu.addItem(settingsMenuItem)

        let settingsMenu = NSMenu(title: languageManager.localizedString(for: "settings_menu"))
        settingsMenuItem.submenu = settingsMenu

        // 语言子菜单
        let languageItem = NSMenuItem(title: languageManager.localizedString(for: "language"), action: nil, keyEquivalent: "")
        let languageMenu = NSMenu(title: languageManager.localizedString(for: "language"))

        for (code, name) in languageManager.availableLanguages {
            let item = NSMenuItem(title: name, action: #selector(selectLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = code
            if languageManager.currentLanguage == code {
                item.state = .on
            }
            languageMenu.addItem(item)
        }

        languageItem.submenu = languageMenu
        settingsMenu.addItem(languageItem)

        // 帮助菜单
        let helpMenuItem = NSMenuItem()
        mainMenu.addItem(helpMenuItem)

        let helpMenu = NSMenu(title: languageManager.localizedString(for: "help_menu"))
        helpMenuItem.submenu = helpMenu

        helpMenu.addItem(NSMenuItem(title: languageManager.localizedString(for: "show_help"), action: #selector(MainWindowController.showHelp), keyEquivalent: "?"))

        NSApp.mainMenu = mainMenu

        // 重新添加监听器
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: .languageChanged,
            object: nil
        )
    }

    @objc private func selectLanguage(_ sender: NSMenuItem) {
        if let code = sender.representedObject as? String {
            languageManager.currentLanguage = code
        }
    }
}
