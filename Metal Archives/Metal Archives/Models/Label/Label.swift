//
//  Label.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Label {
    private(set) var id: String!
    private(set) var urlString: String!
    private(set) var logoURLString: String?
    private(set) var name: String!
    private(set) var address: String!
    private(set) var country: Country?
    private(set) var phoneNumber: String!
    private(set) var status: LabelStatus!
    private(set) var specialisedIn: String!
    private(set) var foundingDate: String!
    private(set) var parentLabel: LabelLite?
    private(set) var subLabels: [LabelLite]?
    private(set) var onlineShopping: String!
    
    private(set) var isLastKnown = false
    
    private(set) var website: RelatedLink?
    
    private(set) var additionalNotes: String?
    
    private(set) var currentRosterPagableManager: PagableManager<BandCurrentRoster>!
    private(set) var pastRosterPagableManager: PagableManager<BandPastRoster>!
    private(set) var releasesPagableManager: PagableManager<ReleaseInLabel>!
    private(set) var links: [RelatedLink]?
    
    private(set) var  addedOnDate: Date?
    private(set) var  lastModifiedOnDate: Date?
    
    init?(fromData data: Data, urlString: String) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        self.urlString = urlString
        self.id = urlString.components(separatedBy: "/").last
        self.currentRosterPagableManager = PagableManager<BandCurrentRoster>(options: ["<LABEL_ID>": self.id])
        self.pastRosterPagableManager = PagableManager<BandPastRoster>(options: ["<LABEL_ID>": self.id])
        self.releasesPagableManager = PagableManager<ReleaseInLabel>(options: ["<LABEL_ID>": self.id])
        
        for div in doc.css("div") {
            if div["class"] == "label_img" {
                if let a = div.at_css("a"), let logoURLString = a["href"] {
                    self.logoURLString = logoURLString
                }
            }
            else if div["id"] == "label_info" {
                if let h1 = div.at_css("h1")?.text {
                    self.name = h1
                }
                
                let dls = div.css("dl")
                if let float_left = dls.first {
                    
                    let dts = float_left.css("dt")
                    let dds = float_left.css("dd")
                    
                    for i in 0..<dts.count {
                        if dts[i].text == "Address:" {
                            if let address = dds[i].text {
                                self.address = address
                            }
                        } else if dts[i].text == "Country:" {
                            if let a = dds[i].at_css("a"),
                                let countryName = a.text,
                                let country = Country(name: countryName) {
                                self.country = country
                            }
                        } else if dts[i].text == "Phone number:" {
                            if let phoneNumber = dds[i].text {
                                self.phoneNumber = phoneNumber
                            }
                        }
                    }
                } //End of if let float_left

                if dls.count > 1 {
                    let float_right = dls[1]
                    let dts = float_right.css("dt")
                    let dds = float_right.css("dd")
                    
                    for i in 0..<dts.count {
                        if dts[i].text == "Status:" {
                            if let statusString = dds[i].text {
                                self.status = LabelStatus(statusString: statusString)
                                if self.status == .unknown || status == .closed {
                                    self.isLastKnown = true
                                }
                            }
                        } else if dts[i].text == "Specialised in:" {
                            if let specialisedIn = dds[i].text {
                                self.specialisedIn = specialisedIn
                            }
                        } else if dts[i].text == "Founding date :" {
                            self.foundingDate = dds[i].text
                        } else if dts[i].text == "Parent label:" {
                            if let a = dds[i].at_css("a"),
                                let labelURLString = a["href"],
                                let labelName = a.text {
                                self.parentLabel = LabelLite(urlString: labelURLString, name: labelName)
                            }
                        } else if dts[i].text == "Sub-labels:" {
                            self.subLabels = []
                            dds[i].css("a").forEach { (a) in
                                
                                if let labelURLString = a["href"],
                                    let labelName = a.text,
                                    let eachSubLabel = LabelLite(urlString: labelURLString, name: labelName) {
                                    
                                    self.subLabels?.append(eachSubLabel)
                                }
                                
                            }
                            
                            if self.subLabels!.count == 0 {
                                self.subLabels = nil
                            }
                        } else if dts[i].text == "Online shopping:" {
                            if let onlineShopping = dds[i].text {
                                self.onlineShopping = onlineShopping
                            }
                        }
                    }
                } //End of if dls.count > 1
            } //End of if (div["id"] == "label_info")
            
            else if div["id"] == "label_content" {
                if let p = div.at_css("p") {
                    //<p id="label_contact">
                    if let a = p.css("a").first,
                        let title = a.text,
                        let urlString = a["href"] {
                        self.website = RelatedLink(title: title, urlString: urlString)
                    }
                }
            }
            
            else if div["id"] == "label_tabs_notes" {
                self.additionalNotes = div.text?.removeHTMLTagsAndNoisySpaces()
            } else if div["id"] == "auditTrail" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let table = div.at_css("table")
                table?.css("td").forEach({ (td) in
                    if let tdText = td.text {
                        if tdText.contains("Added on: ") {
                            let addedOnDateString = tdText.replacingOccurrences(of: "Added on: ", with: "")
                            self.addedOnDate = dateFormatter.date(from: addedOnDateString)
                        } else if tdText.contains("Last modified on: ") {
                            let lastModifiedOnDateString = tdText.replacingOccurrences(of: "Last modified on: ", with: "")
                            self.lastModifiedOnDate = dateFormatter.date(from: lastModifiedOnDateString)
                        }
                    }
                })
            }
        } //End of for div in doc.css("div")
    }
    
    func setLinks(_ links: [RelatedLink]?) {
        self.links = links
    }
}
