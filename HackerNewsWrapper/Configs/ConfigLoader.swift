//
//  ConfigLoader.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 18/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation

class ConfigLoader {
    static let ConfigName = "Config.plist"

    static func parseFile(named fileName: String = ConfigName) -> Configuration {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil),
            let fileData = FileManager.default.contents(atPath: filePath)
        else {
            fatalError("Config file '\(fileName)' not loadable!")
        }

        do {
            let config = try PropertyListDecoder().decode(Configuration.self, from: fileData)
            return config
        } catch {
            fatalError("Configuration not decodable from '\(fileName)': \(error)")
        }
    }

    func showMsg() {
        print(config.msg)
    }

    func getFlag() -> String {
        return config.flag
    }
}

struct Configuration: Decodable {
    let flag: String
    let msg: String
}

let config = ConfigLoader.parseFile()
