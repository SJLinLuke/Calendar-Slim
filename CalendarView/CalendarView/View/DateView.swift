//
//  DateCell.swift
//  CalendarView
//
//  Created by LukeLin on 2025/5/1.
//

import SwiftUI

struct DateView: View {
    // MARK: Properties and Variables
    
    @ObservedObject var viewModel: CalendarViewModel
    let date: Date?
    let yearMonth: YearMonth
    let theme: CalendarTheme
    
    init(
        viewModel: CalendarViewModel,
        date: Date?,
        yearMonth: YearMonth,
        theme: CalendarTheme = DefaultCalendarTheme()
    ) {
        self.viewModel = viewModel
        self.date = date
        self.yearMonth = yearMonth
        self.theme = theme
    }
    
    var body: some View {
        if let date = self.date {
            let isStart = self.viewModel.isStartDate(date)
            let isEnd = self.viewModel.isEndDate(date)
            let isInRange = self.viewModel.isInRange(date)
            let isMultipleSelected = self.viewModel.isMultipleSelected(date)
            let isMiddle = isInRange && !isStart && !isEnd
            let itemWidth = self.viewModel.itemWidth
            let itemHeight = self.viewModel.itemHeight
            let isCurrentMonth = self.viewModel.isCurrentMonth(date, yearMonth: self.yearMonth)
            let isToday = self.viewModel.isToday(date)
            
            Text(self.viewModel.getDateDay(date: date))
                .frame(width: itemWidth, height: itemHeight)
                .font((isStart || isEnd || isMultipleSelected) ? self.theme.selectedDayFont : self.theme.dayFont)
                .foregroundColor(
                    self.getForegroundColor(
                        isStart: isStart,
                        isEnd: isEnd,
                        isMultipleSelected: isMultipleSelected,
                        isCurrentMonth: isCurrentMonth,
                        isToday: isToday
                    )
                )
                .background(
                    ZStack {
                        // First handle the range background (this should be at the bottom layer)
                        if isMiddle || (isStart && self.viewModel.selectedToDate != nil) || (isEnd && self.viewModel.selectedFromDate != nil) {
                            if isStart {
                                Rectangle()
                                    .fill(self.theme.rangeBackgroundColor)
                                    .frame(width: itemWidth / 2, height: itemHeight)
                                    .offset(x: itemWidth / 4, y: 0) // Offset to the right to show only right half
                            }
                            else if isEnd {
                                Rectangle()
                                    .fill(self.theme.rangeBackgroundColor)
                                    .frame(width: itemWidth / 2, height: itemHeight)
                                    .offset(x: -itemWidth / 4, y: 0) // Offset to the left to show only left half
                            }
                            else if isMiddle {
                                Rectangle()
                                    .fill(self.theme.rangeBackgroundColor)
                                    .frame(width: itemWidth, height: itemHeight)
                            }
                        }
                        
                        // Then handle the date circles (this should be at the top layer)
                        if isMultipleSelected || isStart || isEnd {
                            Circle()
                                .fill(self.theme.selectedDayBackgroundColor)
                                .frame(width: itemWidth, height: itemHeight)
                        }
                    }
                )
                .shadow(color: (isStart || isEnd || isMultipleSelected) ? Color.gray.opacity(0.5) : .clear,
                        radius: self.theme.shadowRadius)
                .onTapGesture {
                    if self.viewModel.selectedToDate != nil && self.viewModel.selectedFromDate != nil {
                        self.viewModel.handleSelectedDate(date, yearMonth: self.yearMonth)
                    }
                    else {
                        withAnimation {
                            self.viewModel.handleSelectedDate(date, yearMonth: self.yearMonth)
                        }
                    }
                }
        }
        else {
            Text("")
        }
    }
    
    private func getForegroundColor(isStart: Bool,
                                    isEnd: Bool,
                                    isMultipleSelected: Bool,
                                    isCurrentMonth: Bool,
                                    isToday: Bool) -> Color {
        if isStart || isEnd || isMultipleSelected {
            return self.theme.selectedDayTextColor
        }
        else if !isCurrentMonth {
            return self.theme.otherMonthTextColor
        }
        else if isToday {
            return self.theme.todayTextColor
        }
        else {
            return self.theme.dayTextColor
        }
    }
}
