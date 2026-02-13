import AppKit
import SceneKit
import SwiftUI

class MainWindowController: NSViewController {

    var chessGameView: ChessGameView!
    var gameInfoView: NSHostingView<GameInfoView>!
    var splitView: NSSplitViewController!

    private var gameManager: GameManager!
    private var languageManager = LanguageManager.shared

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height: 800))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gameManager = GameManager()

        setupUI()
        setupBindings()
    }

    private func setupUI() {
        // 创建分割视图
        splitView = NSSplitViewController()
        splitView.view.translatesAutoresizingMaskIntoConstraints = false

        // 3D 游戏视图
        chessGameView = ChessGameView(frame: .zero)
        chessGameView.translatesAutoresizingMaskIntoConstraints = false
        chessGameView.gameManager = gameManager

        let gameViewController = NSViewController()
        gameViewController.view = chessGameView
        gameViewController.view.translatesAutoresizingMaskIntoConstraints = false

        let gameItem = NSSplitViewItem(viewController: gameViewController)
        gameItem.minimumThickness = 600
        gameItem.preferredThicknessFraction = 0.75

        // 信息面板
        let gameInfoViewSwift = GameInfoView(gameManager: gameManager)
        gameInfoView = NSHostingView(rootView: gameInfoViewSwift)
        gameInfoView.translatesAutoresizingMaskIntoConstraints = false

        let infoViewController = NSViewController()
        infoViewController.view = gameInfoView
        infoViewController.view.translatesAutoresizingMaskIntoConstraints = false

        let infoItem = NSSplitViewItem(viewController: infoViewController)
        infoItem.minimumThickness = 200
        infoItem.preferredThicknessFraction = 0.25

        splitView.addSplitViewItem(gameItem)
        splitView.addSplitViewItem(infoItem)

        addChild(splitView)
        splitView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splitView.view)

        NSLayoutConstraint.activate([
            splitView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            splitView.view.topAnchor.constraint(equalTo: view.topAnchor),
            splitView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        gameManager.onGameStateChanged = { [weak self] in
            self?.chessGameView.updatePieces()
            self?.gameInfoView.rootView.gameManager = self!.gameManager
        }

        // 设置初始棋盘
        chessGameView.setupBoard()
    }

    @objc func newGame() {
        gameManager.resetGame()
        chessGameView.setupBoard()
    }

    @objc func resetCamera() {
        chessGameView.resetCamera()
    }

    @objc func showHelp() {
        let alert = NSAlert()
        alert.messageText = languageManager.localizedString(for: "help_title")
        alert.informativeText = languageManager.localizedString(for: "help_text")
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
