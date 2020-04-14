//
//  UserProfile.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class UserProfile {
    private(set) var id: String!
    private(set) var username: String!
    private(set) var rank: String!
    private(set) var points: String!
    private(set) var fullName: String?
    private(set) var gender: String!
    private(set) var age: String!
    private(set) var country: Country?
    private(set) var homepage: String?
    private(set) var favoriteGenres: String?
    private(set) var comments: String?
    
    init?(from data: Data, username: String) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        for div in doc.css("div") {
            if let id = div["id"], id == "userInfo" {
                for a in div.css("a") {
                    if let title = a["title"], title == "Submitted bands", let href = a["href"], let idSubstring = href.split(separator: "/").last {
                        self.id = String(idSubstring)
                        break
                    }
                }
                break
            }
        }
        
        for dl in doc.css("dl") {
            if let `class` = dl["class"], `class` == "float_left" {
                var i = -1
                for dt in dl.css("dt") {
                    i += 1
                    guard let dtText = dt.text, var ddText = dl.css("dd")[i].text else { return nil }
                    
                    ddText = ddText.replacingOccurrences(of: "\n", with: "")
                    
                    let specialSpace = " "
                    ddText = ddText.replacingOccurrences(of: specialSpace, with: "")
                    
                    switch dtText {
                    case "Rank:": rank = ddText
                    case "Points:": points = ddText
                    case "Full name:": fullName = ddText
                    case "Gender:": gender = ddText
                    case "Age:": age = ddText
                    case "Country:": country = Country(name: ddText)
                    case "Homepage:": homepage = ddText
                    case "Favourite metal genre(s):": favoriteGenres = ddText
                    default: break
                    }
                }
                
                if let p = dl.css("p").first, let pText = p.text {
                    comments = pText
                }

                self.username = username
                return
            }
        }
        
        if let _ = id, let _ = rank, let _ = points, let _ = gender, let _ = age {
            return
        }
        
        return nil
    }
}

/*
 <dl class="float_left">
     <dt>Rank:</dt>
     <dd>Metal newbie&nbsp;</dd>
     <dt>Points:</dt>
     <dd>11&nbsp;</dd>
     <dt>Full name:</dt>
     <dd>Thanh-Nhon Nguyen&nbsp;</dd>
     <dt>Gender:</dt>
     <dd>Male&nbsp;</dd>
     <dt>Age:</dt>
     <dd>
         N/A &nbsp;
     </dd>
     <dt>Country:</dt>
     <dd>Vietnam&nbsp;</dd>
     <dt>Homepage:</dt>
     <dd style="width: 600px;"><a href="https://www.facebook.com/MetalArchivesIOSApp" target="_blank">https://www.facebook.com/MetalArchivesIOSApp</a>&nbsp;</dd>
     <dt>Favourite metal genre(s):</dt>
     <dd>death, thrash metal&nbsp;</dd>
     <dt>Comments:</dt>
     <dd> &nbsp;</dd>
     <p>
         Author of Metal Archives iOS
     </p>
 </dl>
 */
