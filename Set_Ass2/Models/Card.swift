//
//  Card.swift
//  Set_Ass2
//
//  Created by jim kardach on 5/21/21.
//

import Foundation

/*
 Any set the number of features that are all the same and the number of features that are all different may break down as
    * 0 the same + 4 different, or
    * 1 the same + 3 different, or
    * 2 the same + 2 different, or
    * 3 the same + 1 different
 
  0 the same + 4 different:
    shape: oval, squiggle, diamond
    color: red, green purple
    number: one, two, three
    shading: solid, striped, outlined
 
 1 the same + 3 different
 
 
 */
enum SetShape: Int, CaseIterable {
    case shape1 = 0, shape2, shape3
}
enum SetColor: Int, CaseIterable {
    case color1 = 0, color2, color3
}
enum SetNumber: Int, CaseIterable {
    case number1 = 1, number2, number3
}
enum SetShading: Int, CaseIterable {
    case shading1 = 0, shading2, shading3
}

struct Card: Equatable {

    let shape: SetShape
    let color: SetColor
    let number: SetNumber
    let shading: SetShading
    var id: Int
    private static var idFactory = 0;
    
    private static func getID() -> Int {
        idFactory += 1
        return idFactory
    }
    
    // Card(shape: shape, color: color, number: number, shading: shading)
    init(shape: SetShape, color: SetColor, number: SetNumber, shading: SetShading) {
        self.shape = shape
        self.color = color
        self.number = number
        self.shading = shading
        self.id = Card.getID()
    }
    // returns true if three cards match
    // match is all elements are different or same
    static func setMatch(cards: [Card]) -> Bool {

        var isShapeMatch = false
        var isColorMatch = false
        var isNumberMatch = false
        var isShadingMatch = false
        
        switch (cards[0].shape, cards[1].shape, cards[2].shape) {
        case (.shape1, .shape1, .shape1),
             (.shape2, .shape2, .shape2),
             (.shape3, .shape3, .shape3),
             (.shape1, .shape2, .shape3), (.shape1, .shape3, .shape2),
             (.shape2, .shape1, .shape3), (.shape2, .shape3, .shape1),
             (.shape3, .shape1, .shape2), (.shape3, .shape2, .shape1):
            isShapeMatch = true
        default:
            isShapeMatch = false
        }
        
        switch (cards[0].color, cards[1].color, cards[2].color) {
        case (.color1, .color1, .color1),
             (.color2, .color2, .color2),
             (.color3, .color3, .color3),
             (.color1, .color2, .color3), (.color1, .color3, .color2),
             (.color2, .color1, .color3), (.color2, .color3, .color1),
             (.color3, .color1, .color2), (.color3, .color2, .color1):
            isColorMatch = true
        default:
            isColorMatch = false
        }
        
        switch (cards[0].number, cards[1].number, cards[2].number) {
        case (.number1, .number1, .number1),
             (.number2, .number2, .number2),
             (.number3, .number3, .number3),
             (.number1, .number2, .number3), (.number1, .number3, .number2),
             (.number2, .number1, .number3), (.number2, .number3, .number1),
             (.number3, .number1, .number2), (.number3, .number2, .number1):
            isNumberMatch = true
        default:
            isNumberMatch = false
        }
        
        switch (cards[0].shading, cards[1].shading, cards[2].shading) {
        case (.shading1, .shading1, .shading1),
             (.shading2, .shading2, .shading2),
             (.shading3, .shading3, .shading3),
             (.shading1, .shading2, .shading3), (.shading1, .shading3, .shading2),
             (.shading2, .shading1, .shading3), (.shading2, .shading3, .shading1),
             (.shading3, .shading1, .shading2), (.shading3, .shading2, .shading1):
            isShadingMatch = true
        default:
            isShadingMatch = false
        }
        return isShapeMatch && isColorMatch && isNumberMatch && isShadingMatch
    }
}

