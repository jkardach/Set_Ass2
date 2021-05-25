//
//  Deck.swift
//  Set_Ass2
//
//  Created by jim kardach on 5/21/21.
//
/*
 creating a new deck should create a deck of set playing cards
 getCard() -> Card?  // returns a card if availble, else nil
 getCards(int number) -> [Card]
 */

import Foundation

struct Deck {
    private var cards = [Card]()    // the entire deck of cards
    
    init() {
        // create all 80 cards in a deck
        for color in SetColor.allCases {
            for shape in SetShape.allCases {
                for number in SetNumber.allCases {
                    for shading in SetShading.allCases {
                        let card = Card(shape: shape, color: color, number: number, shading: shading)
                        cards.append(card)
                    }
                }
            }
        }
        cards.shuffle()  // shuffle deck
    }
    
    // return a card if available from the deck
    mutating func getCard() -> Card? {
        return cards.popLast()
    }
    
    /**
     Returns the num of cards from the deck in an array
     */
    mutating func getCards(num: Int) -> [Card] {
        var start = [Card]()
        for _ in 0..<num {
            if let card = cards.popLast() {
                start.append(card)
            }
        }
        return start
    }
    
    func count() -> Int {
        return cards.count
    }
    
    func isEmpty() -> Bool {
        return cards.isEmpty
    }
    
}
