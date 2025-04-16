//
//  SQLStatements.swift
//  WeWatch
//
//  Created by Anton on 16/04/2025.
//

import Foundation

internal enum SQLStatements {
    
    internal static let createBookmarkIdsTableSQL: String = """
     CREATE TABLE IF NOT EXISTS bookmark(
     id TEXT PRIMARY KEY
     );
     """
    internal static let selectedBookmarkIds: String = "SELECT * FROM bookmark;"
    internal static let createMoviesTableSQL: String = """
     CREATE TABLE IF NOT EXISTS movies(
     id TEXT PRIMARY KEY,
     title TEXT NOT NULL,
     overview TEXT,
     year TEXT,
     posterUrl TEXT,
     country TEXT,
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
