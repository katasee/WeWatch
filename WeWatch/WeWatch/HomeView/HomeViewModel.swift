//
//  HomeViewModel.swift
//  WeWatch
//
//  Created by Anton on 21/01/2025.
//

import Foundation

internal final class HomeViewModel: ObservableObject {
    
    @Published internal var todaySelection: Array<Movie> = []
        // роблю масив з фільмами для закладки todayselection
    @Published internal var discoverySection: Array<Movie> = []
    // роблю масив з фільмами для закладки discoverySection
    internal var currentPage: Int = .init()
    // cторінка
    
    fileprivate enum Constans {
        internal static let discoveryList: String = "DiscoverySection"
            // ключове слово по якому будуть затягуватись фільми для discovery
        internal static let todaySelectionList: String = "TodaySelection"
        // ключове слово по якому будуть затягуватись фільми для todaySelection
        internal static let refreshIntervalHours: Int = 24
        // інтервал з яким оновлюються дані
    }
    
    fileprivate enum HomeViewModelError: Error {
        case insufficientData
            // кастомна помилка яка показує що даних не достатньо
    }
    
    internal func prepareDataDiscoverySection(page: String) async throws -> Array<Movie> {
        // функція яка витягує дані з бекенду і записує їх до дб (повертає масив фільмів)
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        // данні токена
        let token: String = .init(decoding: tokenData, as: UTF8.self)
            // декодинг токена
        let listsResource: Resource<SearchResponse> = .init(
            // ініціалізуємо searchResponse
            url: URL.SearchResponseURL,
            // url
            method: .get([
                .init(name: "query", value: "All"),
                .init(name: "limit", value: "100"),
                .init(name: "page", value: page)
            ]),
            // метод get в якому беремо в квері всі жанри, максимально 100 фільмів і номер сторінки
            token: token
                // токен
        )
        let response: SearchResponse = try await Webservice().call(listsResource)
        // searchResponse
        currentPage += 1
        let moviesForUI: Array<Movie> = response.data?
            // moviesForUI = респонс данних
            .compactMap { MovieDetails in
                    // мапування, проходимось по кожному вибраному елементу details
                guard let id: String = MovieDetails.id,
                      // отримуємо  id
                      let title: String = MovieDetails.name,
                      // отримуємо назву
                      let overview: String = MovieDetails.overview,
                      // отримуємо опис
                      let posterUrl: String = MovieDetails.imageUrl,
                        // отримуємо posterUrl
                      let genreses: [String] = MovieDetails.genres
                        // отримуємо в genress - array<String>

                else {
                    return nil
                    // в іншосу випадку повертаємо ніл
                }
                let genres: String = genreses
                    .joined(separator: ", ")
                    // перетворюємо в один рядок розділений ,
                return .init(
                    id: id,
                    title: title,
                    overview: overview,
                    rating: 3,
                    posterUrl: posterUrl,
                    genres: genres
                )
                // повертаємо ініціалізовані дані
            } ?? .init()
            // якщо ні повертається пуста ініціалізація
        let dbManager: DatabaseManager = try DatabaseManager(dataBaseName: "WeWatch_v1.sqlite")
            // припусуємо DatabaseManager(dataBaseName: "WeWatch_v1.sqlite") до const dbManager
        if try await dbManager.fetchMovieByList(forList: Constans.discoveryList).isEmpty {
            // умова якщо у lists з назвою DiscoverySection нема фільмів, додаємо в дб
            for movie in moviesForUI {
                // беремо фільми які ми витягнули з бекенду
                try await dbManager.insert(movie)
                // додаємо їх до дб
                try await dbManager.attachMovieToList(
                    listId: Constans.discoveryList,
                    movieId: movie.id
                )
                // додаємо їх до lists з назвою DiscoverySection
            }
        }
        return moviesForUI
        // повертаємо moviesForUI (фільми з бекенду)
    }
    
    internal func movieForDiscoveryView() async throws {
            let dbManager: DatabaseManager = try DatabaseManager(dataBaseName: "WeWatch_v1.sqlite")
        // припусуємо DatabaseManager(dataBaseName: "WeWatch_v1.sqlite") до const dbManager
            UserDefaults.standard.set(Date(), forKey: "TodayTime")
        // приписуємо до UserDefaults сет Дати і ключ "TodayTime"
            if try await dbManager.fetchMovieByList(forList: Constans.discoveryList).isEmpty{
                // якщо нема в дб discoveryList елементів
                let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
                    // беремо данні з бекенду і приписуємо до змінної discoveryMovieData
                await MainActor.run { [weak self] in
                    self?.discoverySection = discoveryMovieData
                        // приписуємо discoveryMovieData до discoverySection
                }
            } else {
                if let date: Date = UserDefaults.standard.object(forKey: "TodayTime") as? Date {
                    // якщо дата = даті в Юзердефолт під ключем "TodayTime"
                    if let diff: Int = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > Constans.refreshIntervalHours {
                        // якщо diff = часу який зараз в годинах, from: date, to: Date()).hour (не знаю), і diff > ніж 24
                        let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
                        // приписуємо до discoveryMovieData данні з бекенду
                        await MainActor.run { [weak self] in
                                // ??
                            self?.discoverySection = discoveryMovieData
                            // приписуємо discoveryMovieData до discoverySection
                        }
                    } else {
                        currentPage += 1
                        // додаємо +1 сторінку на випадок якщо данні вже є в даті
                         await MainActor.run { [weak self] in
                             // ??
                            Task {
                                self?.discoverySection = try await dbManager.fetchMovieByList(forList: Constans.discoveryList)
                                    // беремо дані з дб
                            }
                        }
                    }
                }
            }

    }
    
    internal func appendDateFromEndpoint() async throws {
        // додаємо дані при прокрутці
            let discoveryMovieData: [Movie] = try await prepareDataDiscoverySection(page: String(currentPage))
            // приписуємо discoveryMovieData дані з prepareDataDiscoverySection
            await MainActor.run { [weak self] in
                self?.discoverySection.append(contentsOf: discoveryMovieData)
                    // додаємо ці дані до discoverySection
            }
    }
    
    internal func prepareDataTodaySelection(query: String) async throws -> Array<Movie> {
        // функція для витягування фільмів з бекенду для todaySelect
        let tokenData: Data = try KeychainManager.getData(key: KeychainManager.KeychainKey.token)
        // данні токена
        let token: String = .init(decoding: tokenData, as: UTF8.self)
        // декодинг токена
        let searchResource: Resource<SearchResponse> = .init(
            // ініціалізуємо searchResponse
            url: URL.SearchResponseURL,
            method: .get([.init(
                name: "query",
                value: "\(query)")
            ]),
            token: token
        )
        var response: SearchResponse = try await Webservice().call(searchResource)
        // респонс
        var attempts: Int = 0
            // спроби
        let maxAttempts: Int = 5
        // максимальна кількість спроб
        while (response.data?.count ?? 0) < 10  && attempts < maxAttempts {
            // луп який виконується поки умова дійсна (якщо даних буде < 10 i спроб < ніж максимальної кількості)
            response = try await Webservice().call(searchResource)
            // не знаю чи можу залишити тут просто response ?
            attempts += 1
            // +1 спроба
        }
        if (response.data?.count ?? 0) < 10 {
            // якщо фільмів < 10 викидається помилка
            throw HomeViewModelError.insufficientData
        }
        let moviesForUI: Array<Movie> = response.data?
            // приписуємо респонс до moviesForUI
            .prefix(10)
        // макс кількість 10
            .compactMap { details in
                    // перебираємо всі дані з Movie (повертає без nil)
                guard let movieId: String = details.id,
                      let title: String = details.name,
                      let image: String = details.imageUrl else {
                    return nil
                }
                return .init(
                    id: movieId,
                    title: title,
                    overview: "",
                    rating: 3,
                    posterUrl: image,
                    genres: ""
                )
                // повертає ініціалізовані дані
            } ?? .init()
        let dbManager: DatabaseManager = try DatabaseManager(dataBaseName: "WeWatch_v1.sqlite")
            // приписуємо до dbManager  - дб
        for movie in moviesForUI {
            try await dbManager.insert(movie)
                // додаємо фільми до дб
            try await dbManager.attachMovieToList(listId: Constans.todaySelectionList, movieId: movie.id)
            // додаємо фільми до дб з назвою TodaySelection
        }
        return moviesForUI
            // повертаємо фільми
    }
    
    internal func dataForTodaySelection() async throws {
            if hasDateChanged() {
                // якщо дата змінюється
                let todaySelectionData: [Movie] = try await prepareDataTodaySelection(query: randomData())
                // приписуємо данні з бекенду до todaySelectionData
                await MainActor.run { [weak self] in
                    self?.todaySelection = todaySelectionData
                        // додаємо данні до todaySelection
                }
            } else {
                 await MainActor.run { [weak self] in
                    Task {
                        self?.todaySelection = try await DatabaseManager(dataBaseName: "WeWatch_v1.sqlite").fetchMovieByList(forList: Constans.todaySelectionList)
                        // приписуємо до todaySelection дані з бекенду
                    }
                }
            }
    }
    
    internal func hasDateChanged() -> Bool {
        let currentDateString: String = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .short,
            timeStyle: .none
        )
        let lastDate: String? = UserDefaults.standard.string(forKey: "cachedDateString")
        guard lastDate != currentDateString else { return false }
        UserDefaults.standard.setValue(currentDateString, forKey: "cachedDateString")
        return true
    }
    
    internal func randomData() -> String {
        let alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return alphabet.randomElement().map(String.init) ?? "A"
    }
}
