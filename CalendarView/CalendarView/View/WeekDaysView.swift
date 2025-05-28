//
//  WeekDaysView.swift
//  CalendarView
//
//  Created by LukeLin on 2025/5/1.
//

import SwiftUI

struct WeekDaysView: View {
    // MARK: Properties and Variables
    
    /// Weekday labels
    private let weekdays: [String]
    /// Style theme
    private let theme: CalendarTheme
    /// Grid items
    private let gridItems: [GridItem]
    
    init(
        weekdays: [String]? = nil,
        theme: CalendarTheme = DefaultCalendarTheme(),
        screenWidth: CGFloat = UIScreen.main.bounds.width * 0.9
    ) {
        self.weekdays = weekdays ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        self.theme = theme
        self.gridItems = [GridItem(.adaptive(minimum: screenWidth / 7,
                                             maximum: screenWidth / 7), spacing: 5)]
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems) {
            ForEach(self.weekdays, id: \.self) { day in
                Text(day)
                    .font(self.theme.weekdayFont)
                    .foregroundColor(self.theme.weekdayTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
    }
}
