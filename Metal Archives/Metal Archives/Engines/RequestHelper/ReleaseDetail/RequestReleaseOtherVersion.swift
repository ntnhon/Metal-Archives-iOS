//
//  RequestReleaseOtherVersion.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.ReleaseDetail {
    typealias FetchOtherVersionOnSuccess = (_ otherVersions: [ReleaseOtherVersion]) -> Void
    typealias FetchOtherVersionOnError = (Error) -> Void
    
    static func fetchOtherVersion(releaseID: String, onSuccess: @escaping FetchOtherVersionOnSuccess, onError: @escaping FetchOtherVersionOnError) {
        let requestURLString = "http://www.metal-archives.com/release/ajax-versions/current/<RELEASE_ID>/parent/<RELEASE_ID>".replacingOccurrences(of: "<RELEASE_ID>", with: releaseID)
        
        let requestURL = URL(string: requestURLString)!
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let otherVersions = RequestHelper.ReleaseDetail.parseOtherVersions(data: data)
                    onSuccess(otherVersions)
                } else {
                    let error = MAParsingError.badStructure(objectType: "Other version")
                    onError(error)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
    
    private static func parseOtherVersions(data: Data) -> [ReleaseOtherVersion] {
        var otherVersions = [ReleaseOtherVersion]()
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return otherVersions
        }
        
        // Check if user is logged in, because in this case the html structure is different
        // there is 1 more column at the beginning (for editing)
        let isLoggedIn = htmlString.contains("title=\"Edit\"")
        
        let releaseDateColumn = isLoggedIn ? 1 : 0
        let labelColumn = isLoggedIn ? 2 : 1
        let catalogIdColumn = isLoggedIn ? 3 : 2
        let formatColumn = isLoggedIn ? 4 : 3
        let descriptionColumn = isLoggedIn ? 5 : 4
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            var j = 0
            for tr in doc.css("tr") {
                if (j == 0) {
                    j += 1
                    continue
                }
                else {
                    var i = 0

                    var urlString: String?
                    var dateString: String?
                    var description: String?
                    var additionalDetail: String?
                    var labelName: String?
                    var catalogID: String?
                    var format: String?
                    
                    for td in tr.css("td") {
                        
                        if (i == releaseDateColumn) {
                            if let a = td.at_css("a"){
                                urlString = a["href"]
                                dateString = a.text
                            }
                            
                            if let dateString = dateString {
                                var additionalDetailString = td.text
                                additionalDetailString = additionalDetailString?.replacingOccurrences(of: "\n", with: "")
                                additionalDetailString = additionalDetailString?.replacingOccurrences(of: "\t", with: "")
                                
                                additionalDetailString = additionalDetailString?.replacingOccurrences(of: dateString, with: "")
                                
                                additionalDetail = additionalDetailString
                            } else {
                                additionalDetail = ""
                            }
                        }
                        else if (i == labelColumn) {
                            labelName = td.text
                        }
                        else if (i == catalogIdColumn) {
                            catalogID = td.text
                        }
                        else if (i == formatColumn) {
                            format = td.text
                        }
                        else if (i == descriptionColumn) {
                            description = td.text
                        }
                        
                        i += 1
                    }
                    
                    if let urlString = urlString, let dateString = dateString, let additionalDetail = additionalDetail, let labelName = labelName, let catalogID = catalogID, let format = format, let description = description {
                        if let version = ReleaseOtherVersion(urlString: urlString, dateString: dateString, additionalDetail: additionalDetail, labelName: labelName, catalogID: catalogID, format: format, description: description) {
                            otherVersions.append(version)
                        }
                    }
                }
            }
        }
        
        //If there is only one element => this version
        //remove "this version" in this case
        if otherVersions.count == 1 {
            otherVersions.removeAll()
        }
        
        return otherVersions
    }
}
