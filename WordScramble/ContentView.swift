//
//  ContentView.swift
//  WordScramble
//
//  Created by Dr Cpt Blackbeard on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var totalScore = 0
    
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .border(showingError ? .red : .clear)
                        .autocapitalization(.none)
                    
                    Text("Score: \(totalScore)")
                        .monospaced()
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Text(word)
                            Image(systemName: "\(word.count).circle.fill")
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart", action: startGame)
            }
        }
    }
    
    func addNewWord() {
        // Lower case and remove all white spaces from user input
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Must have a minmum set of characters for input
        guard isMinLength(word: answer, minLength: 3) else {
            wordError(title: "Word is too short", message: "Use at least \(3) letters.")
            return
        }
        
        // Can't use our starting word/root word
        guard isRootWord(word: answer) else {
            wordError(title: "Word matches root word", message: "Using the root word doesn't make this much of a word 'scramble' does it?")
            return
        }
        
        // Must not be a duplicate guess
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }
        
        // Must have correct letters from word
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        // Must be an actual word
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        // Add new word to usedWords array
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        // Add to score total
        totalScore += answer.count
        
        // Reset new word
        newWord = ""
        totalScore = 0
    }
    
    func startGame() {
        // Ask iOS where our start.txt file is located and assign the URL of the file to startFileURL
        if let startFileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            if let startWords = try? String(contentsOf: startFileURL) {
                let allWords = startWords.components(separatedBy: "\n")
                usedWords = []
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    // Check for minimum length
    func isMinLength(word: String, minLength: Int) -> Bool {
        return word.count >= minLength
    }
    
    // Check for root word as user answer
    func isRootWord(word: String) -> Bool {
        return word != rootWord
    }
    
    // Check for duplicates
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Check for words that exist
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    // Check for mispelled words
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        // check the range of our entire word
        let wordRange = NSRange(location: 0, length: word.utf16.count)
        // range over our range for misspelled words
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: wordRange, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
