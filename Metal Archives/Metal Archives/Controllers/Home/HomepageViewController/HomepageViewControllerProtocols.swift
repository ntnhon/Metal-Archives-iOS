//
//  HomepageViewControllerProtocols.swft
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

// Have to use long names cause swift doesn't allow nested protocols
protocol HomepageViewControllerLatestAdditionOrUpdateDelegate {
    func didFinishFetchingBandAdditionOrUpdate(_ bands: [BandAdditionOrUpdate])
    func didFinishFetchingLabelAdditionOrUpdate(_ labels: [LabelAdditionOrUpdate])
    func didFinishFetchingArtistAdditionOrUpdate(_ artists: [ArtistAdditionOrUpdate])
    func didFailFetching()
}
