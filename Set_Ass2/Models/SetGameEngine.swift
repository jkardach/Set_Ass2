//
//  SetGameEngine.swift
//  Set_Ass2
//
//  Created by jim kardach on 5/21/21.
//

import Foundation

struct SetGameEngine {
    // scoring for game
    let matchScore = 4
    let misMatchScore = -2
    
    private var deck = Deck()   // get a deck of cards
    var visibleCards = [Card]() // cards that are face-up
    var selectedCards = [Card]()// currently selected cards
    var matchedCards = [Card]() // list of matched cards
    var score = 0
    var cardsLeft: Int {
        return deck.count() + visibleCards.count
    }
    let tableCards: Int
    let startCards: Int
    
    // create game, do initial deal of 12 cards from deck
    init(tableCards: Int = 24, startCards: Int = 12) {
        visibleCards = deck.getCards(num: startCards)  // get 12 cards
        self.startCards = startCards    // how many cards to start
        self.tableCards = tableCards    // how many cards on the table
    }
    
    // selects a card.  If three have been selected, check for match (true if match)
    // if three already selected, empty selectedCards array and add card
    // need to check for the same card for deselect
    mutating func selectCard(card: Card) -> Bool? {
        score = 0
        var match: Bool?
        if deSelected(card: card) { return false }  // if selected same card, deselect
        // remove visible cards if previous was a match
        removeVisibleCardsIfWasAMatch()  // if was a match, remove selected cards
        // add card if it is in the visible list
        if visibleCards.contains(card) {
            selectedCards.append(card)
        }
        if selectedCards.count == 3 {  // 3 cards, check for a match
            match = Card.setMatch(cards: selectedCards)
            matchedCards = matchedCards + selectedCards  // keep a copy of matched cards
            score = match! ? matchScore : misMatchScore
        }
        
        return match
    }
    
    // if card was already selected (in selectedCards array), then deselect
    private mutating func deSelected(card: Card) -> Bool {
        if selectedCards.count < 3 {
            if selectedCards.contains(card) {
                selectedCards.remove(at: selectedCards.firstIndex(of: card)!)
                return true
            }
        }
        return false
    }
    
    // This checks if selected cards was a match.
    // if three cards, possible match
    // if was a match, remove matched cards from visibleCards, and get three new
    // cards from the deck, and remove cards from selected cards array
    mutating func removeVisibleCardsIfWasAMatch() {
        if selectedCards.count == 3 {  // #9 req
            // if was match, remove selected cards from visible, and replace
            // with cards from deck in the same spots
            if Card.setMatch(cards: selectedCards) {
                if deck.isEmpty() {
                    visibleCards = visibleCards.filter {!selectedCards.contains($0) }
                } else {
                    for card in selectedCards {
                        let index = visibleCards.firstIndex(of: card)
                        if let newCard = deck.getCard() {
                            visibleCards[index!] = newCard
                        }
                        
                    }
                }
            }
            selectedCards.removeAll()
        }
    }
    
    // deals three cards from the deck, deselects any cards
    mutating func deal3Cards() {
        let numVisibleCards = visibleCards.count
        removeVisibleCardsIfWasAMatch()
        // if numVisiblecards has not changed, deal 3 more
        if numVisibleCards == visibleCards.count {
            visibleCards += deck.getCards(num: 3)
        }
        selectedCards.removeAll()
    }
    
    // indicates if a deal3MoreCards button is enabled or disabled
    func isDeal3MoreCards() -> Bool {
        // there is a match (3 slots will be freed up)
        let isMatch = selectedCards.count == 3 && Card.setMatch(cards: selectedCards)
        return !deck.isEmpty() && (visibleCards.count + 3 <= tableCards || isMatch)
    }
    
    mutating func isGameOver() -> Bool {
        if deck.isEmpty() && visibleCards.count == 0 || deck.isEmpty() && !areTheirMatches() {
            return true
        }
        return false
    }
    
    mutating func clearSelectedCards() {
        selectedCards.removeAll()
    }
    
    mutating func areTheirMatches() -> Bool {
        let cards = findMatchableSet()
        return cards == nil ? false : true
    }
    
    // This creates an array of a matchable set
    mutating func findMatchableSet() -> [Card]? {
        var found = false
        var cards = [Card]()
        for i in 0..<visibleCards.count {
            for j in (i+1)..<visibleCards.count {
                for k in (j+1)..<visibleCards.count {
                    cards = [visibleCards[i], visibleCards[j], visibleCards[k]]
                    if Card.setMatch(cards: cards) {
                        found = true
                        break
                    }
                }
                if found { break }
            }
            if found {break}
        }
        return found ? cards : nil
    }
    
}

