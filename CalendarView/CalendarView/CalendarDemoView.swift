//
//  CalendarDemoView.swift
//  CalendarView
//
//  Created by LukeLin on 2025/5/3.
//

import SwiftUI

struct CalendarDemoView: View {
    // MARK: - Configuration Properties
    @State private var selectionMode: CalendarConfiguration.SelectionMode = .single
    @State private var showAdjacentMonths: Bool = false
    @State private var showMonthWithYear: Bool = true
    
    // MARK: - Theme Properties
    @State private var dayTextColor: Color = .primary
    @State private var todayTextColor: Color = .blue
    @State private var otherMonthTextColor: Color = .gray
    @State private var weekdayTextColor: Color = .primary
    @State private var headerTextColor: Color = .primary
    @State private var selectedDayTextColor: Color = .white
    
    @State private var selectedDayBackgroundColor: Color = .blue
    @State private var rangeBackgroundColor: Color = Color.blue.opacity(0.3)
    @State private var calendarBorderColor: Color = Color.gray.opacity(0.3)
    
    @State private var cornerRadius: Double = 5
    @State private var borderWidth: Double = 2
    @State private var shadowRadius: Double = 8
    
    // MARK: - Date Range Properties
    @State private var startDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    
    // MARK: - Selection Callback
    @State private var selectedDateText: String = "N/A"
    
    // MARK: - Computed property for configuration
    private var configuration: CalendarConfiguration {
        let theme = CustomCalendarTheme(
            dayTextColor: dayTextColor,
            todayTextColor: todayTextColor,
            otherMonthTextColor: otherMonthTextColor,
            weekdayTextColor: weekdayTextColor,
            headerTextColor: headerTextColor,
            selectedDayTextColor: selectedDayTextColor,
            selectedDayBackgroundColor: selectedDayBackgroundColor,
            rangeBackgroundColor: rangeBackgroundColor,
            calendarBorderColor: calendarBorderColor,
            cornerRadius: CGFloat(cornerRadius),
            borderWidth: CGFloat(borderWidth),
            shadowRadius: CGFloat(shadowRadius)
        )
        
        return CalendarConfiguration(
            dateRange: (startDate: startDate, endDate: endDate),
            selectionMode: selectionMode,
            showAdjacentMonths: showAdjacentMonths,
            showMonthWithYear: showMonthWithYear,
            theme: theme
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Calendar Preview
                Text("Calendar Preview")
                    .font(.headline)
                    .padding(.top)
                
                CalendarView(
                    configuration: configuration,
                    onDateSelected: { date in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        selectedDateText = formatter.string(from: date)
                    },
                    onRangeSelected: { fromDate, toDate in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        selectedDateText = "\(formatter.string(from: fromDate)) 至 \(formatter.string(from: toDate))"
                    },
                    onMultipleDatesSelected: { dates in
                        selectedDateText = dates.map {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            return formatter.string(from: $0)
                        }.joined(separator: ", ")
                    }
                )
                .id("\(self.selectionMode)-\(self.showAdjacentMonths)-\(self.showMonthWithYear)")
                .padding(1)
                
                // MARK: - Selected Date Display
                Text("Selected Dates: \(self.selectedDateText)")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                // MARK: - Configuration Controls
                GroupBox(label: Text("Configuration").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Selection Mode
                        Picker("Selection Mode", selection: $selectionMode) {
                            Text("None").tag(CalendarConfiguration.SelectionMode.none)
                            Text("Single").tag(CalendarConfiguration.SelectionMode.single)
                            Text("Multiple").tag(CalendarConfiguration.SelectionMode.multiple)
                            Text("Range").tag(CalendarConfiguration.SelectionMode.range)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                                                
                        // Display Options
                        Toggle("Show Adjacent Months", isOn: $showAdjacentMonths)
                        Toggle("Show Month With Year", isOn: $showMonthWithYear)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                // MARK: - Theme Controls
                GroupBox(label: Text("Theme Configuration").font(.headline)) {
                    
                    LazyVStack(alignment: .leading, spacing: 12) {
                        DisclosureGroup("Text Color") {
                            VStack(alignment: .leading, spacing: 10) {
                                ColorPicker("Date Text Color", selection: $dayTextColor)
                                ColorPicker("Today Date Text Color", selection: $todayTextColor)
                                ColorPicker("Other Month Date Text Color", selection: $otherMonthTextColor)
                                ColorPicker("Weekday Text Color", selection: $weekdayTextColor)
                                ColorPicker("Header Text Color", selection: $headerTextColor)
                                ColorPicker("Selected Date Text Color", selection: $selectedDayTextColor)
                            }
                            .padding(.vertical)
                        }
                        
                        // Background Color Section
                        DisclosureGroup("Background Color") {
                            VStack(alignment: .leading, spacing: 10) {
                                ColorPicker("Selected date background", selection: $selectedDayBackgroundColor)
                                ColorPicker("Selected range background", selection: $rangeBackgroundColor)
                                ColorPicker("Calendar Border Color", selection: $calendarBorderColor)
                            }
                            .padding(.vertical)
                        }
                        
                        // Style Section
                        DisclosureGroup("Style") {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("CornerRadius: \(Int(self.cornerRadius))")
                                Slider(value: $cornerRadius, in: 0...30, step: 1)
                                    .padding(.bottom, 5)
                                
                                Text("BorderWidth: \(Int(self.borderWidth))")
                                Slider(value: $borderWidth, in: 0...5, step: 1)
                                    .padding(.bottom, 5)
                                
                                Text("ShadowRadius: \(Int(self.shadowRadius))")
                                Slider(value: $shadowRadius, in: 0...15, step: 1)
                            }
                            .padding(.vertical)
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                // MARK: - Date Range Controls
                GroupBox(label: Text("Date Range").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Calendar Demo")
    }
    
    // MARK: - Helper Properties
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "Date(\"\(formatter.string(from: date))\")"
    }
}

// MARK: - Custom Theme Implementation

struct CustomCalendarTheme: CalendarTheme {
    // Text colors
    var dayTextColor: Color
    var todayTextColor: Color
    var otherMonthTextColor: Color
    var weekdayTextColor: Color
    var headerTextColor: Color
    var selectedDayTextColor: Color
    
    // Background colors
    var selectedDayBackgroundColor: Color
    var rangeBackgroundColor: Color
    var calendarBorderColor: Color
    
    // Font settings (使用默認值)
    var dayFont: Font = .system(size: 16)
    var selectedDayFont: Font = .system(size: 18, weight: .semibold)
    var weekdayFont: Font = .system(size: 14, weight: .medium)
    var headerFont: Font = .system(size: 16, weight: .bold)
    
    // Style settings
    var cornerRadius: CGFloat
    var borderWidth: CGFloat
    var shadowRadius: CGFloat
    
    init(
        dayTextColor: Color = .primary,
        todayTextColor: Color = .blue,
        otherMonthTextColor: Color = .gray,
        weekdayTextColor: Color = .primary,
        headerTextColor: Color = .primary,
        selectedDayTextColor: Color = .white,
        selectedDayBackgroundColor: Color = .blue,
        rangeBackgroundColor: Color = Color.blue.opacity(0.3),
        calendarBorderColor: Color = Color.gray.opacity(0.3),
        cornerRadius: CGFloat = 5,
        borderWidth: CGFloat = 2,
        shadowRadius: CGFloat = 8
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
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
    }
}

// MARK: - Preview

struct CalendarDemoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CalendarDemoView()
        }
    }
}
