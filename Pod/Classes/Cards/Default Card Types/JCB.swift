//
//  JCB.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 *  The native supported card type of JCB, Japan Credit Bureau
 */
public struct JCB: CardType {
    
    public let name = "JCB"
    
    public let CVCLength = 3
    
    public let identifyingDigits = Set([35])

    public init() {
        
    }

}
