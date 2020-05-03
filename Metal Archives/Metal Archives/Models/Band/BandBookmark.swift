//
//  BandBookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandBookmark: ThumbnailableObject, Pagable {
    let editId: String
    let name: String
    let country: Country
    let genre: String
    let lastModified: String
    private(set) var note: String?
    
    static var rawRequestURLString = "https://www.metal-archives.com/bookmark/ajax-list/type/band?sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=<SORT_COLUMN>&sSortDir_0=<SORT_ORDER>&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false"
    
    static var displayLength = 500
    
    /*
     Sample array:
     "<a href=\"https://www.metal-archives.com/bands/%28%27M%27%29_Inc./3540373050\">('M') Inc.</a>",
     "United States",
     "Death Metal",
     "~4 months ago",
     "<span id=\"comment_1237683\">Y&acirc;u ti đen</span>",
     "<a class=\"iconContainer ui-state-default ui-corner-all writeAction\" href=\"javascript:;\" id=\"editComment_1387108\" onclick=\"editComment(1387108);\" title=\"Edit note/comment\"><span id=\"editCommentIcon_1387108\" class=\"ui-icon ui-icon-pencil\">Edit</span></a> <input type=\"checkbox\" class=\"band\" name=\"bookmark[1387108]\" id=\"bookmark_1387108\" value=\"1\" onclick=\"toggleSelection(1387108)\" />"
     */
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let urlSubstring = array[0].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let nameSubstring = array[0].subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        guard let noteSubstring = array[4].subString(after: "\">", before: "</span>", options: .caseInsensitive) else { return nil}
        
        guard let editIdSubstring = array[5].subString(after: "onclick=\"editComment(", before: ");\" title=\"Edit", options: .caseInsensitive) else { return nil }
        
        self.editId = String(editIdSubstring)
        self.name = String(nameSubstring)
        self.country = Country(name: array[1])
        self.genre = array[2]
        self.lastModified = array[3]
        
        let noteString = String(noteSubstring)
        if noteString != "" {
            self.note = noteString.htmlToString
        } else {
            self.note = nil
        }
        
        super.init(urlString: String(urlSubstring), imageType: .bandLogo)
    }
    
    func updateNote(_ note: String?) {
        self.note = note
    }
}
