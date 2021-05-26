//
//  ReleaseOtherVersion.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

struct ReleaseOtherVersion {
    let urlString: String
    let date: String
    let labelName: String
    let catalogId: String
    let additionalDetail: String // Ex: "Unofficial"
    let format: String
    let description: String
}

extension ReleaseOtherVersion {
    final class Builder {
        var urlString: String?
        var date: String?
        var labelName: String?
        var catalogId: String?
        var additionalDetail: String?
        var format: String?
        var description: String?

        func build() -> ReleaseOtherVersion? {
            guard let urlString = urlString else {
                Logger.log("[Building ReleaseOtherVersion] urlString can not be nil.")
                return nil
            }

            guard let date = date else {
                Logger.log("[Building ReleaseOtherVersion] date can not be nil.")
                return nil
            }

            guard let labelName = labelName else {
                Logger.log("[Building ReleaseOtherVersion] labelName can not be nil.")
                return nil
            }

            guard let catalogId = catalogId else {
                Logger.log("[Building ReleaseOtherVersion] catalogId can not be nil.")
                return nil
            }

            guard let additionalDetail = additionalDetail else {
                Logger.log("[Building ReleaseOtherVersion] additionalDetail can not be nil.")
                return nil
            }

            guard let format = format else {
                Logger.log("[Building ReleaseOtherVersion] format can not be nil.")
                return nil
            }

            guard let description = description else {
                Logger.log("[Building ReleaseOtherVersion] description can not be nil.")
                return nil
            }

            return ReleaseOtherVersion(urlString: urlString,
                                       date: date,
                                       labelName: labelName,
                                       catalogId: catalogId,
                                       additionalDetail: additionalDetail,
                                       format: format,
                                       description: description)
        }
    }
}
