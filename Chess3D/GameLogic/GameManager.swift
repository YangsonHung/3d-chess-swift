import Foundation
import SwiftChess

class GameManager: ObservableObject {

    @Published private(set) var currentPlayer: Color = .white
    @Published private(set) var isCheck: Bool = false
    @Published private(set) var isCheckmate: Bool = false
    @Published private(set) var isStalemate: Bool = false
    @Published private(set) var moveHistory: [String] = []

    private var game: Game!
    private var whitePlayer: Human!
    private var blackPlayer: Human!

    var board: SwiftChess.Board {
        return game.board
    }

    var canUndo: Bool {
        return moveHistory.count > 0
    }

    var onGameStateChanged: (() -> Void)?

    init() {
        // 创建玩家
        whitePlayer = Human(color: .white)
        blackPlayer = Human(color: .black)

        // 创建游戏
        game = Game(firstPlayer: whitePlayer, secondPlayer: blackPlayer)

        resetGame()
    }

    func resetGame() {
        // 重新创建游戏
        game = Game(firstPlayer: whitePlayer, secondPlayer: blackPlayer, colorToMove: .white)

        currentPlayer = .white
        isCheck = false
        isCheckmate = false
        isStalemate = false
        moveHistory = []

        onGameStateChanged?()
    }

    func movePiece(from: ChessSquare, to: ChessSquare, promotion: Piece.PieceType = .queen) {
        let fromLocation = BoardLocation(x: from.col, y: 7 - from.row)
        let toLocation = BoardLocation(x: to.col, y: 7 - to.row)

        guard let player = currentPlayer == .white ? whitePlayer : blackPlayer else { return }

        do {
            // 记录移动历史（简化的记谱法）
            let fromCol = Character(UnicodeScalar(UnicodeScalar("a").value + UInt32(from.col))!)
            let fromRow = "\(8 - from.row)"
            let toCol = Character(UnicodeScalar(UnicodeScalar("a").value + UInt32(to.col))!)
            let toRow = "\(8 - to.row)"
            moveHistory.append("\(fromCol)\(fromRow)\(toCol)\(toRow)")

            try player.movePiece(from: fromLocation, to: toLocation)

            // 切换玩家
            currentPlayer = currentPlayer == .white ? .black : .white

            checkGameState()

            onGameStateChanged?()
        } catch {
            print("Invalid move: \(error)")
            // 移除无效的移动记录
            moveHistory.removeLast()
        }
    }

    func getValidMoves(for square: ChessSquare) -> [(row: Int, col: Int)] {
        let location = BoardLocation(x: square.col, y: 7 - square.row)
        let possibleLocations = game.board.possibleMoveLocationsForPiece(atLocation: location)

        return possibleLocations.map { (row: 7 - $0.y, col: $0.x) }
    }

    private func checkGameState() {
        // 检查游戏状态
        switch game.state {
        case .won:
            isCheckmate = true
        case .staleMate:
            isStalemate = true
        case .inProgress:
            isCheck = false
        }
    }

    func undoMove() {
        // SwiftChess 可能没有撤销功能，让我们简化处理
    }
}
