//
//  Discover.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/17/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import UIKit

/**
 *  The native supported card type of Discover
 */
public struct Discover: CardType {

    public let name = "Discover"
    
    public let CVCLength = 3
    
    public let identifyingDigits = Set(64...65).union(Set([60]))

    public init() {
        
    }
    
}
