//
//  CalendarTheme.swift
//  CalendarView
//
//  Created by LukeLin on 2025/5/1.
//

import SwiftUI

/// Defines the visual theme for the calendar
public protocol CalendarTheme {
    // Text colors
    var dayTextColor: Color { get }
    var todayTextColor: Color { get }
    var otherMonthTextColor: Color { get }
    var weekdayTextColor: Color { get }
    var headerTextColor: Color { get }
    var selectedDayTextColor: Color { get }
    
    // Background colors
    var selectedDayBackgroundColor: Color { get }
    var rangeBackgroundColor: Color { get }
    var calendarBorderColor: Color { get }
    
    // Font settings
    var dayFont: Font { get }
    var selectedDayFont: Font { get }
    var weekdayFont: Font { get }
    var headerFont: Font { get }
    
    // Style settings
    var cornerRadius: CGFloat { get }
    var borderWidth: CGFloat { get }
    var shadowRadius: CGFloat { get }
}

// MARK: - Default Theme Implementation

/// Default calendar theme
public struct DefaultCalendarTheme: CalendarTheme {
    // Text colors
    public var dayTextColor: Color = .primary
    public var todayTextColor: Color = .blue
    public var otherMonthTextColor: Color = .secondary
    public var weekdayTextColor: Color = .primary
    public var headerTextColor: Color = .primary
    public var selectedDayTextColor: Color = .white
    
    // Background colors
    public var selectedDayBackgroundColor: Color = .blue
    public var rangeBackgroundColor: Color = Color.blue.opacity(0.3)
    public var calendarBorderColor: Color = Color.gray.opacity(0.3)
    
    // Font settings
    public var dayFont: Font = .system(size: 16)
    public var selectedDayFont: Font = .system(size: 18, weight: .semibold)
    public var weekdayFont: Font = .system(size: 14, weight: .medium)
    public var headerFont: Font = .system(size: 14, weight: .medium)
    
    // Style settings
    public var cornerRadius: CGFloat = 5
    public var borderWidth: CGFloat = 2
    public var shadowRadius: CGFloat = 8
    
    /// Initialization
    public init() {}
    
    /// Custom initialization method
    public init(
        dayTextColor: Color = .primary,
        todayTextColor: Color = .blue,
        otherMonthTextColor: Color = .gray,
        weekdayTextColor: Color = .primary,
        headerTextColor: Color = .primary,
        selectedDayTextColor: Color = .white,
        selectedDayBackgroundColor: Color = .blue,
        rangeBackgroundColor: Color = Color.blue.opacity(0.3),
        calendarBorderColor: Color = Color.gray.opacity(0.3),
        dayFont: Font = .system(size: 16),
        selectedDayFont: Font = .system(size: 18, weight: .semibold),
        weekdayFont: Font = .system(size: 14, weight: .medium),
        headerFont: Font = .system(size: 14, weight: .medium),
        cornerRadius: CGFloat = 5,
        borderWidth: CGFloat = 2,
        shadowRadius: CGFloat = 8,
    ) {
        self.dayTextColor = dayTextColor
        self.todayTextColor = todayTextColor
        self.otherMonthTextColor = otherMonthTextColor
        self.weekdayTextColor = weekdayTextColor
        self.headerTextColor = headerTextColor
        self.selectedDayTextColor = selectedDayTextColor
        self.selectedDayBackgroundColor = selectedDayBackgroundColor
        self.rangeBackgroundColor = rangeBackgroundColor
        self.calendarBorderColor = calendarBorderColor
        self.dayFont = dayFont
        self.selectedDayFont = selectedDayFont
        self.weekdayFont = weekdayFont
        self.headerFont = headerFont
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
    }
}
