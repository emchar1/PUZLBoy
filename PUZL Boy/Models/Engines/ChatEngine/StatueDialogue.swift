//
//  StatueDialogue.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/31/24.
//

import Foundation

struct StatueDialogue {
    
    // MARK: - Properties
    
    private let dialogue: [ChatItem]
    private var indices: [Int]
    private var shouldSkipFirstQuestion: Bool
    
    private var dialogueIndex: Int = 0 {
        didSet {
            if dialogueIndex >= dialogue.count {
                dialogueIndex = shouldSkipFirstQuestion ? secondQuestion.indexDialogue : 0
            }
        }
    }
    
    private var indicesIndex: Int = 0 {
        didSet {
            if indicesIndex >= indices.count {
                indicesIndex = shouldSkipFirstQuestion ? secondQuestion.indexIndices : 0
            }
        }
    }
    
    ///Skip the first question and go to the second question, because the first question could be an intro, or a story branching decision question, i.e. don't want to be able to overwrite previous response.
    private var secondQuestion: (indexDialogue: Int, indexIndices: Int) {
        return (indices[0], 1)
    }

    
    // MARK: - Initialization
    
    init(dialogue: [ChatItem], indices: [Int], shouldSkipFirstQuestion: Bool) {
        self.dialogue = dialogue
        self.indices = indices
        self.shouldSkipFirstQuestion = shouldSkipFirstQuestion
        
        if shouldSkipFirstQuestion {
            dialogueIndex = secondQuestion.indexDialogue
            indicesIndex = secondQuestion.indexIndices
        }
    }
    
    
    // MARK: - Functions
    
    /**
     This just loops through the conversation in and endless loop, returning the dialogue in the queuefor processing.
     - returns: dialogue in the queue to be processed
     */
    mutating func getDialogue() -> [ChatItem] {
        var items: [ChatItem] = []
        
        for _ in 0..<indices[indicesIndex] {
            items.append(dialogue[dialogueIndex])
            
            dialogueIndex += 1
        }
        
        indicesIndex += 1
        
        return items
    }
}
