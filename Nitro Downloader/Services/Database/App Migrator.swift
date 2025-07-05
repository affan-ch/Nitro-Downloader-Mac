
// App Migrator.swift

import GRDB

struct AppMigrator {
    
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        // Speeds up development by erasing the database if migrations change
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        // === Migration v1: Create the initial table ===
        migrator.registerMigration("v1") { db in
            try db.create(table: "videos") { t in
                t.primaryKey("id", .text).notNull() // Using UUID as TEXT
                t.column("fileName", .text).notNull()
                t.column("size", .double).notNull()
                t.column("status", .text).notNull()
                t.column("timeLeft", .text).notNull()
                t.column("downloadSpeed", .text).notNull()
                t.column("downloadURL", .text).notNull()
                t.column("lastTryDate", .datetime).notNull()
                t.column("description", .text).notNull()
                t.column("priority", .integer).notNull().defaults(to: 0)
            }
            
            
            try db.create(table: "preferences", ifNotExists: true) { t in
                t.column("key", .text).primaryKey()
                t.column("value", .text).notNull()
            }
            
        }
        
        
        // === Future Migrations ===
        // migrator.registerMigration("v2") { db in ... }
        
        return migrator
    }
}
