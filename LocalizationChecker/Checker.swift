//
//  Checker.swift
//  LocalizationChecker
//
//  Created by Adrian Ziemecki on 09/11/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

class Checker {
    static let quotationMark = "\""
    static let commentMark = "//"
    static let localizedMark = "localizedString(\""

    private let configuration: Configuration
    private var usedStringVars = [String]()
    private var localizations = [StringsLocalization]()
    private var output: String = ""
    private var inputFilename: String {
        return "\(configuration.inputFilename).\(Configuration.inputExtension)"
    }
    private var stringsFilename: String {
        return "\(configuration.localizableFilename).\(Configuration.localizableExtension)"
    }
    private var outputFilename: String {
        return "\(configuration.outputFilename).\(Configuration.outputExtension)"
    }

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func check() {
        guard let inputFile = inputFileUrl(forPath: configuration.inputFolder) else { return }
        guard let inputData = stringFromFile(inputFile) else { return }
        usedStringVars = getUsedStrings(from: inputData)

        let localizableStrings = stringsUrls(forPath: configuration.inputFolder)
        localizations = getLocalizations(from: localizableStrings)

        lookForMissingStrings()
        saveOutput()
    }
}

// Load files
extension Checker {
    private func inputFileUrl(forPath path: String) -> URL? {
        let pathUrl = URL(fileURLWithPath: path, isDirectory: true)
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        let enumerator = fileManager.enumerator(at: pathUrl, includingPropertiesForKeys: nil, options: options, errorHandler: {(url, error) -> Bool in
            return true
        })
        if let enumerator = enumerator {
            while let path = enumerator.nextObject() as? URL {
                if path.lastPathComponent == inputFilename {
                    return path
                }
            }
        }
        print("Could not find input file: \(inputFilename)")
        return nil
    }

    private func stringsUrls(forPath path: String) -> [URL] {
        var urls: [URL] = []
        let pathUrl = URL(fileURLWithPath: path, isDirectory: true)
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        let enumerator = fileManager.enumerator(at: pathUrl, includingPropertiesForKeys: nil, options: options, errorHandler: {(url, error) -> Bool in
            return true
        })
        if let enumerator = enumerator {
            while let path = enumerator.nextObject() as? URL {
                if path.lastPathComponent == stringsFilename {
                    urls.append(path)
                }
            }
        }
        return urls
    }

    // Read file as String
    private func stringFromFile(_ filePath: URL) -> String? {
        guard let data = try? String(contentsOf: filePath) else {
            print("Could not load file \(filePath)")
            return nil
        }
        return data
    }

    // Split multiline String into an array of single line Strings
    private func splitStringByNewLines(_ data: String) -> [String] {
        var lines = [String]()
        data.enumerateLines { (line, _) in
            lines.append(line)
        }
        return lines
    }
}

// Get localization vars used in input file
extension Checker {
    private func getUsedStrings(from data: String) -> [String] {
        var usedStrings = [String]()
        let dataLines = splitStringByNewLines(data)
        for line in dataLines {
            guard let string = usedStringsGetQuotation(from: line as NSString) else { continue }
            usedStrings.append(string)
        }
        return usedStrings
    }

    private func usedStringsGetQuotation(from text: NSString) -> String? {
        let rangeForFirstQM = NSMakeRange(0, text.length)
        let firstQMRange = text.range(of: Checker.localizedMark, options: [], range: rangeForFirstQM, locale: nil)
        guard firstQMRange.location < Int.max else { return nil }
        let firstQMRangeEnd = firstQMRange.location + firstQMRange.length
        let rangeForSecondQM = NSMakeRange(firstQMRangeEnd, text.length - firstQMRangeEnd)
        let secondQMRange = text.range(of: Checker.quotationMark, options: [], range: rangeForSecondQM, locale: nil)
        guard secondQMRange.location < Int.max else { return nil }
        let quotation = text.substring(with: NSMakeRange(firstQMRangeEnd, secondQMRange.location - firstQMRangeEnd))
        return quotation
    }
}

// Get localizations from .strings files
extension Checker {
    private func getLocalizations(from urls: [URL]) -> [StringsLocalization] {
        var localizations = [StringsLocalization]()
        for url in urls {
            guard let data = stringFromFile(url) else { continue }
            let dataLines = splitStringByNewLines(data)
            let localizables = getLocalizables(from: dataLines)
            let stringsLocalization = StringsLocalization(filePath: url, strings: localizables)
            localizations.append(stringsLocalization)
        }
        return localizations
    }

    //TODO: Basic looking for vars, might need updating in the future.
    private func getLocalizables(from data: [String]) -> [String] {
        var parsedLocalizables = [String]()
        for line in data where !localizablesIsCommentLineOnly(line: line as NSString) {
            guard let variable = localizablesGetQuotation(from: line as NSString) else { continue }
            parsedLocalizables.append(variable)
        }
        return parsedLocalizables
    }

    private func localizablesGetQuotation(from text: NSString) -> String? {
        let rangeForFirstQM = NSMakeRange(0, text.length)
        let firstQMRange = text.range(of: Checker.quotationMark, options: [], range: rangeForFirstQM, locale: nil)
        guard firstQMRange.location < Int.max else { return nil }
        let firstQMRangeEnd = firstQMRange.location + firstQMRange.length
        let rangeForSecondQM = NSMakeRange(firstQMRangeEnd, text.length - firstQMRangeEnd)
        let secondQMRange = text.range(of: Checker.quotationMark, options: [], range: rangeForSecondQM, locale: nil)
        guard secondQMRange.location < Int.max else { return nil }
        let quotation = text.substring(with: NSMakeRange(firstQMRangeEnd, secondQMRange.location - firstQMRangeEnd))
        return quotation
    }

    private func localizablesIsCommentLineOnly(line: NSString) -> Bool {
        guard line.contains(Checker.commentMark) else { return false }
        let commentRange = line.range(of: Checker.commentMark)
        let quotationRange = line.range(of: Checker.quotationMark)
        return commentRange.location < quotationRange.location
    }
}

// Look for missing vars in .strings file
extension Checker {
    func lookForMissingStrings() {
        for (index, localization) in localizations.enumerated() {
            for usedStringVar in usedStringVars where !localization.strings.contains(usedStringVar) {
                localizations[index].missingStrings.append(usedStringVar)
            }
        }
    }
}

// Save missing vars to output file
extension Checker {
    private func saveOutput() {
        var outputString = ""
        for localization in localizations where !localization.missingStrings.isEmpty {
            let missingVars = localization.missingStrings.reduce("") { return $0+"\n"+$1 }
            let missingOutput = "File:\n\(localization.filePath.path)\n\nMissing vars:\(missingVars)\n=====\n\n"
            outputString.append(missingOutput)
        }
        let directoryUrl = URL(fileURLWithPath: configuration.outputFolder)
        try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        let outputFileUrl = directoryUrl.appendingPathComponent(configuration.outputFilename).appendingPathExtension(Configuration.outputExtension)
        if configuration.verboseFlag {
            print(outputString)
        }
        do {
            try outputString.write(to: outputFileUrl, atomically: true, encoding: .utf8)
            print("Output saved to: \(outputFileUrl)")
        } catch {
            print("Failed to save output to: \(outputFileUrl)")
        }
    }
}
