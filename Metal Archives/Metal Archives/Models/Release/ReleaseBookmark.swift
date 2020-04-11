//
//  ReleaseBookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseBookmark: ThumbnailableObject {
    let editId: String
    let bandName: String
    let title: String
    let country: Country
    let genre: String
    let lastModified: String
    let note: NSAttributedString?
    
    /*
     Sample array:
     "S.D.I.<br/><a href="https://www.metal-archives.com/albums/S.D.I./80s_Metal_Band/814947">80s Metal Band</a>",
     "Germany",
     "Speed/Thrash Metal",
     "~2 months ago",
     "<span id="comment_1388764"></span>",
     "<a class="iconContainer ui-state-default ui-corner-all writeAction" href="javascript:;" id="editComment_1388764" onclick="editComment(1388764);" title="Edit note/comment"><span id="editCommentIcon_1388764" class="ui-icon ui-icon-pencil">Edit</span></a> <input type="checkbox" class="release" name="bookmark[1388764]" id="bookmark_1388764" value="1" onclick="toggleSelection(1388764)" />"
     */
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let bandNameSubstring = array[0].replacingOccurrences(of: "<br/>", with: "🤘").split(separator: "🤘").first else { return nil }
        
        guard let urlSubstring = array[0].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let titleSubstring = array[0].subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        guard let noteSubstring = array[4].subString(after: "\">", before: "</span>", options: .caseInsensitive) else { return nil}
        
        guard let editIdSubstring = array[5].subString(after: "onclick=\"editComment(", before: ");\" title=\"Edit", options: .caseInsensitive) else { return nil }
        
        self.editId = String(editIdSubstring)
        self.bandName = String(bandNameSubstring)
        self.title = String(titleSubstring)
        self.country = Country(name: array[1])
        self.genre = array[2]
        self.lastModified = array[3]
        
        let noteString = String(noteSubstring)
        if noteString != "" {
            self.note = ("📝 " + noteString).htmlToAttributedString(attributes: [.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont])
        } else {
            self.note = nil
        }

        super.init(urlString: String(urlSubstring), imageType: .release)
    }
}

extension ReleaseBookmark: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/bookmark/ajax-list/type/release?sEcho=3&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=<SORT_COLUMN>&sSortDir_0=<SORT_ORDER>&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false&_=1586550306203"
    
    static var displayLenght = 500
    
    static func parseListFrom(data: Data) -> (objects: [ReleaseBookmark]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [ReleaseBookmark] = []
        
        array.forEach { (releaseBookmarkDetails) in
            if let releaseBookmark = ReleaseBookmark(from: releaseBookmarkDetails) {
                list.append(releaseBookmark)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
