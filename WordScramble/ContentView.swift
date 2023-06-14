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
    @State private var errorText = "sdfhjgdfkjhgsdk"
    
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
                        Text(word)
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
        
        //Extra valudation to come
        
        // Add new word to usedWords array
        usedWords.insert(answer, at: 0)
        
        // Reset new word
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
