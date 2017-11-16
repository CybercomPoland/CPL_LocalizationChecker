# CPL_LocalizationChecker
Basic tool to quickly check for missing translations in .strings files.
The app looks for the specified LocalizedStrings.swift file, extracts all localized string instances it can find and checks all specified
Localizable.strings files to see if they have those strings included. Missing strings are saved to an output.txt file.

# Usage
Available input parameters:
-inputFolder [path] -> input folder path, defaults to main Bundle path.
-inputFile [name] -> input .swift filename, defaults to LocalizedStrings.
-stringsFile [name] -> filename for the .strings files that should be checked, defaults to Localizable.
-outputFolder [path] -> output folder path, defaults to main Bundle path.
-outputFile [name] -> output .txt filename, defaults to output.
-verbose -> Verbose flag, when used the app will output more information to the console.
