//
//  ApplicationUtils.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/07/2021.
//

import UIKit

enum ApplicationUtils {
    static func share(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
    }
}
