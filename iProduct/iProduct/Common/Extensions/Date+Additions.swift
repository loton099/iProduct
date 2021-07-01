//
//  Date+Additions.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import Foundation

extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? Date()
    }
    
    var currentTimeGreetingMessage: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 6 ..< 12 :
            return "morning".localized
        case 12 ..< 17 :
            return "afternoon".localized
        case 17 ..< 20 :
            return "evening".localized
        default:
            return "night".localized
        }
    }
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
