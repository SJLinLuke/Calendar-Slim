//
//  YearMonth.swift
//  CalendarView
//
//  Created by LukeLin on 2025/5/1.
//

import Foundation

struct YearMonth: Hashable, Identifiable {
    let id = UUID()
    let year: Int
    let month: Int
    let dates: [Date?]
    
    var displayYearMonthText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        // 拿當月的第一筆來判斷是什麼月份
        if let firstDayOfMonth = Calendar.current.date(from: DateComponents(year: self.year, month: self.month, day: 1)) {
            return dateFormatter.string(from: firstDayOfMonth)
        }
        return "N/A"
    }
    
    func formattedString(with formatter: DateFormatter) -> String {
        if let firstDayOfMonth = Calendar.current.date(from: DateComponents(year: self.year, month: self.month, day: 1)) {
            return formatter.string(from: firstDayOfMonth)
        }
        return "N/A"
    }
}
