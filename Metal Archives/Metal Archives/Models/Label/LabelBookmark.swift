//
//  LabelBookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class LabelBookmark: ThumbnailableObject {
    let name: String
    let country: Country
    let lastModified: String
    let note: NSAttributedString?
    
    /*
     Sample array:
     "<a href="https://www.metal-archives.com/artists/Mort_Drucker/153781">Mort Drucker</a>",
     "United States",
     "",
     "4 hours ago",
     "<span id="comment_1387501">t&uacute;t ti</span>",
     "<a class="iconContainer ui-state-default ui-corner-all writeAction" href="javascript:;" id="editComment_1387501" onclick="editComment(1387501);" title="Edit note/comment"><span id="editCommentIcon_1387501" class="ui-icon ui-icon-pencil">Edit</span></a> <input type="checkbox" class="artist" name="bookmark[1387501]" id="bookmark_1387501" value="1" onclick="toggleSelection(1387501)" />"
     */
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let urlSubstring = array[0].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let nameSubstring = array[0].subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        guard let noteSubstring = array[4].subString(after: "\">", before: "</span>", options: .caseInsensitive) else { return nil}
        
        self.name = String(nameSubstring)
        self.country = Country(name: array[1])
        self.lastModified = array[3]
        
        let noteString = String(noteSubstring)
        if noteString != "" {
            self.note = ("📝 " + noteString).htmlToAttributedString(attributes: [.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont])
        } else {
            self.note = nil
        }

        super.init(urlString: String(urlSubstring), imageType: .artist)
    }
}

extension LabelBookmark: Pagable {
    static var rawRequestURLString =
    "https://www.metal-archives.com/bookmark/ajax-list/type/label?sEcho=3&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=<SORT_COLUMN>&sSortDir_0=<SORT_ORDER>&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false&_=1586605892036"
    
    static var displayLenght = 500
    
    static func parseListFrom(data: Data) -> (objects: [LabelBookmark]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [LabelBookmark] = []
        
        array.forEach { (labelBookmarkDetails) in
            if let labelBookmark = LabelBookmark(from: labelBookmarkDetails) {
                list.append(labelBookmark)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
