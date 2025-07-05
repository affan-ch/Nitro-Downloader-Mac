
//  Preferences.swift


import Foundation
import GRDB

struct Preferences: Codable, FetchableRecord, PersistableRecord {
    var key: String
    var value: String
    
    static var databaseTableName = "preferences"
}
