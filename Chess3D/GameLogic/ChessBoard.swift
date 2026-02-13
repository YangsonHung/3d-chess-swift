import Foundation
import SwiftChess

struct ChessSquare: Equatable, Hashable {
    let row: Int
    let col: Int

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

class SquareModel {
    var piece: Piece?

    init(piece: Piece? = nil) {
        self.piece = piece
    }
}

class Board {
    private var squares: [[SquareModel]]

    init() {
        squares = Array(repeating: Array(repeating: SquareModel(), count: 8), count: 8)
    }

    func getSquare(at square: ChessSquare) -> SquareModel? {
        guard square.row >= 0 && square.row < 8 && square.col >= 0 && square.col < 8 else {
            return nil
        }
        return squares[square.row][square.col]
    }

    func setPiece(_ piece: Piece, at square: ChessSquare) {
        guard square.row >= 0 && square.row < 8 && square.col >= 0 && square.col < 8 else {
            return
        }
        squares[square.row][square.col].piece = piece
    }

    func clearPiece(at square: ChessSquare) {
        guard square.row >= 0 && square.row < 8 && square.col >= 0 && square.col < 8 else {
            return
        }
        squares[square.row][square.col].piece = nil
    }

    func piece(at square: ChessSquare) -> Piece? {
        return self.getSquare(at: square)?.piece
    }

    func isEmpty(at square: ChessSquare) -> Bool {
        return piece(at: square) == nil
    }

    func isOccupied(by player: Color, at square: ChessSquare) -> Bool {
        guard let piece = piece(at: square) else { return false }
        return piece.color == player
    }
}
