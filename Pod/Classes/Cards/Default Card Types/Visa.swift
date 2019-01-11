//
//  Visa.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 *  The native supported card type of Visa
 */
public struct Visa: CardType {
    
    public let name = "Visa"
    
    public let CVCLength = 3
  
    public let lengths = [13, 14, 15, 16, 17, 18, 19]
  
    public let identifyingDigits = Set(40...49).union(450628...450629).union(450640...450641).union(492901...492902).union(Set([413600, 444509, 444550, 450603, 450617, 450636, 450662, 463100, 476142, 476143, 492920, 492923, 492930, 492937, 492939, 492960]))

    public init() {
        
    }

}
