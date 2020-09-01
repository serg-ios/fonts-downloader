//
//  FontsDownloaderError.swift
//  FontsDownloader
//
//  Created by Sergio Rodríguez Rama on 06/09/2020.
//  Copyright © 2020 serg-ios. All rights reserved.
//

import Foundation

public enum FontsDownloaderError: LocalizedError {
    case urlSessionError
    case fontDataError

    public var errorDescription: String? {
        switch self {
        case .urlSessionError:
            return "Invalid URL or URLSession."
        case .fontDataError:
            return "Downloaded Data may be nil or non-convertible to UIFont."
        }
    }
}
