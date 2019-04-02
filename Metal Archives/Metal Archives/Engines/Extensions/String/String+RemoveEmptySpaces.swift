//
//  String+RemoveEmptySpaces.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension String {
    mutating func removeEmptySpaces() {
        //Work around: remove "\n\t\t"
        // at the beginning and the end of string
        var stringTemp = self
        while(true) {
            if stringTemp.count == 0 {
                break
            }
            
            if stringTemp[0] == "\n" || stringTemp[0] == "\t" || stringTemp[0] == " " {
                stringTemp.remove(at: stringTemp.startIndex)
            } else {
                self = stringTemp
                break
            }
        }
        
        while(true) {
            if stringTemp.count == 0 {
                break
            }
            
            if stringTemp[stringTemp.count-1] == "\n" || stringTemp[stringTemp.count-1] == "\t" || stringTemp[stringTemp.count-1] == " "{
                stringTemp.remove(at: stringTemp.index(before: stringTemp.endIndex))
            } else {
                self = stringTemp
                break
            }
        }
    }
}
