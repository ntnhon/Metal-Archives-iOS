//
//  ReleaseInCollection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import AttributedLib

fileprivate extension Array where Element == BandLite {
    /*
     Sample string:
     "<a href="https://www.metal-archives.com/bands/Dark_Angel/126">Dark Angel</a> / <a href="https://www.metal-archives.com/bands/Death/141">Death</a> / <a href="https://www.metal-archives.com/bands/Forbidden/374">Forbidden</a> / <a href="https://www.metal-archives.com/bands/Faith_or_Fear/977">Faith or Fear</a> / <a href="https://www.metal-archives.com/bands/Raven/1129">Raven</a>"
     */
    static func fromString(_ string: String) -> [BandLite]? {
        var bands: [BandLite] = []
        
        let aTags = string.replacingOccurrences(of: " / ", with: "🤘").split(separator: "🤘")
        aTags.forEach { (substring) in
            if let band = BandLite.init(from: String(substring)) {
                bands.append(band)
            }
        }
        
        return bands.count > 0 ? bands : nil
    }
}

final class ReleaseInCollection: ThumbnailableObject {
    let editId: String
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let type: String
    let version: String
    private(set) var note: String?
    
    lazy var bandsAttributedString: NSAttributedString = {
        let bandNames = bands.map({$0.name})
        return generateAttributedStringFromStrings(bandNames, as: .secondaryTitle, withSeparator: " / ")
    }()
    
    lazy var versionAndTypeAttributedString: NSAttributedString = {
        return version.at.attributed(with: bodyTextAttributes) + " \(type)".at.attributed(with: bodyTextAttributes)
    }()
    
    /*
     Sample array:
    "<a class="iconContainer ui-state-default ui-corner-all" href="https://www.metal-archives.com/collection/owner-list/releaseId/261742" title="See who owns / wants this album"><span class="ui-icon ui-icon-person">Owners</span></a>",
     "<a href="https://www.metal-archives.com/bands/Dark_Angel/126">Dark Angel</a> / <a href="https://www.metal-archives.com/bands/Death/141">Death</a> / <a href="https://www.metal-archives.com/bands/Forbidden/374">Forbidden</a> / <a href="https://www.metal-archives.com/bands/Faith_or_Fear/977">Faith or Fear</a> / <a href="https://www.metal-archives.com/bands/Raven/1129">Raven</a>",
     "<a href="https://www.metal-archives.com/albums/Dark_Angel_-_Death_-_Forbidden_-_Faith_or_Fear_-_Raven/Ultimate_Revenge_2/261742">Ultimate Revenge 2</a> (Split video)",
     "<span id='version_261742_261742'>1989, VHS, Combat Records (NTSC) <a class="iconContainer ui-state-default ui-corner-all" href="javascript:;" title="Edit" onclick="editVersion('261742_261742');"><span class="ui-icon ui-icon-pencil">Edit</span></a></span>",
     "<input type='text' name='notes[261742_261742]' id='note_261742_261742' value="this is a note" class='editable' maxlength='100' size='30' /> <input type='hidden' name='changes[261742_261742]' id='changes_261742_261742' />",
     "<input type='checkbox' class='1 editable' name='item[261742_261742]' id='item_261742_261742' value='1' onclick='toggleSelection("261742_261742")' />"
     */
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let urlSubstring = array[2].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive), let typeSubstring = array[2].subString(after: "</a>") else {
                return nil
        }
        
        guard let bands = Array<BandLite>.fromString(array[1]) else { return nil }
        
        guard let release = ReleaseExtraLite.init(from: array[2]) else { return nil }
        
        guard let versionSubstring = array[3].subString(after: "'>", before: "<a class", options: .caseInsensitive) else { return nil }
        
        guard let noteSubstring = array[4].subString(after: "value=\"", before: "\" class='editable'", options: .caseInsensitive) else { return nil}
        
        guard let editIdSubstring = array[5].subString(after: "toggleSelection(\"", before: "\")", options: .caseInsensitive) else { return nil }
        
        self.editId = String(editIdSubstring)
        self.bands = bands
        self.release = release
        self.type = String(typeSubstring)
        self.version = String(versionSubstring)
        
        let noteString = String(noteSubstring)
        if noteString != "" {
            self.note = noteString.htmlToString
        } else {
            self.note = nil
        }

        super.init(urlString: String(urlSubstring), imageType: .release)
    }
    
    func updateNote(_ note: String?) {
        self.note = note
    }
}

extension ReleaseInCollection: Pagable {
    static var rawRequestURLString =  "https://www.metal-archives.com/collection/ajax-view/id/376380/type/1/json/1/edit/1?sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&sSearch=&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&sSearch_4=&bRegex_4=false&bSearchable_4=true&sSearch_5=&bRegex_5=false&bSearchable_5=true&_=1586624185273"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [ReleaseInCollection]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [ReleaseInCollection] = []
        
        array.forEach { (releaseInCollectionDetails) in
            if let releaseInCollection = ReleaseInCollection(from: releaseInCollectionDetails) {
                list.append(releaseInCollection)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
