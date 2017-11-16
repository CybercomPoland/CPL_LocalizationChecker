//
//  main.swift
//  LocalizationChecker
//
//  Created by Adrian Ziemecki on 09/11/2017.
//  Copyright © 2017 Cybercom. All rights reserved.
//

import Foundation

var arguments = CommandLine.arguments
arguments.removeFirst()
let configuration = Configuration(arguments: arguments)
let checker = Checker(configuration: configuration)
checker.check()
