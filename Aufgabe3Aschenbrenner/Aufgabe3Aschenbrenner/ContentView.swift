//
//  ContentView.swift
//  Aufgabe3Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 23.05.21.
//

import SwiftUI

struct ContentView: View, GameView {
    
    @State var playerX = true
    @State var isStarted = false
    @State var isFinished = false
    @State var isDifficult = false
    @State var isCheating = false
    @State var gameStatus: String? // nil when game has not yet started
    @State var game: GameLogic?
    @State var board: [[String?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    
    var body: some View {
        
        VStack(spacing: -2) {
            Text(gameStatus ?? "Let's play!")
                .font(.largeTitle).bold()
                .padding(.bottom, 50)
            ForEach(0..<3) { row in
                HStack(spacing: -2) {
                    ForEach(0..<3) { col in
                        Button(action: { move(row: row, col: col) }) {
                            Text(board[row][col] ?? "")
                                .frame(width: 100, height: 100)
                                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                                .font(.system(size: 100, weight: .light))
                                .accentColor(.black)
                        }
                    }
                }
            }
            Toggle(isOn: $isDifficult) { Text("Extra difficult?") }
                .disabled(isStarted)
                .font(.title3)
                .frame(width: 300-4)
                .padding(.top, 30)
            Button(action: { makeFirstMove() }) { Text("Computer, make the first move!") }
                .disabled(isStarted)
                .font(.headline)
                .padding(30)
            Button(action: { resetGame() }) { Text("Start over") }
                .disabled(gameStatus == nil)
                .font(.headline)
                .accentColor(.red)
            Button(action: { isCheating.toggle() }) { Text("Click to cheat 😈")}
                .disabled(isCheating || isStarted)
                .font(.footnote)
                .opacity(0.25)
                .offset(y: 100)
        }

    }
    
    func move(row: Int, col: Int) {
        if (!isStarted) {
            startGame()
        }
        if (!isFinished && board[row][col] == nil) {
            board[row][col] = playerX ? "X" : "O"
            board = game!.boardChanged(board: board)
        }
    }
    
    func makeFirstMove() { // Computer makes the first move
        if (!isFinished && !isStarted) {
            playerX = false
            startGame()
            board = game!.boardChanged(board: board)
        }
    }
    
    func startGame() {
        isStarted = true
        gameStatus = "Playing ..."
        let d: Difficulty?
        if (isCheating) {
            d = .cheat
        } else {
            d = (isDifficult) ? .hard : .easy
        }
        game = TTTBrain(difficulty: d!, opponent: playerX, view: self)
    }
    
    func finishGame(value: Int) {
        isFinished = true
        if (value > 0) {
            gameStatus = "You won!"
        } else if (value < 0) {
            gameStatus = "You lost!"
        } else {
            gameStatus = "It's a tie!"
        }
    }
    func resetGame() {
        playerX = true
        isStarted = false
        isFinished = false
        isCheating = false
        gameStatus = nil
        game = nil
        board = Array(repeating: Array(repeating: nil, count: 3), count: 3)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

protocol GameView {
    func finishGame(value: Int)
}
