//
//  DatabaseManager.swift
//  WeWatch
//
//  Created by Anton on 07/01/2025.
//
//

import Foundation
import SQLite3

public enum DatabaseError: Error {
    
    case openDatabase(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
    case missingId
    case unknownError
}

public protocol SQLTable {
    static var tableName: String { get }
    static var createTableStatement: String { get }
    
    init(row: [String: Any]) throws
    func toDictionary() -> [String: Any]
}

public final class DatabaseManager {
    
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.example.DatabaseManager")
    
    public init(dataBaseName: String = "myApp.sqlite") throws {
        try openDatabase(named: dataBaseName)
        try createAllTables()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    private func openDatabase(named dbName: String) throws {
        let fileUrl: URL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(dbName)
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.openDatabase(message: errmsg)
        }
    }
    
    private func createAllTables() throws {
        try createTable(for: Movie.self)
        try createTable(for: Genre.self)
        try createTable(for: List.self)
        
        let movieGenreSQL: String = """
        CREATE TABLE IF NOT EXISTS movie_genres (
        movie_id TEXT NOT NULL,
        genre_id TEXT NOT NULL,
        PRIMARY KEY(movie_id, genre_id),
        FOREIGN KEY(movie_id) REFERENCES movies(id) ON DELETE CASCADE,
        FOREIGN KEY(genre_id) REFERENCES genres(id) ON DELETE CASCADE
        );
        """
        if sqlite3_exec(db, movieGenreSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw
            DatabaseError.openDatabase(message: "Error creating movie_genres: \(errmsg)")
        }
        
        let listMovieSQL: String = """
        CREATE TABLE IF NOT EXISTS list_movies (
        list_id TEXT NOT NULL,
        movie_id TEXT NOT NULL,
        PRIMARY KEY(list_id, movie_id),
        FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE,
        FOREIGN KEY(movie_id) REFERENCES movies(id) ON DELETE CASCADE
        );
        """
        if sqlite3_exec(db, listMovieSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.openDatabase(message: "Error creating list_movies: \(errmsg)")
        }
    }
    
    public func createTable<T: SQLTable>(for type: T.Type) throws {
        let sql = T.createTableStatement
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.openDatabase(message: "Error creating table \(T.tableName): \(errmsg)")
        }
    }
    
    public func insert<T: SQLTable>(_ item: T) throws {
        let dict = item.toDictionary()
        let columns = dict.keys.joined(separator: ", ")
        let placeholders = dict.keys.map { _ in "?"}.joined(separator: ", ")
        let sql = "INSERT OR REPLACE INTO \(T.tableName)(\(columns)) VALUES (\(placeholders));"

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        
        var index: Int32 = 1
        for key in dict.keys {
            let value = dict[key]
            if let intVal = value as? Int {
                sqlite3_bind_int(stmt, index, Int32(intVal))
            } else if let doubleVal = value as? Double {
                sqlite3_bind_double(stmt, index, doubleVal)
            } else if let strVal = value as? String {
                sqlite3_bind_text(stmt, index, strVal, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            } else if value == nil {
                sqlite3_bind_null(stmt, index)
            } else {
                sqlite3_finalize(stmt)
                throw DatabaseError.bind(message: "Unsupported type for key \(key)")
            }
            index += 1
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func fetch<T: SQLTable>(_:T.Type) throws -> [T] {
        var results: [T] = []
        let sql = "SELECT * FROM \(T.tableName);"
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]
            let columnCount = sqlite3_column_count(stmt)
            for i in 0..<columnCount {
                guard let colNameCStr = sqlite3_column_name(stmt, i) else { continue }
                let colName = String(cString: colNameCStr)
                let colType = sqlite3_column_type(stmt, i)
                switch colType {
                case SQLITE_INTEGER:
                    let intVal = sqlite3_column_int(stmt, i)
                    row[colName] = Int(intVal)
                case SQLITE_FLOAT:
                    let dblVal = sqlite3_column_double(stmt, i)
                    row[colName] = Double(dblVal)
                case SQLITE_TEXT:
                    if let cString = sqlite3_column_text(stmt, i) {
                        row[colName] = String(cString: cString)
                    }
                case SQLITE_NULL:
                    row[colName] = nil
                default:
                    break
                }
            }
            do {
                let item = try T(row: row)
                results.append(item)
            } catch {
                print("Error decoding row: \(error)")
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
    
    public func update<T: SQLTable>(_ item: T) throws {
        let dict = item.toDictionary()
        guard let idValue = dict["id"] else {
            throw DatabaseError.missingId
        }
        let filtered = dict.filter { $0.key != "id" }
        let assignments = filtered.map { "\($0.key) = ?" }.joined(separator: ", ")
        let sql = "UPDATE \(T.tableName) SET \(assignments) WHERE id = ?;"
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        
        var index: Int32 = 1
        for key in filtered.keys {
            let value = filtered[key]
            if let intVal = value as? Int {
                sqlite3_bind_int(stmt,index,Int32(intVal))
            } else if let doubleVal = value as? Double {
                sqlite3_bind_double(stmt, index, doubleVal)
            } else if let strVal = value as? String {
                sqlite3_bind_text(stmt, index, strVal, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            } else if value == nil {
                sqlite3_bind_null(stmt, index)
            } else {
                sqlite3_finalize(stmt)
                throw DatabaseError.bind(message: "Unsupported type for key \(key)")
            }
            index += 1
        }
        
        if let intId = idValue as? Int {
            sqlite3_bind_int(stmt,index, Int32(intId))
        } else if let strId = idValue as? String {
            sqlite3_bind_text(stmt, index, strId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        } else {
            sqlite3_finalize(stmt)
            throw DatabaseError.bind(message: "Unsupported id type")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func delete<T: SQLTable>(from type: T.Type, id: Any) throws {
        let sql = "DELETE FROM \(T.tableName) WHERE id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        if let intId = id as? Int {
            sqlite3_bind_int(stmt, 1, Int32(intId))
        } else if let strId = id as? String {
            sqlite3_bind_text(stmt, 1, strId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        } else {
            sqlite3_finalize(stmt)
            throw DatabaseError.bind(message: "Unsupported id type")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    func insertMovieGenre(movieId: String, genreId: String) throws {
        let sql = "INSERT OR IGNORE INTO movie_genres (movie_id, genre_id) VALUES (?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, movieId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, genreId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    func attachMovieToList(listId: String, movieId: String) throws {
        let sql = "INSERT OR REPLACE INTO list_movies (list_id, movie_id) VALUES (?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, listId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, movieId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    func attachListOfGenre(
        genreId: String,
        name: String
    ) throws {
        let sql = "INSERT OR REPLACE INTO genres (id, title) VALUES (?, ?);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, genreId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, name, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    func fetchMovieByList(forList listId: String) throws -> [Movie] {
        let sql = """
            SELECT m.*
            FROM movies m
            JOIN list_movies lm ON lm.movie_id = m.id
            WHERE lm.list_id = ?;
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, listId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        
        var movies: [Movie] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]
            let columnCount = sqlite3_column_count(stmt)
            for i in 0..<columnCount {
                guard let colNameCStr = sqlite3_column_name(stmt, i) else { continue }
                let colName = String(cString: colNameCStr)
                let colType = sqlite3_column_type(stmt, i)
                switch colType {
                case SQLITE_INTEGER:
                    let intVal = sqlite3_column_int(stmt, i)
                    row[colName] = Int(intVal)
                case SQLITE_FLOAT:
                    let dblVal = sqlite3_column_double(stmt, i)
                    row[colName] = Double(dblVal)
                case SQLITE_TEXT:
                    if let cString = sqlite3_column_text(stmt, i) {
                        row[colName] = String(cString: cString)
                    }
                case SQLITE_NULL:
                    row[colName] = nil
                default:
                    break
                }
            }
            do {
                let movie = try Movie(row: row)
                movies.append(movie)
            } catch {
                print("Error decoding movie: \(error)")
            }
        }
        sqlite3_finalize(stmt)
        return movies
    }
    
    func fetchMovieByGenres(forGenre genreId: String) throws -> [Movie] {
        let sql = """
            SELECT m.*
            FROM movies m
            JOIN movie_genres lm ON lm.movie_id = m.id
            WHERE lm.genre_id;
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, genreId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        
        var movies: [Movie] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]
            let columnCount = sqlite3_column_count(stmt)
            for i in 0..<columnCount {
                guard let colNameCStr = sqlite3_column_name(stmt, i) else { continue }
                let colName = String(cString: colNameCStr)
                let colType = sqlite3_column_type(stmt, i)
                switch colType {
                case SQLITE_INTEGER:
                    let intVal = sqlite3_column_int(stmt, i)
                    row[colName] = Int(intVal)
                case SQLITE_FLOAT:
                    let dblVal = sqlite3_column_double(stmt, i)
                    row[colName] = Double(dblVal)
                case SQLITE_TEXT:
                    if let cString = sqlite3_column_text(stmt, i) {
                        row[colName] = String(cString: cString)
                    }
                case SQLITE_NULL:
                    row[colName] = nil
                default:
                    break
                }
            }
            do {
                let movie = try Movie(row: row)
                movies.append(movie)
            } catch {
                print("Error decoding movie: \(error)")
            }
        }
        sqlite3_finalize(stmt)
        return movies
    }
    
    func fetchGenresTab() throws -> [Genre] {
        let sql = """
            SELECT * FROM genres;
            """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        
        var genres: [Genre] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]
            let columnCount = sqlite3_column_count(stmt)
            for i in 0..<columnCount {
                guard let colNameCStr = sqlite3_column_name(stmt, i) else { continue }
                let colName = String(cString: colNameCStr)
                let colType = sqlite3_column_type(stmt, i)
                switch colType {
                case SQLITE_INTEGER:
                    let intVal = sqlite3_column_int(stmt, i)
                    row[colName] = Int(intVal)
                case SQLITE_FLOAT:
                    let dblVal = sqlite3_column_double(stmt, i)
                    row[colName] = Double(dblVal)
                case SQLITE_TEXT:
                    if let cString = sqlite3_column_text(stmt, i) {
                        row[colName] = String(cString: cString)
                    }
                case SQLITE_NULL:
                    row[colName] = nil
                default:
                    break
                }
            }
            do {
                let genre = try Genre(row: row)
                genres.append(genre)
            } catch {
                print("Error decoding movie: \(error)")
            }
        }
        sqlite3_finalize(stmt)
        return genres
    }
}
