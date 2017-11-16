//
//  Configuration.swift
//  LocalizationChecker
//
//  Created by Adrian Ziemecki on 09/11/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

class Configuration {
    static let inputFolderKey = "-inputFolder"
    static let inputFilenameKey = "-inputFile"
    static let localizableFilenameKey = "-stringsFile"
    static let outputFolderKey = "-outputFolder"
    static let outputFilenameKey = "-outputFile"
    static let verboseFlagKey = "-verbose"
    static let localizableExtension = "strings"
    static let inputExtension = "swift"
    static let outputExtension = "txt"

    var inputFolder: String = Bundle.main.bundlePath
    var inputFilename: String = "LocalizedStrings"
    var localizableFilename: String = "Localizable"
    var outputFolder: String = Bundle.main.bundlePath
    var outputFilename: String = "LocalizationCheckerOutput"
    var verboseFlag = false

    init(arguments: [String]) {
        for (index, argument) in arguments.enumerated() {
            switch argument {
            case Configuration.inputFolderKey where index + 1 < arguments.count:
                inputFolder = arguments[index + 1]
            case Configuration.inputFilenameKey where index + 1 < arguments.count:
                inputFilename = arguments[index + 1]
            case Configuration.localizableFilenameKey where index + 1 < arguments.count:
                localizableFilename = arguments[index + 1]
            case Configuration.outputFolderKey where index + 1 < arguments.count:
                outputFolder = arguments[index + 1]
            case Configuration.outputFilenameKey where index + 1 < arguments.count:
                outputFilename = arguments[index + 1]
            case Configuration.verboseFlagKey:
                verboseFlag = true
            default:
                continue
            }
        }
    }
}
