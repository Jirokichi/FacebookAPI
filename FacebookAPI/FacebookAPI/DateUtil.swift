//
//  DateUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/23.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

/// NSDateを加工して欲しい値を取得するためのユーティリティークラス
class DateUtil{
    
    /*******************************************************/
    // - MARK: 何度も利用する変数
    /*******************************************************/
    private static let dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        return formatter
    }()
    private static let calendar:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    
    /*******************************************************/
    // - MARK: プリミティブな関数
    /*******************************************************/
    /// NSDateComponents([.Year, .Month, .Day, .Weekday])を取得
    static func getNSDateComponets(date:NSDate) -> NSDateComponents{
        return DateUtil.calendar.components([.Year, .Month, .Day, .Weekday], fromDate: date)
    }
    
    /// フォーマットの日付文字列を取得
    static func getDateString_YYYYMM(date:NSDate, format:String = "yyyy/MM") -> String{
        DateUtil.dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(date)
    }
    
    /// 引数の文字列がフォーマットの通りならNSDateを取得
    static func getNSDate(str:String, format:String = "yyyy/MM") -> NSDate?{
        DateUtil.dateFormatter.dateFormat = format
        return DateUtil.dateFormatter.dateFromString(str)
    }
    
    /// 特定「日」後の日付を取得
    /// - parameter date: 基準日
    /// - parameter day: day日後
    static func getDateAfterSpecificDays(date:NSDate, day:Int) -> NSDate{
        return NSDate(timeInterval: Double(day)*24*60*60, sinceDate:date)
    }
    
    /// 特定「月」後の日付(xxxx年xx月１日)を取得
    /// - parameter date: 基準日
    /// - parameter month: month月後
    static func getDateAfterSpecificMonth(date:NSDate, month:Int) -> NSDate{
        if month == 0{
            return date
        }
        
        let dataComps = DateUtil.calendar.components([.Year, .Month, .Day], fromDate: date)
        
        var changedYear = dataComps.year
        var changedMonth = dataComps.month
        
        changedMonth = changedMonth + month
        while changedMonth < 1 || changedMonth > 12{
            if changedMonth < 1{
                changedMonth = 12 + changedMonth
                changedYear = changedYear - 1
            }
            else if changedMonth > 12{
                changedMonth = changedMonth - 12
                changedYear = changedYear + 1
            }
        }
        
        DateUtil.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateResult = (DateUtil.dateFormatter.dateFromString("\(changedYear)/\((changedMonth))/01 09:00:00"))!
        return dateResult
    }
    
    /// NSDateComponents([.Year, .Month, .Day, .Weekday])の取得
    static func getNSDateComponents(date:NSDate) -> NSDateComponents{
        let dayComponent = DateUtil.calendar.components([.Year, .Month, .Day, .Weekday], fromDate: date)
        return dayComponent
    }
    
    /// 引数の月の初日のNSDateComponent(Year, Month, Day, Weekday)の取得
    static func getFirstNSDateComponents(date:NSDate) -> NSDateComponents{
        let thisMonthFirstDay = DateUtil.getFirstNSDate(date)
        let dayComponent = DateUtil.calendar.components([.Year, .Month, .Day, .Weekday], fromDate: thisMonthFirstDay)
        
        return dayComponent
    }
    
    
    /// 引数の月の最終日のNSDate(Year, Month, Day, Weekday)の取得
    static func getLastNSDate(date:NSDate) -> NSDate{
        let nextMonthFirstDay = DateUtil.getNextMonthFirstDay(date)
        let finalDayInThisMonth = DateUtil.getDateAfterSpecificDays(nextMonthFirstDay, day:-1)
        return finalDayInThisMonth
    }
    
    /// 引数の月の最終日のNSDateComponent(Year, Month, Day, Weekday)の取得
    static func getLastDay(date:NSDate) -> NSDateComponents{
        let finalDayInThisMonth = DateUtil.getLastNSDate(date)
        let dayComponent = DateUtil.calendar.components([.Year, .Month, .Day, .Weekday], fromDate: finalDayInThisMonth)
        return dayComponent
    }
    
    /// 引数の月の最終日のNSDateComponent(Year, Month, Day, Weekday)の取得
    static func getLastDayOfLastMonth(date:NSDate) -> NSDateComponents{
        let thisMonthFirstDay = DateUtil.getFirstNSDate(date)
        let lastDayInLastMonth = NSDate(timeInterval: -1*24*60*60, sinceDate:thisMonthFirstDay)
        let dayComponent = DateUtil.calendar.components([.Year, .Month, .Day, .Weekday], fromDate: lastDayInLastMonth)
        
        return dayComponent
    }
    
    static func getFirstNSDate(date:NSDate) -> NSDate{
        
        let dataComps = DateUtil.calendar.components([.Year, .Month, .Day], fromDate: date)
        
        let year = dataComps.year
        let thisMonth = dataComps.month
        
        DateUtil.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let firstDate = (dateFormatter.dateFromString("\(year)/\((thisMonth))/01 09:00:00"))!
        
        return firstDate
    }
    
    static func getNextMonthFirstDay(date:NSDate) -> NSDate{
        // 翌月
        let nextMonthDate = DateUtil.getDateAfterSpecificMonth(date, month: 1)
        // 翌月のコンポーネント
        let nextMonthComps = DateUtil.calendar.components([.Year, .Month, .Day], fromDate: nextMonthDate)
        // 月の初日
        DateUtil.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let nextMonthFirstDay = (dateFormatter.dateFromString("\(nextMonthComps.year)/\((nextMonthComps.month))/01 09:00:00"))!
        return nextMonthFirstDay
    }
    
    static func getAllDatesInTheMonth(date:NSDate) -> [NSDate]{
        let firstDay = DateUtil.getFirstNSDate(date)
        let lastDayInThisMonth = DateUtil.getLastDay(date)
        var dates:[NSDate] = []
        for i in 1...lastDayInThisMonth.day{
            dates.append(DateUtil.getDateAfterSpecificDays(firstDay, day:(i - 1)))
        }
        return dates
    }
    
    /// 「カレンダーで利用するための日付情報(月の一日から最終日)の１次元配列(42)」と「特定日が何番目かの情報」を取得するためのメソッド。
    static func getMonthDateForGrid42(basedDate:NSDate, targetDate:NSDate) -> (grid:[NSDate], dayIndex:Int?){
        
        // 引数のdateのインデックス番号
        var dayIndex:Int?
        
        let dateComp = DateUtil.getNSDateComponents(targetDate)
        let firstDay = DateUtil.getFirstNSDate(basedDate)
        var dates:[NSDate] = []
        let weekDayOfADay = DateUtil.getWeekDay(DateUtil.getNSDateComponets(firstDay))
        for i in 0...41{
            let day = i - (weekDayOfADay.rawValue - 1)
            let lDate = DateUtil.getDateAfterSpecificDays(firstDay, day:(day - 1))
            let lDateComp = DateUtil.getNSDateComponents(lDate)
            if dateComp.year == lDateComp.year && dateComp.month == lDateComp.month && dateComp.day == lDateComp.day{
                dayIndex = i
            }
            
            dates.append(lDate)
        }
        return (dates, dayIndex)
    }
    
    static func getWeekDay(date:NSDateComponents) -> WeekDay{
        return WeekDay(rawValue: date.weekday-1) ?? .Unknown
    }
    
    /// １日の始まりと終わりの時間を取得
    static func getAllDay(date:NSDate) -> (startDate:NSDate, endDate:NSDate){
        
        
        let dataComps = DateUtil.calendar.components([.Year, .Month, .Day], fromDate: date)
        
        let year = dataComps.year
        let month = dataComps.month
        let day = dataComps.day
        
        DateUtil.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let startDate = (DateUtil.dateFormatter.dateFromString("\(year)/\((month))/\(day) 00:00:00"))!
        let endDate = (DateUtil.dateFormatter.dateFromString("\(year)/\((month))/\(day) 23:59:59"))!
        
        return (startDate, endDate)
        
    }
}

enum WeekDay:Int{
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    case Unknown
    
    func getDisplayedValues() -> String{
        let DisplayedValues = ["日", "月", "火", "水", "木", "金", "土", "?"]
        return DisplayedValues[self.rawValue]
    }
    
    
}