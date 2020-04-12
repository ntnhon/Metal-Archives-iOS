//
//  Enums.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//


import UIKit
import EventKit

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let baseNavigationBarViewHeightWithoutTopInset: CGFloat = 50
let segmentedNavigationBarViewHeightWithoutTopInset: CGFloat = 70

let countryDictionary: NSDictionary = {
    let path = Bundle.main.path(forResource: "MA_Countries", ofType: "plist")!
    return NSDictionary(contentsOfFile: path)!
}()

let sortedCountryList: [Country] = {
    countryDictionary.allKeys.compactMap({ countryISO in
        if countryISO is String {
            return Country(iso: countryISO as! String)
        }
        
        return nil
    }).sorted(by: {
        $0.name < $1.name
    })
}()

let customURLQueryAllowedCharacterSet: CharacterSet = {
    let characterSet = NSMutableCharacterSet()
    characterSet.formUnion(with: CharacterSet.urlQueryAllowed)
    characterSet.addCharacters(in: "[]")
    return characterSet as CharacterSet
}()

let defaultDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter
}()

let dateOnlyFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()

let MAImageBaseURLString = "https://www.metal-archives.com/images/"

let endOfListMessage = "That's all! 🤘"
let errorLoadingMessage = "Unknown error occured."
let errorBookmarkMessage = "Bookmark error. Please try again later."
let blockedMessage = "Still loading..."
let noResultMessage = "No result found."

let minimumYearOfFormation = 1960
let thisYear = Calendar.current.component(.year, from: Date())

let eventStore = EKEventStore()

//MARK - monthList
let monthList: [MonthInYear] = {
    var monthList: [MonthInYear] = []
    
    let shortDateFormatter = DateFormatter()
    shortDateFormatter.dateFormat = "MMM yyyy"
    shortDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let longDateFormatter = DateFormatter()
    longDateFormatter.dateFormat = "yyyy - MMMM"
    longDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let requestParameterDateFormatter = DateFormatter()
    requestParameterDateFormatter.dateFormat = "yyyy-MM"
    requestParameterDateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    var startDate: Date! = shortDateFormatter.date(from: "Jul 2002")
    let endDate = Date()
    
    let calendar = Calendar.current
    
    while(true) {
        let shortDisplayString = shortDateFormatter.string(from: startDate)
        let longDisplayString = longDateFormatter.string(from: startDate)
        let requestParameterString = requestParameterDateFormatter.string(from: startDate)
        let month = MonthInYear(date: startDate, shortDisplayString: shortDisplayString, longDisplayString: longDisplayString, requestParameterString: requestParameterString)
        monthList.append(month)
        startDate = calendar.date(byAdding: .month, value: 1, to: startDate)
        
        if startDate > endDate {
            break
        }
    }
    
    monthList.reverse()
    
    return monthList
}()
