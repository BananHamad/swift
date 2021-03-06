// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// RUN: %target-run-simple-swift
// REQUIRES: executable_test
// REQUIRES: objc_interop

import Foundation
import CoreFoundation

#if FOUNDATION_XCTEST
import XCTest
class TestDateSuper : XCTestCase { }
#else
import StdlibUnittest
class TestDateSuper { }
#endif

class TestDate : TestDateSuper {

    func testDateComparison() {
        let d1 = Date()
        let d2 = d1 + 1
        
        expectTrue(d2 > d1)
        expectTrue(d1 < d2)
        
        let d3 = Date(timeIntervalSince1970: 12345)
        let d4 = Date(timeIntervalSince1970: 12345)
        
        expectTrue(d3 == d4)
        expectTrue(d3 <= d4)
        expectTrue(d4 >= d3)
    }
    
    func testDateMutation() {
        let d0 = Date()
        var d1 = Date()
        d1 = d1 + 1
        let d2 = Date(timeIntervalSinceNow: 10)
        
        expectTrue(d2 > d1)
        expectTrue(d1 != d0)
        
        let d3 = d1
        d1 += 10
        expectTrue(d1 > d3)
    }
    
    func testDateHash() {
        let d0 = NSDate()
        let d1 = Date(timeIntervalSinceReferenceDate: d0.timeIntervalSinceReferenceDate)
        expectEqual(d0.hashValue, d1.hashValue)
    }

    func testCast() {
        let d0 = NSDate()
        let d1 = d0 as Date
        expectEqual(d0.timeIntervalSinceReferenceDate, d1.timeIntervalSinceReferenceDate)
    }

    func testDistantPast() {
        let distantPast = Date.distantPast
        let currentDate = Date()
        expectTrue(distantPast < currentDate)
        expectTrue(currentDate > distantPast)
        expectTrue(distantPast.timeIntervalSince(currentDate) < 3600.0*24*365*100) /* ~1 century in seconds */
    }

    func testDistantFuture() {
        let distantFuture = Date.distantFuture
        let currentDate = Date()
        expectTrue(currentDate < distantFuture)
        expectTrue(distantFuture > currentDate)
        expectTrue(distantFuture.timeIntervalSince(currentDate) > 3600.0*24*365*100) /* ~1 century in seconds */
    }

    func dateWithString(_ str: String) -> Date {
        let formatter = DateFormatter()
        // Note: Calendar(identifier:) is OSX 10.9+ and iOS 8.0+ whereas the CF version has always been available
        formatter.calendar = CFCalendarCreateWithIdentifier(kCFAllocatorSystemDefault, .gregorianCalendar)! as Calendar
        formatter.locale = Locale(localeIdentifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter.date(from: str)! as Date
    }

    func testEquality() {
        let date = dateWithString("2010-05-17 14:49:47 -0700")
        let sameDate = dateWithString("2010-05-17 14:49:47 -0700")
        expectEqual(date, sameDate)
        expectEqual(sameDate, date)

        let differentDate = dateWithString("2010-05-17 14:49:46 -0700")
        expectNotEqual(date, differentDate)
        expectNotEqual(differentDate, date)

        let sameDateByTimeZone = dateWithString("2010-05-17 13:49:47 -0800")
        expectEqual(date, sameDateByTimeZone)
        expectEqual(sameDateByTimeZone, date)

        let differentDateByTimeZone = dateWithString("2010-05-17 14:49:47 -0800")
        expectNotEqual(date, differentDateByTimeZone)
        expectNotEqual(differentDateByTimeZone, date)
    }

    func testTimeIntervalSinceDate() {
        let referenceDate = dateWithString("1900-01-01 00:00:00 +0000")
        let sameDate = dateWithString("1900-01-01 00:00:00 +0000")
        let laterDate = dateWithString("2010-05-17 14:49:47 -0700")
        let earlierDate = dateWithString("1810-05-17 14:49:47 -0700")

        let laterSeconds = laterDate.timeIntervalSince(referenceDate)
        expectEqual(laterSeconds, 3483121787.0)

        let earlierSeconds = earlierDate.timeIntervalSince(referenceDate)
        expectEqual(earlierSeconds, -2828311813.0)

        let sameSeconds = sameDate.timeIntervalSince(referenceDate)
        expectEqual(sameSeconds, 0.0)
    }
    
    func testDateComponents() {
        // Make sure the optional init stuff works
        let dc = DateComponents()
        
        expectEmpty(dc.year)
        
        let dc2 = DateComponents(year: 1999)
        
        expectEmpty(dc2.day)
        expectEqual(1999, dc2.year)
    }
}

#if !FOUNDATION_XCTEST
var DateTests = TestSuite("TestDate")
DateTests.test("testDateComparison") { TestDate().testDateComparison() }
DateTests.test("testDateMutation") { TestDate().testDateMutation() }
DateTests.test("testDateHash") { TestDate().testDateHash() }
DateTests.test("testCast") { TestDate().testCast() }
DateTests.test("testDistantPast") { TestDate().testDistantPast() }
DateTests.test("testDistantFuture") { TestDate().testDistantFuture() }
DateTests.test("testEquality") { TestDate().testEquality() }
DateTests.test("testTimeIntervalSinceDate") { TestDate().testTimeIntervalSinceDate() }
DateTests.test("testDateComponents") { TestDate().testDateComponents() }
runAllTests()
#endif
