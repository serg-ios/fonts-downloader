//
//  FontsDownloader.swift
//  FontsDownloader
//
//  Created by Sergio Rodríguez Rama on 04/08/2020.
//  Copyright © 2020 sergios. All rights reserved.
//

import Foundation
import UIKit

public class FontsDownloader {

    /**
     The URL of the directory where the fonts will be cached.
     */
    public static let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("FontsDownloader")

    /**
     Font download tasks, must be stored someway to cancel them when needed.
     */
    private var urlSessionDataTasks: [URLSessionDataTask] = []

    // MARK: - Init

    public init() {
        // Init must be public.
    }

    deinit {
        cancelCurrentRequests()
    }

    // MARK: - Static methods

    /**
     Converts font `Data` to `UIFont`.

     Tested font file formats:
     - .ttf
     - .otf
     - .ttc

     - Parameter fontData: `Data` of the font file.
     - Parameter size: `UIFont` point size desired, 12 by default.

     - Returns: The corresponding `UIFont` with the requested `pointSize`. If the conversion is not successful, `nil` is returned.
     */
    public static func uiFont(from fontData: Data, size: CGFloat = 12) -> UIFont? {
        guard let cfData = fontData as CFData?, let ctFontDescriptor = CTFontManagerCreateFontDescriptorFromData(cfData) else {
            return nil
        }
        let ctFont = CTFontCreateWithFontDescriptor(ctFontDescriptor, 0, nil)
        let cgFont = CTFontCopyGraphicsFont(ctFont, nil)
        CTFontManagerRegisterGraphicsFont(cgFont, nil)
        guard let fontName = cgFont.postScriptName else {
            return nil
        }
        let uiFont = UIFont(name: fontName as String, size: size)
        return uiFont
    }

    /**
     Saves font `Data` in disk, in the caches directory.

     - Parameter fontData: The `Data` of the font file.
     - Parameter fileName: The name of the file under which the font `Data` will be saved in cache directory.
     */
    public static func cacheFont(_ fontData: Data, saveAs fileName: String) {
        do {
            try fontData.write(to: Self.cacheURL.appendingPathComponent(fileName))
        } catch {
            try? FileManager.default.createDirectory(atPath: Self.cacheURL.path, withIntermediateDirectories: true, attributes: nil)
            try? fontData.write(to: Self.cacheURL.appendingPathComponent(String(fontData.hashValue)))
        }
    }

    /**
     Cleans the cached fonts.
     */
    public static func cleanCache() {
        let fileManager = FileManager.default
        let cachedFiles = try? fileManager.contentsOfDirectory(at: Self.cacheURL, includingPropertiesForKeys: nil, options: [])
        for file in cachedFiles ?? [] {
            try? fileManager.removeItem(at: file)
        }
    }

    // MARK: - Public methods

    /**
     Downloads font from internet url.

     - Parameter name: The name of the font, it will be used to store the file in cache, under `FontsDownloader` directory.
     - Parameter fontSize: `UIFont` point size desired, 12 by default.     
     - Parameter url: The internet url from which the font will be downloaded.
     - Parameter session: The `urlSession` needed to request the font.
     - Parameter cancelPreviousRequests: If `true`, all previous requests alive are cancelled.
     - Parameter writeCache: If `true` (by default), will save the downloaded font in cache.
     - Parameter readCache: If `true` (by default), will try to get the font from cache.
     - Parameter completion: Block that receives as parameter the requested font and a `FontsDownloaderError` if something happens.
     */
    public func downloadFont(name: String, fontSize: CGFloat = 12, url: URL? = nil, session: URLSession? = nil, cancelPreviousRequests: Bool = false, writeCache: Bool = true, readCache: Bool = true, completion: @escaping (UIFont?, FontsDownloaderError?) -> ()) {
        if cancelPreviousRequests {
            cancelCurrentRequests()
        }
        if readCache {
            let cacheUrl = Self.cacheURL.appendingPathComponent(name)
            let fontData = try? Data(contentsOf: cacheUrl)
            if let data = fontData {
                completion(Self.uiFont(from: data), nil)
                return
            }
        }
        guard let url = url, let session = session else {
            completion(nil, .urlSessionError)
            return
        }
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data, let downloadedFont = Self.uiFont(from: data, size: fontSize) else {
                completion(nil, .fontDataError)
                return
            }
            if writeCache {
                Self.cacheFont(data, saveAs: name)
            }
            completion(downloadedFont, nil)
        })
        urlSessionDataTasks.append(task)
        task.resume()
    }

    // MARK: - Private methods

    /**
     Cancels all requests that may be unfinished.
     */
    private func cancelCurrentRequests() {
        urlSessionDataTasks.forEach({
            $0.cancel()
        })
    }
}
