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
    
//    @State private var showingError = false
//    @State private var errorText = ""
    
    @State private var showingError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    // Calculated property
//    var errorMessage: some View {
//        if showingError {
//            return AnyView(Text(errorText)
//                .foregroundColor(.red)
//                .font(.subheadline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                )
//        } else {
//            return AnyView(EmptyView())
//        }
//    }
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    TextField("Enter your word", text: $newWord)
                        .border(showingError ? .red : .clear)
                        .autocapitalization(.none)
                    
//                    errorMessage
                }
                
                Section {
                    // used self because every word is unique
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Text(word)
                            
                            // Count and display number of non-whitespace characters
                            Image(systemName: "\(countCharacters(in: word)).circle.fill")
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        // Lower case and remove all white spaces from user input
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        showingError = false
        // Must have at least 1 letter of input (we could use isEmpty, but this is scalable incase we wanna require a minumum of 3 or more letters
        guard answer.count > 0 else {
//            showingError = true
//            errorText = "Please provide at least one letter."
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
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
            if let startWords = try? String(contentsOf: startFileURL) {
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
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
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
