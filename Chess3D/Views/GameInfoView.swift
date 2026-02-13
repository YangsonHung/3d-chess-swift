import SwiftUI

struct GameInfoView: View {
    @ObservedObject var gameManager: GameManager
    @StateObject private var languageManager = LanguageManager.shared

    private var lang: [String: String] {
        Localization.strings[languageManager.currentLanguage] ?? Localization.strings["zh"]!
    }

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text(lang["app_title"] ?? "3D Chess")
                .font(.system(size: 24, weight: .bold))

            Divider()

            // 当前回合
            VStack(spacing: 8) {
                Text(lang["current_turn"] ?? "Current Turn")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Circle()
                        .fill(gameManager.currentPlayer == .white ? Color.white : Color.black)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                    Text(gameManager.currentPlayer == .white ? (lang["white"] ?? "White") : (lang["black"] ?? "Black"))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            Divider()

            // 游戏状态
            if gameManager.isCheck {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)

                    Text(lang["check"] ?? "Check!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }

            if gameManager.isCheckmate {
                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)

                    Text(lang["checkmate"] ?? "Checkmate!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(gameManager.currentPlayer == .white ? (lang["black"] ?? "Black") : (lang["white"] ?? "White")) \(lang["winner"] ?? "wins")")
                        .foregroundColor(.secondary)
                }
            }

            if gameManager.isStalemate {
                VStack(spacing: 8) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)

                    Text(lang["stalemate"] ?? "Stalemate!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(lang["draw"] ?? "Draw")
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // 操作按钮
            VStack(spacing: 12) {
                Button(action: {
                    gameManager.resetGame()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text(lang["new_game"] ?? "New Game")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    gameManager.undoMove()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(lang["undo"] ?? "Undo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .disabled(!gameManager.canUndo)
            }

            Spacer()

            // 移动历史
            VStack(alignment: .leading, spacing: 4) {
                Text(lang["move_history"] ?? "Move History")
                    .font(.headline)

                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(gameManager.moveHistory.enumerated()), id: \.offset) { index, move in
                            if index % 2 == 0 {
                                Text("\(index/2 + 1). \(move)")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.primary)
                            } else {
                                Text(move)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .frame(maxHeight: 150)
            }

            Spacer()
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            // 强制刷新视图
            languageManager.objectWillChange.send()
        }
    }
}
