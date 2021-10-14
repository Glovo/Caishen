//
//  MultipleGroupingsCardType.swift
//  CaishenTests
//
//  Created by Anton Nazarov on 12.10.2021.
//  Copyright © 2021 Prolific Interactive. All rights reserved.
//

import Caishen

struct MultipleGroupingsCardType: CardType {
    public let name = "MultipleGroupingsCardType"

    public let CVCLength = 3

    public let identifyingDigits = Set([67])

    let numberGroupings = [
        [4, 4, 4, 4],
        [4, 4, 4, 4, 3]
    ]
}
