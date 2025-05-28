//
//  CalendarViewModel.swift
//  CalendarView
//
//  Created by LukeLin on 2025/3/7.
//

import UIKit
import SwiftUI

@MainActor final class CalendarViewModel: ObservableObject {
    // MARK: Properties and Variables
    
    private(set) var column: [GridItem]
    private var calendar = Calendar.current
    private let configuration: CalendarConfiguration
    private let screenWidth: CGFloat

    var itemHeight: CGFloat {
        return self.screenWidth / 7
    }
    
    var itemWidth: CGFloat {
        return self.itemHeight + 5
    }
    
    var dynamicHeight: CGFloat {
        let currentMonth = self.availableMonth[self.currentMonthIndex]
        return CGFloat(self.rowCount(month: currentMonth.month, year: currentMonth.year)) * self.itemHeight + 80
    }
    
    /// Current year and month display string
    @Published var currentYearMonth: String = ""
    /// Index to track current month in TabView
    @Published var currentMonthIndex: Int = 1
    /// Available months to display
    @Published var availableMonth: [YearMonth] = []
    /// Selected start date
    @Published var selectedFromDate: Date?
    /// Selected end date
    @Published var selectedToDate: Date?
    /// Selected dates for multiple select mode
    @Published var selectedMultipleDates: [Date] = []
    /// Call back
    var onDateSelected: ((Date) -> Void)?
    var onRangeSelected: ((Date, Date) -> Void)?
    var onMultipleDatesSelected: (([Date]) -> Void)?

    // MARK: - Life Cycle
    
    init(configuration: CalendarConfiguration = CalendarConfiguration()) {
        self.configuration = configuration
        self.screenWidth = UIScreen.main.bounds.width * 0.9
        self.column = [GridItem(.adaptive(minimum: self.screenWidth / 7,
                                          maximum: self.screenWidth / 7), spacing: 5)]
        self.setupViewModel()
    }
}

// MARK: Public Method

extension CalendarViewModel {

    func getDateDay(date: Date) -> String {
        return String(self.calendar.component(.day, from: date))
    }
    
    func getMonthYearTitle(index: Int) {
        if index >= 0 && index < self.availableMonth.count {
            self.currentYearMonth = self.availableMonth[index].formattedString(with: configuration.dateFormatter)
        }
    }
    
    func isSelected(_ date: Date) -> Bool {
        return self.selectedFromDate == date || self.selectedToDate == date
    }
    
    func isMultipleSelected(_ date: Date) -> Bool {
        return self.selectedMultipleDates.contains(date)
    }
    
    func isCurrentMonth(_ date: Date, yearMonth: YearMonth) -> Bool {
        let components = self.calendar.dateComponents([.year, .month], from: date)
        return components.year == yearMonth.year && components.month == yearMonth.month
    }
    
    func isInRange(_ date: Date?) -> Bool {
        guard let date = date,
              let fromDate = self.selectedFromDate,
              let toDate = self.selectedToDate else { return false }
        return date > fromDate && date < toDate
    }
    
    func isStartDate(_ date: Date) -> Bool {
        guard let startDate = self.selectedFromDate else { return false }
        return self.calendar.isDate(date, inSameDayAs: startDate)
    }
    
    func isEndDate(_ date: Date) -> Bool {
        guard let endDate = self.selectedToDate else { return false }
        return self.calendar.isDate(date, inSameDayAs: endDate)
    }
    
    func isMiddleDate(_ date: Date) -> Bool {
        return self.isInRange(date) && !self.isStartDate(date) && !self.isEndDate(date)
    }
    
    func isToday(_ date: Date) -> Bool {
        return self.calendar.isDateInToday(date)
    }
    
    func handleSelectedDate(_ selectedDate: Date, yearMonth: YearMonth) {
        guard self.calendar.component(.month, from: selectedDate) == yearMonth.month else {
            return
        }
        
        // If selection mode is none, return immediately
        if case .none = self.configuration.selectionMode {
            return
        }
        
        // Ensure selected date is in current month (if not showing adjacent months)
        if !self.configuration.showAdjacentMonths {
            guard self.isCurrentMonth(selectedDate, yearMonth: yearMonth) else { return }
        }
        
        // Ensure the selected date is not a duplicate
        guard selectedDate != self.selectedFromDate else { return }
        guard selectedDate != self.selectedToDate else { return }
        
        switch self.configuration.selectionMode {
        case .single:
            self.handleSingleSelection(selectedDate)
        case .range:
            self.handleRangeSelection(selectedDate)
        case .multiple:
            self.handleMultipleSelection(selectedDate)
        case .none:
            break
        }
    }
}

// MARK: Private Method

extension CalendarViewModel {
    
    private func numberOfWeeksInMonth(month: Int, year: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return 0
        }

        let numberOfDaysInMonth = range.count
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstOfMonth) // Sunday = 1

        let totalSlots = numberOfDaysInMonth + (weekdayOfFirstDay - 1)

        return Int(ceil(Double(totalSlots) / 7.0))
    }

    private func rowCount(month: Int, year: Int) -> Int {
        if self.configuration.showAdjacentMonths {
            return 6
        }
        else {
            return numberOfWeeksInMonth(month: month, year: year)
        }
    }
    
    private func handleSingleSelection(_ selectedDate: Date) {
        self.selectedFromDate = selectedDate
        self.selectedToDate = nil
        if let date = self.selectedFromDate {
            self.onDateSelected?(date)
        }
    }
    
    private func handleRangeSelection(_ selectedDate: Date) {
        // If start date is already selected
        if let fromDate = self.selectedFromDate {
            // If end date is also selected
            if let _ = self.selectedToDate {
                // Start over with a new start date
                self.selectedFromDate = selectedDate
                self.selectedToDate = nil
            }
            // If only start date is selected
            else {
                // If selected date is earlier than start date, replace start date
                if selectedDate < fromDate {
                    self.selectedFromDate = selectedDate
                }
                // Normal scenario - set end date
                else {
                    self.selectedToDate = selectedDate
                    // Notify range selection completion
                    if let start = self.selectedFromDate, let end = self.selectedToDate {
                        self.onRangeSelected?(start, end)
                    }
                }
            }
        }
        // If no start date is selected yet, set it
        else {
            self.selectedFromDate = selectedDate
        }
    }
    
    func handleMultipleSelection(_ selectedDate: Date) {
        if let index = self.selectedMultipleDates.firstIndex(of: selectedDate) {
            self.selectedMultipleDates.remove(at: index)
        } else {
            self.selectedMultipleDates.append(selectedDate)
        }
        self.onMultipleDatesSelected?(self.selectedMultipleDates)
    }
    
    private func setupViewModel() {
        // Set timezone
        self.calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        // Generate available months
        self.availableMonth = self.generateYearMonthArray(
            from: self.configuration.dateRange.startDate,
            to: self.configuration.dateRange.endDate
        )
        
        // Set initial month (default to the month containing today)
        let today = Date()
        let todayComponents = self.calendar.dateComponents([.year, .month], from: today)
        
        // Try to find today's month in available months
        if let todayIndex = self.availableMonth.firstIndex(where: { yearMonth in
            return yearMonth.year == todayComponents.year && yearMonth.month == todayComponents.month
        }) {
            self.currentMonthIndex = todayIndex
        }
        else {
            // If not found, use the middle month
            self.currentMonthIndex = self.availableMonth.count / 2
        }
        
        self.getMonthYearTitle(index: self.currentMonthIndex)
    }
    
    private func generateYearMonthArray(from startDate: Date, to endDate: Date) -> [YearMonth] {
        var components = calendar.dateComponents([.year, .month], from: startDate)
        let startYear = components.year!
        let startMonth = components.month!
        
        components = calendar.dateComponents([.year, .month], from: endDate)
        let endYear = components.year!
        let endMonth = components.month!
        
        var result: [YearMonth] = []

        components.year = startYear
        components.month = startMonth
        components.day = 1

        while (components.year! < endYear) || (components.year! == endYear && components.month! <= endMonth) {
            if let date = calendar.date(from: components) {
                let yearMonth = YearMonth(
                    year: components.year!,
                    month: components.month!,
                    dates: self.perpareDates(for: date)
                )
                result.append(yearMonth)
            }

            components.month! += 1
            if components.month! > 12 {
                components.month! = 1
                components.year! += 1
            }
        }
        return result
    }
    
    private func perpareDates(for monthDate: Date) -> [Date?] {
        let components = self.calendar.dateComponents([.year, .month], from: monthDate)
        let firstDayOfMonth = self.calendar.date(from: components)!
        
        // Current month's day range
        let range = self.calendar.range(of: .day, in: .month, for: monthDate)!
        let year = self.calendar.component(.year, from: monthDate)
        let month = self.calendar.component(.month, from: monthDate)
        
        // Calculate weekday of first day of month
        let firstWeekday = self.calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        var dates: [Date?] = []
        
        // Fill in dates from previous month
        if self.configuration.showAdjacentMonths,
           let previousMonthDate = self.calendar.date(byAdding: .month, value: -1, to: monthDate),
           let previousMonthRange = self.calendar.range(of: .day, in: .month, for: previousMonthDate) {
            
            let previousMonthDays = Array(previousMonthRange)
            let previousMonthYear = self.calendar.component(.year, from: previousMonthDate)
            let previousMonthMonth = self.calendar.component(.month, from: previousMonthDate)
            
            // Take last few days from previous month to fill in
            let lastDays = previousMonthDays.suffix(firstWeekday)
            for day in lastDays {
                if let date = self.calendar.date(from: DateComponents(year: previousMonthYear, month: previousMonthMonth, day: day)) {
                    dates.append(date)
                }
            }
        }
        else if !self.configuration.showAdjacentMonths {
            // If not showing adjacent months, fill with placeholder dates
            for _ in 0..<firstWeekday {
                dates.append(nil)
            }
        }
        
        // Fill in current month dates
        for day in range {
            if let date = self.calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                dates.append(date)
            }
        }
        
        // Calculate how many next month dates needed
        let totalCells = 42 // Ensure calendar has 6 rows (7x6 = 42)
        let remainingCells = totalCells - dates.count
        
        // Fill in dates from next month
        if remainingCells > 0 {
            if self.configuration.showAdjacentMonths,
               let nextMonthDate = self.calendar.date(byAdding: .month, value: 1, to: monthDate) {
                let nextMonthYear = self.calendar.component(.year, from: nextMonthDate)
                let nextMonthMonth = self.calendar.component(.month, from: nextMonthDate)
                
                for day in 1...remainingCells {
                    if let date = self.calendar.date(from: DateComponents(year: nextMonthYear, month: nextMonthMonth, day: day)) {
                        dates.append(date)
                    }
                }
            }
            else if !self.configuration.showAdjacentMonths {
                // If not showing adjacent months, fill with placeholder dates
                for _ in 0..<remainingCells {
                    dates.append(nil)
                }
            }
        }
        
        return dates
    }
}
