//
//  ContentView.swift
//  WordScramble
//
//  Created by Dr Cpt Blackbeard on 6/13/23.
//
//If a guard check fails we must always exit the current scope.
//That scope is usually a method, but it could also be a loop or a condition.

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    TextField("Enter your word", text: $newWord)
                        .border(showingError ? .red : .clear)
                        .autocapitalization(.none)
                }
                
                Section {
                    // used self because every word is unique
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Text(word)

                            Image(systemName: "\(countCharacters(in: word)).circle.fill")
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
                Button("Restart Game", action: startGame)
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
        
        // Reset new word
        newWord = ""
    }
    
    func countCharacters(in word: String) -> Int {
        // Don't count white spaces
        let numOfWhiteSpace = word.filter { $0 == " "}.count
        return word.count - numOfWhiteSpace
    }
    
    func startGame() {
        // Ask iOS where our start.txt file is located and assign the URL of the file to startFileURL
        if let startFileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {

            // Attempt to load the content of the file at the URL startFileURL into a String object.
            // If it's successful, it assigns the content of the file (as a String) to startWords.
            // Throwing functions are those that will flag up errors if problems happen, and Swift requires you to handle those errors in your code.
            if let startWords = try? String(contentsOf: startFileURL) { // String(contentsOf:) is a throwing function, so use it carefully.
                let allWords = startWords.components(separatedBy: "\n")

                // randomElement return an optional string, because it might be an empty array
                // but rootWord is a non-optional string so we need to nil coalescing and provide a default of 'silkworm' in the rare case we load an empty file.
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    // Check for minimum length
    func isMinLength(word: String, minLength: Int) -> Bool {
        // Must have at least 3 letters of input
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
        // UITextChecker uses the built-in system dictionary, so we don't need to provide any words
        let checker = UITextChecker()
        // check the range of our entire word
        let wordRange = NSRange(location: 0, length: word.utf16.count)
        // range over our range for misspelled words
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: wordRange, startingAt: 0, wrap: false, language: "en")
        
        // If true, then it was a real word - otherwise their was a misspelled word, so return false
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
