//
//  DatabaseManager.swift
//  WeWatch
//
//  Created by Anton on 07/01/2025.
//
//

import Foundation
import SQLite3

internal enum DatabaseError: Error {
    
    case openDatabase(message: String)
    case createTable(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
    case missingId
    case unknownError
    case transactionError
    case fetchError(message: String)
}

internal enum Constans {
    
    internal static let bookmarkList: String = "Bookmark"
    internal static let discoveryList: String = "DiscoverySection"
    internal static let todaySelectionList: String = "TodaySelection"
    internal static let refreshIntervalHours: Int = 24
}

internal enum DatabaseConfig {
    
    internal static let name: String = "WeWatch_v1.sqlite"
}

internal enum SQLStatements {
    
    internal static let createBookmarkIdsTableSQL: String = """
     CREATE TABLE IF NOT EXISTS bookmark(
     id TEXT PRIMARY KEY
     );
     """
    internal static let insertBookmarkIds: String = "INSERT OR REPLACE INTO bookmark id VALUES ?;"
    internal static let selectedBookmarkIds: String = "SELECT * FROM bookmark;"
    internal static let createMoviesTableSQL: String = """
     CREATE TABLE IF NOT EXISTS movies(
     id TEXT PRIMARY KEY,
     title TEXT NOT NULL,
     overview TEXT,
     rating REAL,
     posterUrl TEXT,
     genres TEXT
     );
     """
    internal static let createListsTableSQL: String = """
     CREATE TABLE IF NOT EXISTS lists(
     id TEXT PRIMARY KEY,
     title TEXT NOT NULL
     );
     """
    internal static let createGenresTableSQL: String = """
     CREATE TABLE IF NOT EXISTS genres(
     id TEXT PRIMARY KEY,
     title TEXT NOT NULL
     );
     """
    internal static let createMovieGenreTableSQL: String = """
     CREATE TABLE IF NOT EXISTS movie_genres (
     movie_id TEXT NOT NULL,
     genre_id TEXT NOT NULL,
     PRIMARY KEY(movie_id, genre_id),
     FOREIGN KEY(movie_id) REFERENCES movies(id) ON DELETE CASCADE,
     FOREIGN KEY(genre_id) REFERENCES genres(id) ON DELETE CASCADE
     );
     """
    internal static let createdListMovieTableSQL: String = """
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
    internal static let selectedMovieId: String = """
    SELECT * FROM movies
    WHERE id = ?;
    """
    internal static let selectMovieByTitle: String = """
    SELECT * FROM movies
    WHERE title = ?;
    """
    internal static let selectedGenres: String = "SELECT * FROM genres;"
    internal static let beginTransaction: String = "BEGIN TRANSACTION;"
    internal static let saveAllChanges: String = "COMMIT;"
    internal static let undoesChanges: String = "ROLLBACK;"
}

internal protocol SQLTable {
    
    static var tableName: String { get }
    static var createTableStatement: String { get }
    
    init(row: Dictionary<String, Any>) throws
    func toDictionary() -> Dictionary<String, Any>
}

internal enum SQLiteConstants {
    
    internal static let sqliteTransient: sqlite3_destructor_type = unsafeBitCast(
        OpaquePointer(
            bitPattern: -1),
        to: sqlite3_destructor_type.self
    )
}

internal actor DatabaseManager {
    
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.example.DatabaseManager")
    
    internal init(dataBaseName: String = DatabaseConfig.name) {
        do {
            try openDatabase(named: dataBaseName)
            try createAllTables()
        } catch {
            
        }
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
        if sqlite3_exec(db, SQLStatements.createMovieGenreTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.createTable(message: "Error creating movie_genres: \(errmsg)")
        }
        if sqlite3_exec(db, SQLStatements.createdListMovieTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.createTable(message: "Error creating list_movies: \(errmsg)")
        }
    }
    
    internal func createTable<T: SQLTable>(for type: T.Type) throws {
        let sql = T.createTableStatement
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.createTable(message: "Error creating table \(T.tableName): \(errmsg)")
        }
    }
    
    private func beginTransaction() {
        sqlite3_exec(db, SQLStatements.beginTransaction, nil, nil, nil)
    }
    
    private func commitTransaction() {
        sqlite3_exec(db, SQLStatements.saveAllChanges, nil, nil, nil)
    }
    
    private func rollbackTransaction() {
        sqlite3_exec(db, SQLStatements.undoesChanges, nil, nil, nil)
    }
    
    private func transaction(_ transactionBlock: (DatabaseManager) throws -> ()) throws {
        beginTransaction()
        do {
            try transactionBlock(self)
            commitTransaction()
        } catch {
            rollbackTransaction()
            throw DatabaseError.transactionError
        }
    }
    
    
    internal func insert<T: SQLTable>(_ item: T) throws {
        
        try transaction {  dbManager in
            let dict: Dictionary<String, Any> = item.toDictionary()
            let columns: String = dict.keys.joined(separator: ", ")
            let placeholders: String = dict.keys.map { _ in "?"}.joined(separator: ", ")
            let sql: String = "INSERT OR REPLACE INTO \(T.tableName)(\(columns)) VALUES (\(placeholders));"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            var index: Int32 = 1
            for key in dict.keys {
                let value: Any? = dict[key]
                try bindValue(value, to: stmt, at: index)
                index += 1
            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.step(message: errmsg)
            }
        }
    }
    
    internal func update<T: SQLTable>(_ item: T) throws {
        try transaction { dbManager in
            let dict: Dictionary<String, Any> = item.toDictionary()
            guard let idValue: Any = dict["id"] else {
                throw DatabaseError.missingId
            }
            let filtered: Dictionary<String, Any> = dict.filter { $0.key != "id" }
            let assignments: String = filtered.map { "\($0.key) = ?" }.joined(separator: ", ")
            let sql: String = "UPDATE \(T.tableName) SET \(assignments) WHERE id = ?;"
            
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            
            var index: Int32 = 1
            for key in filtered.keys {
                let value: Any? = filtered[key]
                try bindValue(value, to: stmt, at: index)
                index += 1
            }
            
            if let intId: Int = idValue as? Int {
                sqlite3_bind_int(stmt,index, Int32(intId))
            } else if let strId: String = idValue as? String {
                sqlite3_bind_text(stmt, index, strId, -1, SQLiteConstants.sqliteTransient)
            } else {
                throw DatabaseError.bind(message: "Unsupported id type")
            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.step(message: errmsg)
            }
        }
    }
    
    internal func delete<T: SQLTable>(from type: T.Type, id: Any) throws {
        try transaction { dbManager in
            let sql = "DELETE FROM \(T.tableName) WHERE id = ?;"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            if let intId: Int = id as? Int {
                sqlite3_bind_int(stmt, 1, Int32(intId))
            } else if let strId: String = id as? String {
                sqlite3_bind_text(stmt, 1, strId, -1, SQLiteConstants.sqliteTransient)
            } else {
                throw DatabaseError.bind(message: "Unsupported id type")
            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.step(message: errmsg)
                
            }
        }
    }
    
    internal func detachMovieFromList(listId: String, movieId: String) throws {
        try transaction { dbManager in
            let sql = "DELETE FROM list_movies WHERE list_id = ? AND movie_id = ?;"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            sqlite3_bind_text(stmt, 1, listId, -1, SQLiteConstants.sqliteTransient)
            sqlite3_bind_text(stmt, 2, movieId, -1, SQLiteConstants.sqliteTransient)
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.step(message: errmsg)
            }
        }
    }
    
    internal func deleteAll<T: SQLTable>(from type: T.Type) throws {
        try transaction { dbManager in
            let sql = "DELETE FROM \(T.tableName);"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.step(message: errmsg)
            }
        }
    }
    
    internal func insertMovieGenre(
        movieId: String,
        genreId: String
    ) throws {
        try transaction { dbManager in
            try executeSimpleQuery(
                sql: SQLStatements.insertGenreMovies,
                params: [movieId, genreId]
            )
        }
    }
    
    internal func attachMovieToList(
        listId: String,
        movieId: String
    ) throws {
        try transaction { dbManager in
            try executeSimpleQuery(sql: SQLStatements.insertListMovies, params: [listId, movieId])
        }
    }
    
    internal func attachListOfGenre(
        genreId: String,
        name: String
    ) throws {
        try transaction { dbManager in
            try executeSimpleQuery(sql: SQLStatements.insertGenres, params: [genreId, name])
        }
    }
    
    internal func attachBookmarkIds(
        bookmarkId: String
    ) throws {
        try transaction { dbManager in
            try executeSimpleQuery(sql: SQLStatements.insertBookmarkIds, params: [bookmarkId])
        }
    }
    
    internal func fetch<T: SQLTable>(_:T.Type) throws -> Array<T> {
        var results: Array<T> = .init()
        try transaction { dbManager in
            let sql: String = "SELECT * FROM \(T.tableName);"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                let item: T = try .init(row: row)
                results.append(item)
            }
        }
        return results
    }
    
    internal func fetchMovieByList(forList listId: String) throws -> Array<Movie> {
        var stmt: OpaquePointer?
        var movies: Array<Movie> = .init()
        try transaction { dbManager in
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, SQLStatements.selectMovieByList, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            sqlite3_bind_text(stmt, 1, listId, -1, SQLiteConstants.sqliteTransient)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                let movie: Movie = try .init(row: row)
                movies.append(movie)
            }
        }
        return movies
    }
    
    
    
    internal func searchMovie(by title: String) throws -> Array<Movie> {
        var stmt: OpaquePointer?
        var movies: Array<Movie> = .init()
        try transaction { dbManager in
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, SQLStatements.selectMovieByTitle, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            sqlite3_bind_text(stmt, 1, title, -1, SQLiteConstants.sqliteTransient)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                let movie: Movie = try .init(row: row)
                movies.append(movie)
            }
        }
        return movies
    }
    
    internal func fetchMovie(by id: String) throws -> Movie {
        var stmt: OpaquePointer?
        var movie: Movie?
        try transaction { dbManager in
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, SQLStatements.selectedMovieId, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            sqlite3_bind_text(stmt, 1, id, -1, SQLiteConstants.sqliteTransient)
            if sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                movie = try .init(row: row)
            }
        }
        guard let unwrapMovie = movie else {
            throw DatabaseError.fetchError(message: "Fetch movie by id error")
        }
        return unwrapMovie
    }
    
    internal func fetchMovieByGenres(forGenre genreId: String) throws -> Array<Movie> {
        var stmt: OpaquePointer?
        var movies: Array<Movie> = .init()
        try transaction { dbManager in
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, SQLStatements.selectMovieByGenre, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            sqlite3_bind_text(stmt, 1, genreId, -1, SQLiteConstants.sqliteTransient)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                let movie: Movie = try .init(row: row)
                movies.append(movie)
            }
        }
        return movies
    }
    
    internal func fetchGenresTab() throws -> Array<Genre> {
        var stmt: OpaquePointer?
        var genres: Array<Genre> = .init()
        try transaction { dbManager in
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, SQLStatements.selectedGenres, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                let genre: Genre = try .init(row: row)
                genres.append(genre)
            }
        }
        return genres
    }
    
    internal func fetchBookmarkIds() throws -> Array<BookmarkIds> {
        var stmt: OpaquePointer?
        var ids: Array<BookmarkIds> = .init()
        try transaction { dbManager in
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, SQLStatements.selectedBookmarkIds, -1, &stmt, nil) == SQLITE_OK else {
                let errmsg: String = .init(cString: sqlite3_errmsg(db))
                throw DatabaseError.prepare(message: errmsg)
            }
            while sqlite3_step(stmt) == SQLITE_ROW {
                let row: Dictionary<String, Any> = mapRowToDict(stmt: stmt)
                let id: BookmarkIds = try .init(row: row)
                ids.append(id)
            }
        }
        return ids
    }
    
    internal func mapRowToDict(stmt: OpaquePointer?) -> [String: Any] {
        guard let stmt: OpaquePointer = stmt else { return [:] }
        var row: Dictionary<String, Any> = [:]
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
    
    
    private func bindValue(_ value: Any?, to stmt: OpaquePointer?, at index: Int32) throws {
        if let intVal = value as? Int {
            sqlite3_bind_int(stmt, index, Int32(intVal))
        } else if let doubleVal = value as? Double {
            sqlite3_bind_double(stmt, index, doubleVal)
        } else if let strVal = value as? String {
            let sqliteTransient = SQLiteConstants.sqliteTransient
            sqlite3_bind_text(stmt, index, strVal, -1, sqliteTransient)
        } else if value == nil {
            sqlite3_bind_null(stmt, index)
        } else {
            throw DatabaseError.bind(message: "Unsupported type for index \(index)")
        }
    }
    
    private func executeSimpleQuery(sql: String, params: [String]) throws {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.prepare(message: errmsg)
        }
        defer { sqlite3_finalize(stmt) }
        for (index, param) in params.enumerated() {
            let sqliteTransient = SQLiteConstants.sqliteTransient
            sqlite3_bind_text(stmt, Int32(index + 1), param, -1, sqliteTransient)
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg: String = .init(cString: sqlite3_errmsg(db))
            throw DatabaseError.step(message: errmsg)
        }
    }
}
