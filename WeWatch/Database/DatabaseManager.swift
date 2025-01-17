//
//  DatabaseManager.swift
//  WeWatch
//
//  Created by Anton on 07/01/2025.
//
//

import Foundation
import SQLite3

internal final class DatabaseManager {
    
    internal static let shared: DatabaseManager = .init()
    
    internal enum DatabaseError: Error {
        
        case movieAddError
        case movieNotAdd
        case dublicateError
        case updateError
        case notUpdate
        case movieTableCreatioFailed
        case selectStatementFailed
        case movieNotDelete
        case movieDeleteNotPrepare
    }
    
    private init() {
        db = openDatabase()
        do {
            try createMovieTable()
        } catch {
            DatabaseError.movieTableCreatioFailed
        }
    }
    
    private let dataPath: String = "MyDB"
    private var db: OpaquePointer?
    
    internal func openDatabase() -> OpaquePointer? {
        let filePath: URL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent(dataPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            return nil
        } else {
            return db
        }
    }
    
    internal func createMovieTable() throws {
        let createTableString: String = """
        CREATE TABLE IF NOT EXISTS Movie(
            movieId INTEGER PRIMARY KEY,
            title TEXT,
            overview TEXT,
            releaseDate TEXT,
            rating INTEGER,
            posterUrl TEXT
        );
"""
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
            } else {
                throw DatabaseError.movieTableCreatioFailed
            }
        } else {
            throw DatabaseError.movieTableCreatioFailed
        }
        sqlite3_finalize(createTableStatement)
    }
    
    internal func insertMovie(
        movieId: Int,
        title: String,
        overview: String,
        releaseDate: String,
        rating: Int,
        posterUrl: String
    ) throws {
        let movies: [Movie] = try getAllMovies()
        for movie in movies {
            if movie.movieId == movieId || movie.title == title {
                throw DatabaseError.dublicateError
            }
        }
        let insertStatementString: String = "INSERT INTO Movie (title, overview, releaseDate, rating, posterUrl) VALUES (?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (overview as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (releaseDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(rating))
            sqlite3_bind_text(insertStatement, 5, (posterUrl as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                sqlite3_finalize(insertStatement)
            } else {
                throw DatabaseError.movieNotAdd
            }
        } else {
            throw DatabaseError.movieAddError
        }
    }
    
    internal func getAllMovies() throws -> Array<Movie> {
        let queryStatementString: String = "SELECT * FROM Movie;"
        var queryStatement: OpaquePointer? = nil
        var movies: [Movie] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let movieId: Int32 = sqlite3_column_int(queryStatement, 0)
                let title: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let overview: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let releaseDate: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let rating: Int32 = sqlite3_column_int(queryStatement, 4)
                let posterUrl: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                movies.append(Movie(
                    movieId: Int(movieId),
                    title: title,
                    overview: overview,
                    releaseDate: releaseDate,
                    rating: Int(rating),
                    posterUrl: posterUrl
                ))
            }
        } else {
            throw DatabaseError.selectStatementFailed
        }
        sqlite3_finalize(queryStatement)
        return movies
    }
    
    internal func updateMovie(
        movieId: Int,
        title: String,
        overview: String,
        releaseDate: String,
        rating: Int,
        posterUrl: String
    ) throws {
        let updateStatementString: String = "UPDATE Movie SET title = ?, overview = ?, releaseDate = ?, rating = ?, posterUrl = ? WHERE movieId = ?;"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (overview as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (releaseDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 4, Int32(rating))
            sqlite3_bind_text(updateStatement, 5, "", -1, nil)
            sqlite3_bind_int(updateStatement, 6, Int32(movieId))
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                sqlite3_finalize(updateStatement)
            } else {
                throw DatabaseError.notUpdate
            }
        } else {
            throw DatabaseError.updateError
        }
    }
    
    internal func deleteMovieById(movieId: Int) throws  {
        let deleteStatementString: String = "DELETE FROM Movie WHERE movieId = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(movieId))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
            } else {
                throw DatabaseError.movieNotDelete
            }
        } else {
            throw DatabaseError.movieDeleteNotPrepare
        }
        sqlite3_finalize(deleteStatement)
    }
}


