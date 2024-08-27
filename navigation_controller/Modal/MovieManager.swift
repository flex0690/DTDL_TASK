//
//  MovieManager.swift
//  navigation_controller
//
//  Created by Tarun Kumar on 23/08/24.
//

import Foundation

//    now playing - https://api.themoviedb.org/3/movie/now_playing?api_key=9ed2ae3dea2dca625465fdb20da3429a&page=1
//
//    trending- https://api.themoviedb.org/3/trending/movie/week?api_key=9ed2ae3dea2dca625465fdb20da3429a&page=1
//
//    search- https://api.themoviedb.org/3/search/movie?api_key=9ed2ae3dea2dca625465fdb20da3429a&query=dead
//
//    details- https://api.themoviedb.org/3/movie/616037?api_key=9ed2ae3dea2dca625465fdb20da3429a


protocol MovieManagerDelegate{
    func didUpadateMovies(movies:MovieModal)
    func didFailWithError(error: Error)
}

struct MovieManager {
        //weak 
        var delegate : MovieManagerDelegate?

        let apiKeys = ApiKeys()
        
        let SEARCH_URL: String
        let TRENDING_URL: String
        let NOWPLAYING_URL: String
        var currentPage = 1
        
        init() {
            SEARCH_URL = "\(apiKeys.BASE_URL)search/movie?api_key=\(apiKeys.API_KYE)"
            TRENDING_URL = "\(apiKeys.BASE_URL)trending/movie/week?api_key=\(apiKeys.API_KYE)"
            NOWPLAYING_URL = "\(apiKeys.BASE_URL)movie/now_playing?api_key=\(apiKeys.API_KYE)"
        }
        
        
        func fetchSearchedMovies(movieName:String)
        {
            let query = movieName
            let url = "\(SEARCH_URL)&query=\(query)"
            performRequest(urlString: url)
        }
        
    mutating func fetchTrendingMovies(page: Int = 1)
        {
            currentPage = page
            performRequest(urlString: "\(TRENDING_URL)&page=\(currentPage)")
        }
    mutating func fetchNowPlayingMovies(page: Int = 1)
        {
            currentPage = page
            performRequest(urlString: "\(NOWPLAYING_URL)&page=\(currentPage)")
        }
        
        func performRequest(urlString :String)
        {
            if let url = URL(string: urlString){
                let session = URLSession(configuration: .default)
    //            let task = session.dataTask(with: url, completionHandler:handle(data:response:error:) )
                let task = session.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print(error)
                        self.delegate?.didFailWithError(error: error)
                        return
                    }
                   if let data = data {
                    do {
                        // Attempt to decode the data into a JSON object
//                        self.parsJSON(movieData: data)
                    
                        if let movies =  self.parsJSON(movieData: data){
                            self.delegate?.didUpadateMovies(movies:movies)
                        }

                        
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
//                        print("JSON Response: \(json)")
                    } catch {
                        self.delegate?.didFailWithError(error: error)
                        print("Failed to decode JSON: \(error)")
                    }
                   }
                }
                task.resume();
            }
        }
        
        func parsJSON(movieData: Data)-> MovieModal?
        {
            
            let decorder = JSONDecoder()
            do{
                
                let decodedData = try decorder.decode(MovieData.self, from: movieData);
                let results = decodedData.results
                
                let movieResults = results.map { result in
                           MovieResult(id: result.id, original_title: result.original_title, overview: result.overview, poster_path: result.poster_path)
                       }
                
                let moviesCount = decodedData.results.count
                            
                let movies = MovieModal(movieResults: movieResults, numberOfMovies: moviesCount)
                
                print("printing inside movieManger \(movies.numberOfMovies)")
                
                return movies
                
            }
            catch{
                print(error)
                self.delegate?.didFailWithError(error: error)  
                return nil
            }
        }

    }

//                for movies in movies.movieResults{
//                    print(movies.id)
//                    print("--------")
//                }
