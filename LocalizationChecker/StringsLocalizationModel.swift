//
//  StringsLocalizationModel.swift
//  CPL_LocalizationChecker
//
//  Created by Adrian Ziemecki on 16/11/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

struct StringsLocalization {
    let filePath: URL
    let strings: [String]
    var missingStrings: [String]

    init(filePath: URL, strings: [String]) {
        self.filePath = filePath
        self.strings = strings
        self.missingStrings = [String]()
    }
}
