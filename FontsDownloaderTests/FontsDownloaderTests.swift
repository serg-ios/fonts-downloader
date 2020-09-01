//
//  FontsDownloaderTests.swift
//  FontsDownloaderTests
//
//  Created by Sergio Rodríguez Rama on 04/08/2020.
//  Copyright © 2020 sergios. All rights reserved.
//

import XCTest

@testable import FontsDownloader

class FontsDownloaderTests: XCTestCase {

    private static let newYorkFontURL = URL(string: "https://github.com/serg-ios/fonts-downloader/raw/develop/FontsDownloaderTests/Resources/NewYork.ttf?raw=true")

    private let newYorkTestFont = TestFont(name: "NewYork", format: "ttf", internetURL: newYorkFontURL)
    private let sfProTextTestFont = TestFont(name: "SF-Pro-Text-Regular", format: "otf")
    private let muktaMaheeTestFont = TestFont(name: "MuktaMahee", format: "ttc")

    private var urlSession: URLSession!
    private var fontsDownloader: FontsDownloader!

    // MARK: - Test life cycle

    override func setUp() {
        fontsDownloader = FontsDownloader()
        urlSession = URLSession.shared
    }

    override func tearDown() {
        FontsDownloader.cleanCache()
        fontsDownloader = nil
        urlSession = nil
    }

    // MARK: - Tests

    func testTTFFontDataToUIFont() {
        // Given
        let expectedSize: CGFloat = 12
        let expectedFamilyName = "New York"
        // When
        let uiFont = FontsDownloader.uiFont(from: newYorkTestFont.localData)
        // Then
        XCTAssertEqual(expectedSize, uiFont?.pointSize)
        XCTAssertEqual(expectedFamilyName, uiFont?.familyName)
    }

    func testOTFFontDataToUIFont() {
        // Given
        let expectedSize: CGFloat = 16
        let expectedFamilyName = "SF Pro Text"
        // When
        let uiFont = FontsDownloader.uiFont(from: sfProTextTestFont.localData, size: expectedSize)
        // Then
        XCTAssertEqual(expectedSize, uiFont?.pointSize)
        XCTAssertEqual(expectedFamilyName, uiFont?.familyName)
    }

    func testTTCFontDataToUIFont() {
        // Given
        let expectedSize: CGFloat = 60
        let expectedFamilyName = "Mukta Mahee"
        // When
        let uiFont = FontsDownloader.uiFont(from: muktaMaheeTestFont.localData, size: expectedSize)
        // Then
        XCTAssertEqual(expectedSize, uiFont?.pointSize)
        XCTAssertEqual(expectedFamilyName, uiFont?.familyName)
    }

    func testCacheFontSuccessfully() {
        // Given
        XCTAssertNil(muktaMaheeTestFont.cacheData)
        // When
        FontsDownloader.cacheFont(muktaMaheeTestFont.localData, saveAs: muktaMaheeTestFont.name)
        // Then
        XCTAssertEqual(muktaMaheeTestFont.localData, muktaMaheeTestFont.cacheData)
    }

    func testCacheFontSuccessfullyCleaned() {
        // Given
        XCTAssertNil(muktaMaheeTestFont.cacheData)
        FontsDownloader.cacheFont(muktaMaheeTestFont.localData, saveAs: muktaMaheeTestFont.name)
        XCTAssert(muktaMaheeTestFont.localData == muktaMaheeTestFont.cacheData)
        // When
        FontsDownloader.cleanCache()
        // Then
        XCTAssertNil(muktaMaheeTestFont.cacheData)
    }

    func testDownloadFontFromTheInternetAndCacheFontInDisk() {
        // Given
        let expectation = XCTestExpectation()
        XCTAssertNil(newYorkTestFont.cacheData)
        // When
        fontsDownloader.downloadFont(name: newYorkTestFont.name, url: newYorkTestFont.internetURL, session: urlSession, writeCache: true, readCache: false) { [weak self] (font, error) in
        // Then
            XCTAssertEqual(font, self?.newYorkTestFont.localFont)
            XCTAssertEqual(self?.newYorkTestFont.localData, self?.newYorkTestFont.cacheData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testDownloadFontFromTheInternetAndDontCacheFontInDisk() {
        // Given
        let expectation = XCTestExpectation()
        XCTAssertNil(newYorkTestFont.cacheData)
        // When
        fontsDownloader.downloadFont(name: newYorkTestFont.name, url: newYorkTestFont.internetURL, session: urlSession, writeCache: false, readCache: false) { [weak self] (font, error) in
        // Then
            XCTAssertEqual(font, self?.newYorkTestFont.localFont)
            XCTAssertNil(self?.newYorkTestFont.cacheData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testDownloadFontFromTheInternetNeverDownloadsBecauseFontIsInCache() {
        // Given
        let expectation = XCTestExpectation()
        fontsDownloader.downloadFont(name: newYorkTestFont.name) { (font, error) in
            XCTAssertNil(font)
        }
        // When
        FontsDownloader.cacheFont(newYorkTestFont.localData, saveAs: newYorkTestFont.name)
        fontsDownloader.downloadFont(name: newYorkTestFont.name) { [weak self] (font, error) in
        // Then
            XCTAssertEqual(font, self?.newYorkTestFont.localFont)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}

// MARK: - Test classes

/**
 Will be used only for testing purposes. To simplify testing code.
 */
fileprivate class TestFont {
    var name: String
    var localURL: URL
    var localData: Data
    var localFont: UIFont
    var cacheURL: URL
    var cacheData: Data? { try? Data(contentsOf: self.cacheURL) }
    var internetURL: URL?

    init(name: String, format: String, internetURL: URL? = nil) {
        self.name = name
        self.localURL = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: name, ofType: format)!)
        self.localData = try! Data(contentsOf: localURL)
        self.localFont = FontsDownloader.uiFont(from: localData)!
        self.cacheURL = FontsDownloader.cacheURL.appendingPathComponent(name)
        self.internetURL = internetURL
    }
}
