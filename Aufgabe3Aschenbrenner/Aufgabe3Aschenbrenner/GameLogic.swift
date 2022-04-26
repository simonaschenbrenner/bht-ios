//
//  GameLogic.swift
//  Aufgabe3Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 23.05.21.
//

import Foundation

class TTTBrain: GameLogic {
    
    var difficulty: Difficulty
    var player: String // Computer
    var opponent: String // Human
    var firstMove = true
    var smartAI = true
    var opponentDelegate: GameView?
    
    init(difficulty: Difficulty, opponent playerX: Bool, view: GameView) {
        self.difficulty = difficulty
        self.opponentDelegate = view
        if (playerX) {
            self.opponent = "X"
            self.player = "O"
        } else {
            self.opponent = "O"
            self.player = "X"
        }
        if (difficulty == .cheat) {
            smartAI = false
        }
    }
    
    // Game logic adapted and expanded from https://www.geeksforgeeks.org/minimax-algorithm-in-game-theory-set-3-tic-tac-toe-ai-finding-optimal-move/
        
    func boardChanged(board: [[String?]]) -> [[String?]] {
        var mutableBoard = board
        if (firstMove && player == "X") {
            let move = decideFirstMove()
            mutableBoard[move.row][move.col] = player
        } else {
            if(!isGameFinished(board: mutableBoard)) { // Check if opponent made winning move
                let move = findBestMove(mutableBoard)
                mutableBoard[move.row][move.col] = player
                isGameFinished(board: mutableBoard) // Check if player has made winning move
            }
        }
        firstMove = false
        return mutableBoard
    }
    
    func isGameFinished(board: [[String?]]) -> Bool {
        let score = evaluate(board)
        if (score == 10) { // Player has won
            opponentDelegate?.finishGame(value: -1)
        } else if (score == -10) { // Opponent has won
            opponentDelegate?.finishGame(value: 1)
        } else if (score == 0) {
            if (!isMovesLeft(board)) { // Tie
                opponentDelegate?.finishGame(value: 0)
            } else {
                return false
            }
        }
        return true
    }
    
    // Avoid long calculations as there are fixed rules for the first move, see difficulties
    func decideFirstMove() -> Move {
        let random = Int.random(in: 0...4)
        switch difficulty {
        case .easy, .cheat:
            switch random {
            case 0:
                return Move(row: 0, col: 1)
            case 1:
                return Move(row: 1, col: 0)
            case 2:
                return Move(row: 1, col: 2)
            case 3:
                return Move(row: 2, col: 1)
            default:
                return Move(row: 1, col: 1)
            }
        case .hard:
            switch random {
            case 0:
                return Move(row: 0, col: 0)
            case 1:
                return Move(row: 0, col: 2)
            case 2:
                return Move(row: 2, col: 0)
            case 3:
                return Move(row: 2, col: 2)
            default:
                return Move(row: 1, col: 1)
            }
        }
    }
    
    func isMovesLeft(_ board: [[String?]]) -> Bool {
        for row in 0...2 {
            for col in 0...2 {
                if (board[row][col] == nil) {
                    return true
                }
            }
        }
        return false
    }
    
    func findBestMove(_ board: [[String?]]) -> Move {
        var mutableBoard = board
        var bestVal = Int.min
        var bestMove = Move()

        for row in 0...2 {
            for col in 0...2 {
                if (mutableBoard[row][col] == nil) {
                    // Make the move
                    mutableBoard[row][col] = player
                    // Start recursive function with opponent's (minimizer) next move
                    let moveVal = minmax(board: mutableBoard, depth: 0, isMax: !smartAI)
                    // Undo the move
                    mutableBoard[row][col] = nil
                    if (moveVal > bestVal) {
                        bestMove.row = row
                        bestMove.col = col
                        bestVal = moveVal
                    }
                }
            }
        }
        return bestMove
    }
    
    func evaluate(_ board: [[String?]]) -> Int {
        // Check rows for victory
        for row in 0...2 {
            if (board[row][0] == board[row][1] && board[row][1] == board[row][2]) {
                if (board[row][0] == player) {
                    return 10
                } else if (board[row][0] == opponent) {
                    return -10
                }
            }
        }
        // Check columns for victory
        for col in 0...2 {
            if (board[0][col] == board[1][col] && board[1][col] == board[2][col]) {
                if (board[0][col] == player) {
                    return 10
                } else if (board[0][col] == opponent) {
                    return -10
                }
            }
        }
        // Check diagonals for victory
        if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
            if (board[0][0] == player) {
                return 10;
            } else if (board[0][0] == opponent) {
                return -10;
            }
        }
        if (board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
            if (board[0][2] == player) {
                return 10;
            } else if (board[0][2] == opponent) {
                return -10;
            }
        }
        // No victory
        return 0
    }
    
    // Recursive function to compute best strategy
    func minmax(board: [[String?]], depth: Int, isMax: Bool) -> Int {
        let score = evaluate(board)
        // Maximizer has won
        if (score == 10) {
            if (difficulty == .hard) {
                return score - depth
            } else {
                return score
            }
        }
        // Minimizer has won
        if (score == -10) {
            if (difficulty == .hard) {
                return score + depth
            } else {
                return score
            }
        }
        // Tie
        if (!isMovesLeft(board)) {
            return 0;
        }
        
        var mutableBoard = board
        var best: Int?
        // Maximizer's move
        if (isMax) {
            best = Int.min
            for row in 0...2 {
                for col in 0...2 {
                    if (mutableBoard[row][col] == nil) {
                        // Make the move
                        mutableBoard[row][col] = player;
                        // Recursion and choose maximum value
                        best = max(best!, minmax(board: mutableBoard, depth: depth+1, isMax: !isMax))
                        // Undo the move
                        mutableBoard[row][col] = nil
                    }
                }
            }
        }
        // Minimizer's move
        if (!isMax) {
            best = Int.max
            for row in 0...2 {
                for col in 0...2 {
                    if (mutableBoard[row][col] == nil) {
                        // Make the move
                        mutableBoard[row][col] = opponent;
                        // Recursion and choose maximum value
                        best = min(best!, minmax(board: mutableBoard, depth: depth+1, isMax: !isMax))
                        // Undo the move
                        mutableBoard[row][col] = nil
                    }
                }
            }
        }
        return best!
    }
}

protocol GameLogic {
    func boardChanged(board: [[String?]]) -> [[String?]]
}

struct Move {
    var row: Int = -1
    var col: Int = -1
}

enum Difficulty {
    case easy // If computer starts, it will not pick a corner as its first move and will pick a winning strategy at random
    case hard // If computer starts, it will pick a corner as its first move and will pick the quickest winning strategy
    case cheat // Computer will pick the worst strategy, only possibility to win
}
