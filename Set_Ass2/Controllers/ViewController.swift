//
//  ViewController.swift
//  Set_Ass2
//
//  Created by jim kardach on 5/20/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var gameScore: UILabel!       // gameScore label
    @IBOutlet var setButtons: [UIButton]!  // Cards on the Screen
    @IBOutlet var deal3MoreButton: UIButton!
    @IBOutlet var newGameButton: UIButton!
    @IBOutlet var tauntLabel: UILabel!
    @IBOutlet var cheatButton: UIButton!
    
    let cornerRadius: CGFloat = 8.0
    let multipleLines = 0
    var game: SetGameEngine!
    let shapes = ["▲", "●", "■"]    // shapes
    let colors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]       // colors
    let shadedAlpha = [1, 1, 0.3];  // shaded index
    let shadedStrokeWidth = [-15, 15, 15] // shaded index
    var match = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newGameButton.layer.cornerRadius = cornerRadius
        deal3MoreButton.layer.cornerRadius = cornerRadius
        cheatButton.layer.cornerRadius = cornerRadius
        cheatButton.pulsate()
        gameScore.text = "Score = 0"
        tauntLabel.text = " "
        
        initGame()
    }
    
    func initGame() {
        game = SetGameEngine()      // creates deck, 12 cards are ready to go
        gameScore.text = "Score = 0"
        tauntLabel.text = ""
        deal3MoreButton.isEnabled = true
        deal3MoreButton.alpha = 1
        
        // show the startcards
        for index in 0..<game.tableCards {
            let button = setButtons[index]
            button.titleLabel?.numberOfLines = multipleLines
            button.setTitle(nil, for: .normal)
            button.setAttributedTitle(nil, for: .normal)
            button.layer.cornerRadius = cornerRadius
            button.isEnabled = false
            
            if index < game.startCards {
                button.backgroundColor = UIColor.white
                let card = game.visibleCards[index]
                showCard(from: button, and: card)
                button.tag = card.id        // associate the button with the card
                button.isEnabled = true
            } else {
                button.backgroundColor = UIColor.systemBlue
                button.tag = -1
                button.isEnabled = false
            }
        }

    }
    
    /**
     UpdateView updates the cards on the screen
     */
    func updateView() {
        // show the startcards
        for index in 0..<game.tableCards {  // all buttons
            let button = setButtons[index]
            button.setTitle(nil, for: .normal)
            button.setAttributedTitle(nil, for: .normal)
            button.layer.borderColor = UIColor.clear.cgColor
            button.isEnabled = false
            if index < game.visibleCards.count { // visible cards
                button.isEnabled = true
                button.layer.borderWidth = 0.0
                button.backgroundColor = UIColor.white
                let card = game.visibleCards[index]
                showCard(from: button, and: card)
                button.tag = card.id        // associate the button with the card

                if game.selectedCards.contains(card) {
                    button.layer.borderWidth = 3.0
                    if match {
                        // show a match
                        button.layer.borderColor = UIColor.green.cgColor
                    } else {
                        // select the card
                        button.layer.borderColor = UIColor.blue.cgColor
                    }
                }
                
            } else if(index < game.cardsLeft) {  // flipped down cards
                button.tag = -1
                button.backgroundColor = UIColor.systemBlue
            } else {                             // invisible cards
                button.tag = -1
                button.backgroundColor = UIColor.clear;
            }
        }  // end for loop
        // enable/disable deal 3 card button
        deal3MoreButton.isEnabled = game.isDeal3MoreCards() ? true : false
        deal3MoreButton.alpha = game.isDeal3MoreCards() ? 1.0 : 0.5
        gameScore.text = "Score: \(game.score)"
    }

    @IBAction func deal3CardsButton(_ sender: UIButton) {
        game.deal3Cards()
        updateView()
    }
    
    @IBAction func newGameButton(_ sender: Any) {
        initGame()
    }
    
    
    @IBAction func cardButtonPressed(_ sender: UIButton) {
        tauntLabel.text = ""
        match = game.selectCard(card: getCardFrom(sender.tag)!)
        if match {
            let selectedButtons = getButtonFromSelectedCards(cards: game.selectedCards)
            for button in selectedButtons {
                button.flash()
            }
        }
        updateView()
    }
    
    @IBAction func cheatButton(_ sender: UIButton) {
        if let cards = game.findMatchableSet() {
            let cheatButtons = getButtonFromSelectedCards(cards: cards)
            for button in cheatButtons {
                button.flash()
            }
        } else {
            tauntLabel.text = "No matches"
        }
        updateView()
    }
    
    
    // gets the card from id.
    func getCardFrom(_ id: Int) -> Card? {
        var theCard:Card?
        for card in game.visibleCards {
            if card.id == id {
                theCard = card
                break
            }
        }
        return theCard
    }
    
    // returns array of selected cards
    func getButtonFromSelectedCards(cards: [Card]) -> [UIButton] {
        var selectedButtons = [UIButton]()  // create array to hold buttons
        for button in setButtons {      // iterate through selected cards
            for card in cards {
                if card.id == button.tag {
                    selectedButtons.append(button)
                }
            }
        }
        return selectedButtons
    }
    
    // this shows the cards on the view faceup
    func showCard(from button: UIButton, and card: Card) {
        button.setAttributedTitle(symbol(card: card), for: .normal)
        
    }
    
    // this function creates an attributed string symbol from a card
    func symbol(card: Card) -> NSAttributedString {
        func getSymbol(card: Card) -> NSAttributedString {
            let font = UIFont.systemFont(ofSize: 30)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: colors[card.color.rawValue].withAlphaComponent(CGFloat(shadedAlpha[card.shading.rawValue])),
                .strokeWidth: shadedStrokeWidth[card.shading.rawValue],
                .strokeColor: colors[card.color.rawValue].withAlphaComponent(CGFloat(shadedAlpha[card.shading.rawValue]))
            ]
            return NSAttributedString(string: shapes[card.shape.rawValue], attributes: attributes)
        }
        let symbol = getSymbol(card: card)
        var result = symbol
        for _ in 0..<card.number.rawValue-1 {
            result += NSAttributedString(string: "\n") + symbol
        }
        return result
    }
}

// this extension is used to concat NSAttributedStrings via + and +=
extension NSAttributedString {
    static func += ( left: inout NSAttributedString, right: NSAttributedString) {
        left = left + right
    }
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
    }
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.3
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        layer.add(flash, forKey: nil)
    }
}
