//
//  String+RemoveHTMLTags.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

 // This extension is meant to make something like:

 /*
 
 1983-1984                               (as <a href="https://www.metal-archives.com/bands/Mantas/35328">Mantas</a>),
 1984-2001
 */

// To:

/*
1983-1984 (as Mantas), 1984-2001
 */

extension String {
    func removeHTMLTagsAndNoisySpaces() -> String {
        var newString = ""
        var isInATag = false
        
        for character in self {
            
            if character == "<" {
                isInATag = true
                continue
            }
            
            if character != ">" && isInATag {
                continue
            }
            
            if character == "\n" || character == "\t" {
                continue
            }
            
            if character == ">" {
                isInATag = false
                continue
            }
            
            if character == " " {
                if let lastCharacter = newString.last {
                    if lastCharacter == " " {
                        continue
                    } else if lastCharacter == "," {
                        // Allow space after comma
                        newString.append(character)
                        continue
                    }
                } else {
                    // Begin at the string, skip space
                    continue
                }
            }
            
            newString.append(character)
        }
        
        // Remove last space
        guard let lastCharacter = newString.last, lastCharacter == " " else {
            return newString
        }
        
        return String(newString.dropLast())
    }
}
