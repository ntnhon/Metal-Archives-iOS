//
//  ModificationRecord.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ModificationRecord: Pagable {
    enum RecordType {
        case band, artist, label, release
    }
    
    let name: String
    let urlString: String
    let type: RecordType
    let note: String
    let dateString: String
    
    lazy var thumbnailableObject: ThumbnailableObject? = {
        switch type {
        case .band: return ThumbnailableObject(urlString: urlString, imageType: .bandLogo)
        case .artist: return ThumbnailableObject(urlString: urlString, imageType: .artist)
        case .label: return ThumbnailableObject(urlString: urlString, imageType: .label)
        case .release: return ThumbnailableObject(urlString: urlString, imageType: .release)
        }
    }()
    
    static var rawRequestURLString =    "https://www.metal-archives.com/history/ajax-view/id/<USER_ID>/type/user?sEcho=1&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&iSortCol_0=0&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=false&bSortable_3=false&bSortable_4=true"
    
    static var displayLength = 500
    
    /*
     Sample array:
     "2020-02-28 21:42:43",
     "<a href="https://www.metal-archives.com/albums/Orphans_of_Doom/II/829371">Orphans of Doom - II</a>",
     "Modified album data: <a href="https://www.metal-archives.com/albums/Orphans_of_Doom/II/829371">II</a>",
     "<span class='historyItem' data-historyId='14733007'><a id="14733007" class="details iconContainer ui-state-default ui-corner-all" href="javascript:;" title="Expand"><span id="icon_14733007" class="ui-icon ui-icon-plus"> </span></a></span>",
     "0"
     */
    init?(from array: [String]) {
        guard array.count == 5 else { return nil }
        
        guard let urlSubstring = array[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive), let nameSubstring = array[1].subString(after: "\">", before: "</a>", options: .caseInsensitive) else { return nil }
        
        self.name = String(nameSubstring)
        self.urlString = String(urlSubstring)
        self.dateString = array[0]
        
        let itemString = array[1]
        if itemString.contains("/bands") {
            self.type = .band
        } else if itemString.contains("/artists") {
            self.type = .artist
        } else if itemString.contains("/labels") {
            self.type = .label
        } else {
            self.type = .release
        }
        
        self.note = array[2].htmlToString ?? ""
    }
}

extension ModificationRecord: Actionable {
    var actionableElements: [ActionableElement] {
        switch type {
        case .band: return [ActionableElement.band(name: name, urlString: urlString)]
        case .artist: return [ActionableElement.artist(name: name, urlString: urlString)]
        case .label: return [ActionableElement.label(name: name, urlString: urlString)]
        case .release: return [ActionableElement.release(name: name, urlString: urlString)]
        }
    }
}
