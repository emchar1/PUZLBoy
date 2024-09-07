//
//  StatueDialogue.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/31/24.
//

import Foundation

struct StatueDialogue {
    
    // MARK: - Properties
    
    private(set) var dialogue: [ChatItem]
    private(set) var indices: [Int]
    private var shouldSkipFirstQuestion: Bool
    private var shouldRepeatLastDialogueOnEnd: Bool
    
    private var dialogueIndex: Int = 0 {
        didSet {
            if dialogueIndex >= dialogue.count {
                if shouldRepeatLastDialogueOnEnd {
                    dialogueIndex = lastDialogue.indexDialogue
                }
                else if shouldSkipFirstQuestion {
                    dialogueIndex = secondDialogue.indexDialogue
                }
                else {
                    dialogueIndex = 0
                }
            }
        }
    }
    
    private var indicesIndex: Int = 0 {
        didSet {
            if indicesIndex >= indices.count {
                if shouldRepeatLastDialogueOnEnd {
                    indicesIndex = lastDialogue.indexIndices
                }
                else if shouldSkipFirstQuestion {
                    indicesIndex = secondDialogue.indexIndices
                }
                else {
                    indicesIndex = 0
                }
            }
        }
    }
    
    ///Returns the second set of dialogue, because the first set could be an intro, or a story branching decision question, i.e. don't want to repeat or be able to overwrite a previous response.
    private var secondDialogue: (indexDialogue: Int, indexIndices: Int) {
        return (indices[0], 1)
    }
    
    ///Returns the last set of dialogue, i.e. just keep repeating it once you go through all the line of dialogue.
    private var lastDialogue: (indexDialogue: Int, indexIndices: Int) {
        let lastIndex = indices.count - 1
        
        return (indices.reduce(0, +) - indices[lastIndex], lastIndex)
    }

    
    // MARK: - Initialization
    
    init(dialogue: [ChatItem], indices: [Int], shouldSkipFirstQuestion: Bool, shouldRepeatLastDialogueOnEnd: Bool) {
        self.dialogue = dialogue
        self.indices = indices
        self.shouldSkipFirstQuestion = shouldSkipFirstQuestion
        self.shouldRepeatLastDialogueOnEnd = shouldRepeatLastDialogueOnEnd
        
        if shouldSkipFirstQuestion {
            dialogueIndex = secondDialogue.indexDialogue
            indicesIndex = secondDialogue.indexIndices
        }
        
        if shouldRepeatLastDialogueOnEnd {
            dialogueIndex = lastDialogue.indexDialogue
            indicesIndex = lastDialogue.indexIndices
        }
    }
    
    
    // MARK: - Functions
    
    /**
     This just loops through the conversation in and endless loop, returning the dialogue in the queue for processing.
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
    
    mutating func updateDialogue(index: Int, newDialogue: String) {
        var updatedChatItem = dialogue[index]
        updatedChatItem.updateChat(newDialogue)
        
        dialogue[index] = updatedChatItem
    }
    
    ///Updates shouldSkipFirstQuestion property, i.e. once the decision question has been answered, need to update the object so it doesn't ask it again!
    mutating func setShouldSkipFirstQuestion(_ shouldSkipFirstQuestion: Bool) {
        self.shouldSkipFirstQuestion = shouldSkipFirstQuestion
        
        //Careful with resetting to 0! Might not necessarily want to, but I haven't encountered a scenario where I don't want it to be 0. 8/9/24
        dialogueIndex = shouldSkipFirstQuestion ? secondDialogue.indexDialogue : 0
        indicesIndex = shouldSkipFirstQuestion ? secondDialogue.indexIndices : 0
    }
    
    ///Updates shouldRepeatLastDialogueOnEnd property
    mutating func setShouldRepeatLastDialogueOnEnd(_ shouldRepeatLastDialogueOnEnd: Bool) {
        self.shouldRepeatLastDialogueOnEnd = shouldRepeatLastDialogueOnEnd
        
        if shouldRepeatLastDialogueOnEnd {
            dialogueIndex = lastDialogue.indexDialogue
            indicesIndex = lastDialogue.indexIndices
        }
    }
}
