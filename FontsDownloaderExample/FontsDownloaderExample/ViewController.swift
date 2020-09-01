//
//  ViewController.swift
//  FontsDownloaderExample
//
//  Created by Sergio Rodríguez Rama on 06/09/2020.
//  Copyright © 2020 serg-ios. All rights reserved.
//

import UIKit
import FontsDownloader

class ViewController: UIViewController {

    private let fontsDownloader = FontsDownloader()

    private let fonts: [Font] = [
        Font(name: "Mukta Mahee", url: URL(string: "https://github.com/serg-ios/fonts-downloader/blob/develop/FontsDownloaderTests/Resources/MuktaMahee.ttc?raw=true")!),
        Font(name: "New York", url: URL(string: "https://github.com/serg-ios/fonts-downloader/blob/develop/FontsDownloaderTests/Resources/NewYork.ttf?raw=true")!),
        Font(name: "SF Pro Text Regular", url: URL(string: "https://github.com/serg-ios/fonts-downloader/blob/develop/FontsDownloaderTests/Resources/SF-Pro-Text-Regular.otf?raw=true")!)
    ]

    private let fontSize: CGFloat = 30

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var label: UILabel!
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        cell.textLabel?.attributedText = NSAttributedString(string: fonts[indexPath.row].name, attributes: [.paragraphStyle:style, .foregroundColor: UIColor.red])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fonts.count
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        fontsDownloader.downloadFont(name: fonts[indexPath.row].name, fontSize: fontSize, url: fonts[indexPath.row].url, session: URLSession.shared, cancelPreviousRequests: true, writeCache: false, readCache: false) { (font, error) in
            guard error == nil else { return }
            DispatchQueue.main.async { [weak self] in
                self?.label.font = font
            }
        }
    }
}
