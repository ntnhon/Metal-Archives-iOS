//
//  EKEvent.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import EventKit

extension EKEvent {
    static func createEventFrom(dateString: String, title: String?, notes: String?, url: URL?) -> EKEvent? {
        let now = Date()
        guard let date = Date(from: dateString), date >= now else {
            return nil
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.notes = notes
        event.url = url
        event.startDate = date.addingTimeInterval(10*60*60)
        event.endDate = date.addingTimeInterval(12*60*60)
        
        return event
    }
}
