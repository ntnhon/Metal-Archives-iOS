//
//  Artist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Artist {
    private(set) var urlString: String!
    private(set) var id: String!
    private(set) var bandMemberName: String!
    private(set) var realFullName: String!
    private(set) var age: String!
    private(set) var origin: String!
    private(set) var gender: String!
    private(set) var isDead: Bool = false
    private(set) var rip: String?
    private(set) var diedOf: String?
    private(set) var photoURLString: String?
    
    private(set) var biography: String?
    private(set) var trivia: String?
    
    private(set) var isBookmarked: Bool? = nil
    
    private(set) var  addedOnDate: Date?
    private(set) var  lastModifiedOnDate: Date?
    
    private(set) var activeBands: [RolesInBand]?
    private(set) var pastBands: [RolesInBand]?
    private(set) var live: [RolesInBand]?
    private(set) var guestSession: [RolesInBand]?
    private(set) var miscStaff: [RolesInBand]?
    
    private(set) var links: [RelatedLink]?
    
    deinit {
        print("Artist is deallocated")
    }
    
    init?(fromData data: Data, urlString: String) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        self.urlString = urlString
        self.id = urlString.components(separatedBy: "/").last
        
        // Firstly detect if artist is bookmarked or not
        for a in doc.css("a") {
            // When bookmarked
            // <a id="bookmark" class="iconContainer ui-state-active ui-corner-all writeAction"...
            // When not bookmarked
            // <a id="bookmark" class="iconContainer ui-state-default ui-corner-all writeAction"...
            if let id = a["id"], id == "bookmark", let classValue = a["class"] {
                self.isBookmarked = classValue.contains("active")
                continue
            }
        }
        
        for div in doc.css("div") {
            if (div["id"] == "member_info") {
                self.parseArtistMetaData(div_member_info: div)
            } else if (div["class"] == "member_img") {
                if let a = div.at_css("a") {
                    self.photoURLString = a["href"]
                }
            } else if (div["id"] == "artist_tab_active") {
                self.activeBands = self.parseRolesInBand(div: div)
            } else if (div["id"] == "artist_tab_past") {
                self.pastBands = self.parseRolesInBand(div: div)
            } else if (div["id"] == "artist_tab_live") {
                self.live = self.parseRolesInBand(div: div)
            } else if (div["id"] == "artist_tab_guest") {
                self.guestSession = self.parseRolesInBand(div: div)
            } else if (div["id"] == "artist_tab_misc") {
                self.miscStaff = self.parseRolesInBand(div: div)
            } else if (div["id"] == "auditTrail") {
                self.parseAddedOnAndLastModified(div: div)
            }
        }
    }
    
    private func parseArtistMetaData(div_member_info: XMLElement) {
        
        if let h1 = div_member_info.at_css("h1"), let bandMemberName = h1.text {
            self.bandMemberName = bandMemberName
        }
        
        for dl in div_member_info.css("dl") {
            if (dl["class"] == "float_left") {
                // Check is artist id dead by counting dd tag (info)
                var countDD = 0
                for _ in dl.css("dd") {
                    countDD = countDD + 1
                }
                
                if (countDD == 2) {
                    self.isDead = false
                }
                else if (countDD == 3 || countDD == 4) {
                    self.isDead = true
                }
                
                var i = 0
                for dd in dl.css("dd") {
                    if (i == 0) {
                        var temp = dd.text
                        temp = temp?.replacingOccurrences(of: "\n", with: "")
                        temp = temp?.replacingOccurrences(of: "\t", with: "")
                        self.realFullName = temp
                    }
                    else if (i == 1) {
                        self.age = dd.text
                    }
                    
                    if (isDead == true) {
                        if (i == 2) {
                            self.rip = dd.text
                        }
                        else if (i == 3) {
                            self.diedOf = dd.text
                        }
                    }
                    
                    i = i + 1
                }
            }
            else if (dl["class"] == "float_right") {
                
                var i = 0
                
                for dd in dl.css("dd") {
                    if (i == 0) {
                        self.origin = dd.text
                    }
                    else if (i == 1) {
                        gender = dd.text
                    }
                    
                    i = i + 1
                }
                
                return
            }
        }
    }
    
    private func parseRolesInBand(div: XMLElement) -> [RolesInBand]? {
        var rolesInBands = [RolesInBand]()
        
        for div_member_in_band in div.css("div") {
            
            if (div_member_in_band["class"] == "member_in_band") {
                if let rolesInBand = RolesInBand(div_member_in_band: div_member_in_band) {
                    rolesInBands.append(rolesInBand)
                }
            }
        }
        
        return rolesInBands
    }
    
    private func parseAddedOnAndLastModified(div: XMLElement) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var i = 0
        for td in div.css("td") {
            if (i == 2) {
                if let addedOnString = (td.text?.replacingOccurrences(of: "Added on: ", with: "")),
                    let addedOnDate =  dateFormatter.date(from: addedOnString) {
                    self.addedOnDate = addedOnDate
                } else {
                    self.addedOnDate = nil
                }
            }
            else if (i == 3) {
                if let lastModifiedOnString = (td.text?.replacingOccurrences(of: "Last modified on: ", with: "")),
                    let lastModifiedOnDate = dateFormatter.date(from: lastModifiedOnString) {
                    self.lastModifiedOnDate = lastModifiedOnDate
                } else {
                    self.lastModifiedOnDate = nil
                }
                
                break
            }
            
            i = i + 1
        }
    }
    
    func setBiography(biographyString: String?) {
        self.biography = biographyString
    }
    
    func setTrivia(triviaString: String?) {
        self.trivia = triviaString
    }
    
    func setLinks(links: [RelatedLink]?) {
        self.links = links
    }
    
    func setIsBookmarked(_ isBookmarked: Bool) {
        self.isBookmarked = isBookmarked
    }
}

extension Artist: Descriptive {
    var generalDescription: String {
        return "\(id ?? "") - \(bandMemberName ?? "") - \(urlString ?? "")"
    }
}
