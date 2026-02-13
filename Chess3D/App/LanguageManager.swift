import Foundation
import AppKit

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "language")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    let availableLanguages = [
        ("zh", "中文"),
        ("en", "English")
    ]

    private init() {
        // 读取保存的语言设置，如果没有则使用系统语言
        let savedLanguage = UserDefaults.standard.string(forKey: "language")
        if let saved = savedLanguage {
            currentLanguage = saved
        } else {
            // 默认使用中文
            currentLanguage = "zh"
        }
    }

    func localizedString(for key: String) -> String {
        guard let langStrings = Localization.strings[currentLanguage] else { return key }
        return langStrings[key] ?? key
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

struct Localization {
    static let strings: [String: [String: String]] = [
        "zh": [
            "app_title": "3D 国际象棋",
            "game_menu": "游戏",
            "view_menu": "视图",
            "help_menu": "帮助",
            "settings_menu": "设置",
            "new_game": "新游戏",
            "close_window": "关闭窗口",
            "reset_camera": "重置摄像机",
            "show_help": "Chess3D 帮助",
            "language": "语言",
            "current_turn": "当前回合",
            "white": "白方",
            "black": "黑方",
            "check": "将军!",
            "checkmate": "将死!",
            "stalemate": "和棋!",
            "winner": "获胜",
            "draw": "逼和",
            "undo": "悔棋",
            "move_history": "移动记录",
            "about": "关于",
            "quit": "退出",
            "reset_camera_desc": "重置摄像机视角",
            "new_game_desc": "开始新游戏",
            "help_text": """
            操作说明:
            • 点击棋子选中
            • 点击有效移动位置移动棋子
            • 拖拽鼠标旋转视角
            • 滚轮缩放视角
            • 右键拖拽平移视角

            游戏规则:
            • 白方先行
            • 轮流移动棋子
            • 将死对方王即获胜
            """,
            "help_title": "3D 国际象棋帮助"
        ],
        "en": [
            "app_title": "3D Chess",
            "game_menu": "Game",
            "view_menu": "View",
            "help_menu": "Help",
            "settings_menu": "Settings",
            "new_game": "New Game",
            "close_window": "Close Window",
            "reset_camera": "Reset Camera",
            "show_help": "Chess3D Help",
            "language": "Language",
            "current_turn": "Current Turn",
            "white": "White",
            "black": "Black",
            "check": "Check!",
            "checkmate": "Checkmate!",
            "stalemate": "Stalemate!",
            "winner": "wins",
            "draw": "Draw",
            "undo": "Undo",
            "move_history": "Move History",
            "about": "About",
            "quit": "Quit",
            "reset_camera_desc": "Reset camera view",
            "new_game_desc": "Start a new game",
            "help_text": """
            Controls:
            • Click piece to select
            • Click highlighted square to move
            • Drag mouse to rotate view
            • Scroll wheel to zoom
            • Right-click drag to pan

            Rules:
            • White moves first
            • Take turns moving pieces
            • Checkmate the opponent's king to win
            """,
            "help_title": "3D Chess Help"
        ]
    ]
}
