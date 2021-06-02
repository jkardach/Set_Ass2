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
    @IBOutlet var tauntLabel: UILabel! {
        didSet {
            tauntLabel.text = ""
        }
    }
    @IBOutlet var cheatButton: UIButton!
    @IBOutlet var iPhoneButton: UIButton!
    
    let CORNER_RADIUS: CGFloat = 8.0
    let MULTIPLE_LINES = 0
    let SHAPES = ["▲", "●", "■"]    // shapes (triangle, circle, square)
    let COLORS = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)]       // colors (red, green, purple)
    let SHADED_ALPHAS = [1, 1, 0.3];  // shaded index (outline, solid, shaded)
    let SHADED_STROKEWIDTH = [-15, 15, 15] // shaded index (outline, solid, shaded)
    
    var game: SetGameEngine!
    var match = false
    var start: Date?
    var timer = Timer()
    
    // used for iphone AutoPlay
    var playerScore = 0     // keeps track of player's score
    var iphoneScore = 0     // keeps track of iphone score
    
    // anytime score is set, updates UILabel
    var score: Int = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newGameButton.layer.cornerRadius = CORNER_RADIUS
        deal3MoreButton.layer.cornerRadius = CORNER_RADIUS
        cheatButton.layer.cornerRadius = CORNER_RADIUS
        iPhoneButton.layer.cornerRadius = CORNER_RADIUS
        
        tauntLabel.lineBreakMode = .byWordWrapping
        tauntLabel.numberOfLines = MULTIPLE_LINES
        
        initGame()
    }
    
    func initGame() {
        game = SetGameEngine()      // creates deck, 12 cards are ready to go
        tauntLabel.text = ""
        deal3MoreButton.isEnabled = true
        deal3MoreButton.alpha = 1
        
        // show the startcards
        for index in 0..<game.tableCards {
            let button = setButtons[index]
            button.titleLabel?.numberOfLines = MULTIPLE_LINES
            button.setTitle(nil, for: .normal)
            button.setAttributedTitle(nil, for: .normal)
            button.layer.cornerRadius = CORNER_RADIUS
            button.layer.borderWidth = 3
            button.isEnabled = false
            
            if index < game.startCards {
                button.backgroundColor = UIColor.white
                button.layer.borderColor = UIColor.white.cgColor // same as background
                let card = game.visibleCards[index]
                showCard(from: button, and: card)
                button.tag = card.id        // associate the button with the card
                button.isEnabled = true
            } else {
                button.layer.borderColor = UIColor.systemBlue.cgColor // same as background
                button.backgroundColor = UIColor.systemBlue
                button.tag = -1
                button.isEnabled = false
            }
        }
        start = Date()
    }
    
    /**
     UpdateView updates the cards on the screen
     */
    func updateView() {
        // update on the main thread (works if called by closure)
        DispatchQueue.main.async {
            for index in 0..<self.game.tableCards {  // all buttons
                let button = self.setButtons[index]
                button.setTitle(nil, for: .normal)
                button.setAttributedTitle(nil, for: .normal)
                //button.layer.borderColor = UIColor.systemBlue.cgColor // same as background
                button.isEnabled = false
                if index < self.game.visibleCards.count { // visible cards
                    button.isEnabled = true
                    //button.layer.borderWidth = 0.0
                    button.backgroundColor = UIColor.white
                    let card = self.game.visibleCards[index]
                    self.showCard(from: button, and: card)
                    button.tag = card.id        // associate the button with the card
                    
                    if self.game.selectedCards.contains(card) {
                        //button.layer.borderWidth = 3.0
                        if self.match {
                            // show a match
                            button.layer.borderColor = UIColor.green.cgColor
                        } else {
                            // select the card
                            button.layer.borderColor = UIColor.blue.cgColor
                        }
                    } else {
                        // not selected, but visible
                        button.layer.borderColor = UIColor.white.cgColor
                    }
                    
                } else if(index < self.game.cardsLeft) {  // flipped down cards
                    button.tag = -1
                    button.backgroundColor = UIColor.systemBlue
                } else {                             // invisible cards
                    button.tag = -1
                    button.backgroundColor = UIColor.clear;
                }
            }  // end for loop
            // enable/disable deal 3 card button
            self.deal3MoreButton.isEnabled = self.game.isDeal3MoreCards() ? true : false
            self.deal3MoreButton.alpha = self.game.isDeal3MoreCards() ? 1.0 : 0.5
        }
    }

    @IBAction func deal3CardsButton(_ sender: UIButton) {
        game.deal3Cards()
        if game.areTheirMatches() {
            tauntLabel.text = "You game up too easily, there were matches!"
            score -= 2
        }
        updateView()
    }
    
    @IBAction func newGameButton(_ sender: Any) {
        initGame()
    }
    //action: ((UIButton) -> Void)? = nil) {

    @IBAction func cardButtonPressed(_ sender: UIButton) {
        tauntLabel.text = ""
        let card = getCardFrom(sender.tag)
        // selectCard returns boolean optional, true or false if match, nil otherwise (deselect)
        if let aMatch = game.selectCard(card: card!) {
            match = aMatch
            if match {
                let duration = Date().timeIntervalSince(start!)
                score += game.score + (Int) (5.0 / duration)
                let selectedButtons = getButtonFromSelectedCards(cards: game.selectedCards)
                for button in selectedButtons {
                    button.flash()
                }
            } else {    // not a match
                score -= 2
            }
            start = Date()  // start new time
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
            updateView()
        }
    }
    
    @IBAction func playAgainstIphoneButton(_ sender: UIButton) {
        if(!timer.isValid) {
            playerScore = score
            sender.backgroundColor = UIColor.green
            self.tauntLabel.text = "🤔"
            // repeatable timer, every 4-10 seconds it fires
            timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 4..<10), repeats: true){ (timer) in
                self.tauntLabel.text = "😁"
                // make move in 2 seconds
                self.playerScore = self.score   // before iphone move, scores is players
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false){ (timer) in
                    if let cards = self.game.findMatchableSet() {
                        self.game.clearSelectedCards()
                        let matchButtons = self.getButtonFromSelectedCards(cards: cards)
                        let card = matchButtons[2]
                        self.cardButtonPressed(matchButtons[0])
                        self.cardButtonPressed(matchButtons[1])
                        self.cardButtonPressed(card)
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                            self.cardButtonPressed(card)
                        }
                        self.iphoneScore += self.score - self.playerScore // set iphone score
                        self.score -= self.playerScore
                        self.tauntLabel.text = "🤔"
                        
                    } else {
                        if self.game.isGameOver() {
                            if self.playerScore > self.iphoneScore {
                                self.tauntLabel.text = "😢 - You Win! (\(self.score) Vs. \(self.iphoneScore))"
                            } else {
                                self.tauntLabel.text = "🥳 - You Lose! (\(self.iphoneScore) Vs. \(self.score))"
                            }
                            self.timer.invalidate()
                        } else {
                            sender.backgroundColor = UIColor.systemYellow
                            let temp = UIButton()
                            self.deal3CardsButton(temp)  // not match, so deal 3 more cards
                        }
                    }
                }
            }
        } else {
            sender.backgroundColor = UIColor.yellow
            timer.invalidate()
        }
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
    
    // gets called when device is rotated
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        updateView()
    }

    
    // this function creates an attributed string symbol from a card
    func symbol(card: Card) -> NSAttributedString {
        func getSymbol(card: Card) -> NSAttributedString {
            let font = UIFont.systemFont(ofSize: 30)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: COLORS[card.color.rawValue].withAlphaComponent(CGFloat(SHADED_ALPHAS[card.shading.rawValue])),
                .strokeWidth: SHADED_STROKEWIDTH[card.shading.rawValue],
                .strokeColor: COLORS[card.color.rawValue].withAlphaComponent(CGFloat(SHADED_ALPHAS[card.shading.rawValue]))
            ]
            return NSAttributedString(string: SHAPES[card.shape.rawValue], attributes: attributes)
        }
        let symbol = getSymbol(card: card)
        var result = symbol
        for _ in 0..<card.number.rawValue-1 {
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
                UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                result += symbol
            } else {
                result += NSAttributedString(string: "\n") + symbol
            }
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
//    func pulsate() {
//        let pulse = CASpringAnimation(keyPath: "transform.scale")
//        pulse.duration = 0.4
//        pulse.fromValue = 0.98
//        pulse.toValue = 1.0
//        pulse.autoreverses = true
//        pulse.repeatCount = .infinity
//        pulse.initialVelocity = 0.5
//        pulse.damping = 1.0
//        layer.add(pulse, forKey: nil)
//    }
    func flash(_ action: (() -> Void)? = nil) {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.3
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        layer.add(flash, forKey: nil)
        if action != nil {
            action!()
        }
    }
}
