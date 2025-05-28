//
//  CalendarConfiguration.swift
//  CalendarView
//
//  Created by LukeLin on 2025/5/1.
//

import Foundation

public struct CalendarConfiguration {
    /// Selection mode
    public enum SelectionMode {
        case none       // Not selectable
        case single     // Single selection
        case multiple   // Multiple selection (to be implemented)
        case range      // Range selection
    }
    
    /// Date range of the calendar
    public var dateRange: (startDate: Date, endDate: Date)
    /// Selection mode
    public var selectionMode: SelectionMode
    /// Whether to display dates from adjacent months
    public var showAdjacentMonths: Bool
    /// Whether to display header
    public var showMonthWithYear: Bool
    /// Calendar theme
    public var theme: CalendarTheme
    /// Date format for header (default "MMM yyyy")
    public var dateFormatter: DateFormatter
    /// Custom weekday symbols
    public var weekdaySymbols: [String]?
    
    /// Initializer
    public init(
        dateRange: (startDate: Date, endDate: Date)? = nil,
        selectionMode: SelectionMode = .single,
        showAdjacentMonths: Bool = false,
        showMonthWithYear: Bool = false,
        theme: CalendarTheme = DefaultCalendarTheme(),
        dateFormatter: DateFormatter? = nil,
        weekdaySymbols: [String]? = nil,
    ) {
        self.dateRange = dateRange ?? CalendarConfiguration.defaultDateRange()
        self.selectionMode = selectionMode
        self.showAdjacentMonths = showAdjacentMonths
        self.showMonthWithYear = showMonthWithYear
        self.theme = theme
        self.dateFormatter = dateFormatter ?? CalendarConfiguration.defaultDateFormatter()
        self.weekdaySymbols = weekdaySymbols
    }
    
    /// Default date range (one year before to one year after today)
    private static func defaultDateRange() -> (startDate: Date, endDate: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today),
              let oneYearLater = calendar.date(byAdding: .year, value: 1, to: today) else {
            return (today, today)
        }
        
        return (oneYearAgo, oneYearLater)
    }
    
    /// Default date formatter
    private static func defaultDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
}
