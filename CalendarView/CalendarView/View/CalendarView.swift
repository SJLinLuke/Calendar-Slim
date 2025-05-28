//
//  CalendarView.swift
//  CalendarView
//
//  Created by LukeLin on 2025/3/7.
//

import SwiftUI

public struct CalendarView: View {
    // MARK: Properties and Variables
    
    @StateObject private var viewModel: CalendarViewModel
    private let configuration: CalendarConfiguration
    private let onDateSelected: ((Date) -> Void)?
    private let onRangeSelected: ((Date, Date) -> Void)?
    private let onMultipleDatesSelected: (([Date]) -> Void)?
    
    // MARK: - init
    
    public init(
        configuration: CalendarConfiguration = CalendarConfiguration(),
        onDateSelected: ((Date) -> Void)? = nil,
        onRangeSelected: ((Date, Date) -> Void)? = nil,
        onMultipleDatesSelected: (([Date]) -> Void)? = nil
    ) {
        self.configuration = configuration
        self._viewModel = StateObject(wrappedValue: CalendarViewModel(configuration: configuration))
        self.onDateSelected = onDateSelected
        self.onRangeSelected = onRangeSelected
        self.onMultipleDatesSelected = onMultipleDatesSelected
    }
    
    // MARK: - View
    
    public var body: some View {
        VStack {
            if self.configuration.showMonthWithYear {
            Text(self.viewModel.currentYearMonth)
                .font(self.configuration.theme.headerFont)
                .foregroundColor(self.configuration.theme.headerTextColor)
                .padding(.top, 10)
            }
            
            WeekDaysView(
                weekdays: self.configuration.weekdaySymbols,
                theme: self.configuration.theme
            )
            
            TabView(selection: self.$viewModel.currentMonthIndex) {
                ForEach(Array(self.viewModel.availableMonth.enumerated()),
                        id: \.element.id) { index, yearMonth in
                    let dates = yearMonth.dates
                    LazyVGrid(columns: self.viewModel.column) {
                        ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                            DateView(
                                viewModel: self.viewModel,
                                date: date,
                                yearMonth: yearMonth,
                                theme: self.configuration.theme
                            )
                        }
                    }
                    .tag(index)
                }
            }
            .frame(height: self.viewModel.dynamicHeight)
            .animation(.easeInOut(duration: 0.5), value: self.viewModel.dynamicHeight)
            .onChange(of: self.viewModel.currentMonthIndex) { _, newIndex in
                self.viewModel.getMonthYearTitle(index: newIndex)
            }
            .onChange(of: self.viewModel.selectedFromDate) { _, _ in
                if let date = self.viewModel.selectedFromDate, self.viewModel.selectedToDate == nil {
                    self.onDateSelected?(date)
                }
            }
            .onChange(of: self.viewModel.selectedToDate) { _, _ in
                if let startDate = self.viewModel.selectedFromDate,
                   let endDate = self.viewModel.selectedToDate {
                    self.onRangeSelected?(startDate, endDate)
                }
            }
            .onChange(of: self.viewModel.selectedMultipleDates) { _, newDates in
                self.onMultipleDatesSelected?(newDates)
            }
            .onAppear {
                self.viewModel.onDateSelected = self.onDateSelected
                self.viewModel.onRangeSelected = self.onRangeSelected
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .overlay {
            RoundedRectangle(cornerRadius: self.configuration.theme.cornerRadius)
                .stroke(self.configuration.theme.calendarBorderColor,
                        lineWidth: self.configuration.theme.borderWidth)
        }
        .padding(.horizontal, 3)
        
    }
}

// MARK: - Preview

#Preview("CalendarView") {
    CalendarView()
}
