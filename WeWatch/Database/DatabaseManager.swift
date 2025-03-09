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
    case createTable(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
    case missingId
    case unknownError
}

fileprivate enum SQLStatements {
    internal static let movieGenreSQL: String = """
        CREATE TABLE IF NOT EXISTS movie_genres (
        movie_id TEXT NOT NULL,
        genre_id TEXT NOT NULL,
        PRIMARY KEY(movie_id, genre_id),
        FOREIGN KEY(movie_id) REFERENCES movies(id) ON DELETE CASCADE,
        FOREIGN KEY(genre_id) REFERENCES genres(id) ON DELETE CASCADE
        );
        """
    internal static let listMovieSQL: String = """
        CREATE TABLE IF NOT EXISTS list_movies (
        list_id TEXT NOT NULL,
        movie_id TEXT NOT NULL,
        PRIMARY KEY(list_id, movie_id),
        FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE,
        FOREIGN KEY(movie_id) REFERENCES movies(id) ON DELETE CASCADE
        );
        """
    
    internal static let insertGenreMovies: String = "INSERT OR IGNORE INTO movie_genres (movie_id, genre_id) VALUES (?, ?);"
    internal static let insertListMovies: String = "INSERT OR REPLACE INTO list_movies (list_id, movie_id) VALUES (?, ?);"
    internal static let insertGenres: String = "INSERT OR REPLACE INTO genres (id, title) VALUES (?, ?);"
    internal static let selectMovieByList: String = """
            SELECT m.*
            FROM movies m
            JOIN list_movies lm ON lm.movie_id = m.id
            WHERE lm.list_id = ?;
            """
    internal static let selectMovieByGenre: String = """
            SELECT m.*
            FROM movies m
            JOIN movie_genres lm ON lm.movie_id = m.id
            WHERE lm.genre_id = ?;
            """
    internal static let selectedGenres: String = "SELECT * FROM genres;"
}

 public protocol SQLTable {
    static var tableName: String { get }
    static var createTableStatement: String { get }
    
    init(row: [String: Any]) throws
    func toDictionary() -> [String: Any]
}

public actor DatabaseManager {
    
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.example.DatabaseManager")
    
    public init(dataBaseName: String = "WeWatch_v1.sqlite") throws {
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
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.openDatabase(message: errmsg)
        }
    }
    
    private func createAllTables() throws {
        try createTable(for: Movie.self)
        try createTable(for: Genre.self)
        try createTable(for: List.self)
        
        if sqlite3_exec(db, SQLStatements.movieGenreSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.createTable(message: "Error creating movie_genres: \(errmsg)")
        }
   
        if sqlite3_exec(db, SQLStatements.listMovieSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.createTable(message: "Error creating list_movies: \(errmsg)")
        }
    }
    
    public func createTable<T: SQLTable>(for type: T.Type) throws {
        let sql = T.createTableStatement
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.createTable(message: "Error creating table \(T.tableName): \(errmsg)")
        }
    }
    
    public func insert<T: SQLTable>(_ item: T) throws {
        let dict: [String : Any] = item.toDictionary()
        let columns: String = dict.keys.joined(separator: ", ")
        let placeholders: String = dict.keys.map { _ in "?"}.joined(separator: ", ")
        let sql: String = "INSERT OR REPLACE INTO \(T.tableName)(\(columns)) VALUES (\(placeholders));"
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        
        var index: Int32 = 1
        for key in dict.keys {
            let value: Any? = dict[key]
            if let intVal: Int = value as? Int {
                sqlite3_bind_int(stmt, index, Int32(intVal))
            } else if let doubleVal: Double = value as? Double {
                sqlite3_bind_double(stmt, index, doubleVal)
            } else if let strVal: String = value as? String {
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
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func update<T: SQLTable>(_ item: T) throws {
        let dict: [String : Any] = item.toDictionary()
        guard let idValue: Any = dict["id"] else {
            throw DatabaseError.missingId
        }
        let filtered: [String : Any] = dict.filter { $0.key != "id" }
        let assignments: String = filtered.map { "\($0.key) = ?" }.joined(separator: ", ")
        let sql: String = "UPDATE \(T.tableName) SET \(assignments) WHERE id = ?;"
        
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        
        var index: Int32 = 1
        for key in filtered.keys {
            let value: Any? = filtered[key]
            if let intVal: Int = value as? Int {
                sqlite3_bind_int(stmt,index,Int32(intVal))
            } else if let doubleVal:Double = value as? Double {
                sqlite3_bind_double(stmt, index, doubleVal)
            } else if let strVal: String = value as? String {
                sqlite3_bind_text(stmt, index, strVal, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            } else if value == nil {
                sqlite3_bind_null(stmt, index)
            } else {
                sqlite3_finalize(stmt)
                throw DatabaseError.bind(message: "Unsupported type for key \(key)")
            }
            index += 1
        }
        
        if let intId: Int = idValue as? Int {
            sqlite3_bind_int(stmt,index, Int32(intId))
        } else if let strId: String = idValue as? String {
            sqlite3_bind_text(stmt, index, strId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        } else {
            sqlite3_finalize(stmt)
            throw DatabaseError.bind(message: "Unsupported id type")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func delete<T: SQLTable>(from type: T.Type, id: Any) throws {
        let sql = "DELETE FROM \(T.tableName) WHERE id = ?;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        if let intId: Int = id as? Int {
            sqlite3_bind_int(stmt, 1, Int32(intId))
        } else if let strId: String = id as? String {
            sqlite3_bind_text(stmt, 1, strId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        } else {
            sqlite3_finalize(stmt)
            throw DatabaseError.bind(message: "Unsupported id type")
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func insertMovieGenre(movieId: String, genreId: String) throws {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, SQLStatements.insertGenreMovies, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, movieId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, genreId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func attachMovieToList(listId: String, movieId: String) throws {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, SQLStatements.insertListMovies, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, listId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, movieId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func attachListOfGenre(
        genreId: String,
        name: String
    ) throws {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, SQLStatements.insertGenres, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, genreId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_text(stmt, 2, name, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            sqlite3_finalize(stmt)
            throw DatabaseError.step(message: errmsg)
        }
        sqlite3_finalize(stmt)
    }
    
    public func fetch<T: SQLTable>(_:T.Type) throws -> [T] {
        var results: [T] = []
        let sql: String = "SELECT * FROM \(T.tableName);"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        while sqlite3_step(stmt) == SQLITE_ROW {
            let row: [String : Any] = mapRowToDict(stmt: stmt)
            let item: T = try .init(row: row)
            results.append(item)
        }
        sqlite3_finalize(stmt)
        return results
    }
    
    public func fetchMovieByList(forList listId: String) throws -> [Movie] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, SQLStatements.selectMovieByList, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, listId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        var movies: [Movie] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let row: [String : Any] = mapRowToDict(stmt: stmt)
            let movie: Movie = try .init(row: row)
            movies.append(movie)
        }
        sqlite3_finalize(stmt)
        return movies
    }
    
    public func fetchMovieByGenres(forGenre genreId: String) throws -> [Movie] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, SQLStatements.selectMovieByGenre, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        sqlite3_bind_text(stmt, 1, genreId, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        var movies: [Movie] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let row: [String : Any] = mapRowToDict(stmt: stmt)
            let movie: Movie = try .init(row: row)
            movies.append(movie)
        }
        sqlite3_finalize(stmt)
        return movies
    }
    
    public func fetchGenresTab() throws -> [Genre] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, SQLStatements.selectedGenres, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        var genres: [Genre] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let row: [String : Any] = mapRowToDict(stmt: stmt)
            let genre: Genre = try .init(row: row)
            genres.append(genre)
        }
        sqlite3_finalize(stmt)
        return genres
    }
    
    public func mapRowToDict(stmt: OpaquePointer?) -> [String: Any] {
        guard let stmt: OpaquePointer = stmt else { return [:] }
        var row: [String: Any] = [:]
            let columnCount: Int32 = sqlite3_column_count(stmt)
            for i in 0..<columnCount {
                guard let colNameCStr: UnsafePointer<CChar> = sqlite3_column_name(stmt, i) else { continue }
                let colName: String = .init(cString: colNameCStr)
                let colType: Int32 = sqlite3_column_type(stmt, i)
                switch colType {
                case SQLITE_INTEGER:
                    let intVal: Int32 = sqlite3_column_int(stmt, i)
                    row[colName] = Int(intVal)
                case SQLITE_FLOAT:
                    let dblVal: Double = sqlite3_column_double(stmt, i)
                    row[colName] = Double(dblVal)
                case SQLITE_TEXT:
                    if let cString: UnsafePointer<UInt8> = sqlite3_column_text(stmt, i) {
                        row[colName] = String(cString: cString)
                    }
                case SQLITE_NULL:
                    row[colName] = nil
                default:
                    break
                }
            }
        return row
    }
}
