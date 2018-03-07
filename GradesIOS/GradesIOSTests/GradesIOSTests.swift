//
//  GradesIOSTests.swift
//  GradesIOSTests
//
//  Created by Inna Soboleva on 1/19/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import XCTest
@testable import GradesIOS

class GradesIOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTask() {
        let task = Task(uid: 0, name: "")
        XCTAssertEqual(task, nil)
        let task2 = Task(uid: 1, name: "Inna")
        let task3 = Task(uid: 2, name: "Inna")
        XCTAssertEqual(task2, task3)
    }
    
    func testSubject() {
        let subject = Subject(uid: 0, name: "")
        XCTAssertEqual(subject, nil)
        let subject2 = Subject(uid: 1, name: "Inna")
        let subject3 = Subject(uid: 2, name: "Inna")
        XCTAssertEqual(subject2, subject3)
    }
    
    func testUser() {
        let user = User(uid: 0, name: "")
        XCTAssertEqual(user, nil)
        let user2 = User(uid: 1, name: "Inna")
        let user3 = User(uid: 2, name: "Inna")
        XCTAssertEqual(user2, user3)
    }
    
}
