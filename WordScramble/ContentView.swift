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
    @State private var showError = false
    @State private var errorText = ""
    
    // Calculated property
    var errorMessage: some View {
        if showError {
            return AnyView(Text(errorText)
                .foregroundColor(.red)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    TextField("Enter your word", text: $newWord)
                        .border(showError ? .red : .clear)
                        .autocapitalization(.none)
                    
                    errorMessage
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
        }
    }
    
    func addNewWord() {
        // Lower case and remove all white spaces from user input
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        showError = false
        // Must have at least 1 letter of input (we could use isEmpty, but this is scalable incase we wanna require a minumum of 3 or more letters
        guard answer.count > 0 else {
            showError = true
            errorText = "Please provide at least one letter."
            return
        }
        
        //Extra validation to come
        
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
