//
//  ViewController.swift
//  navigation_controller
//
//  Created by Tarun Kumar on 22/08/24.
//

import UIKit

struct movieElements{
    let ID : Int
    let Movie_Title :String
    let Movie_Discription:String
    let Movie_Image:String
}
class ViewController: UIViewController {
    
    var RenderMovies:[movieElements] = []
    var trendingMovies: [movieElements] = []
    var nowPlayingMovies: [movieElements] = []
    var searchResults: [movieElements] = []

    var currentPageTrending = 1
    var currentPageNowPlaying = 1
    var isFetchingMoreMovies = false
    var currentTab: Tab = .trending

    enum Tab {
            case trending
            case nowPlaying
            case search
        }

    var MovieTitle:String?
    var MovieUrl:String?
    var MovieLable:String?

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var SearchBar: UISearchBar!

    @IBOutlet weak var trendingBar: UITabBarItem!
    
    @IBOutlet weak var nowPlayingBar: UITabBarItem!
    
    @IBOutlet weak var myTabBar: UITabBar!
    
    var movieManager = MovieManager()
    
//MARK: - Main function
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        movieManager.delegate = self
        myTabBar.delegate = self
        SearchBar.delegate = self
        
        loadMovies(for: .trending, page: currentPageTrending)

    }
    
    func loadMovies(for tab: Tab, page: Int) {
            switch tab {
            case .trending:
                movieManager.fetchTrendingMovies(page: page)
            case .nowPlaying:
                movieManager.fetchNowPlayingMovies(page: page)
            case .search:
                // Do nothing; search results are handled separately
                break
            }
        }
}

//MARK: - UI COLLECIOION DATASOURCE
extension ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        RenderMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let imageUrl = "https://image.tmdb.org/t/p/w500/\(RenderMovies[indexPath.row].Movie_Image).jpg"
        
        cell.configure(with: RenderMovies[indexPath.row].Movie_Title, discription: RenderMovies[indexPath.row].Movie_Discription,imageUrl: imageUrl)
        return cell;
      
    }
}

//MARK: - UI COLLECTION FLOWLAYOUT
extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height:120)
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard currentTab != .search else { return }  // Prevent pagination during search
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            if !isFetchingMoreMovies {
                isFetchingMoreMovies = true
                switch currentTab {
                case .trending:
                    currentPageTrending += 1
                    loadMovies(for: .trending, page: currentPageTrending)
                case .nowPlaying:
                    currentPageNowPlaying += 1
                    loadMovies(for: .nowPlaying, page: currentPageNowPlaying)
                case .search:
                    break
                }
            }
        }
    }


}

//MARK: - UI WEB VIEW DELEGATE
extension ViewController:UIWebViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        MovieTitle = RenderMovies[indexPath.row].Movie_Title
        MovieLable = RenderMovies[indexPath.row].Movie_Discription
        MovieUrl = "https://image.tmdb.org/t/p/w500/\(RenderMovies[indexPath.row].Movie_Image).jpg"
        performSegue(withIdentifier: "toDetailVC", sender: nil)
        
        print(RenderMovies[indexPath.row].Movie_Title);
    }
}
//MARK: - SEARCH BAR
extension  ViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print(searchBar.text)
        if let searchedMovie = searchBar.text {
               currentTab = .search
               movieManager.fetchSearchedMovies(movieName: searchedMovie)
           }
           searchBar.resignFirstResponder()
        
    }
    
}
//MARK: - TAB BAR
extension ViewController:UITabBarDelegate{
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.title == "Trending" {
                   currentTab = .trending
                   if trendingMovies.isEmpty {
                       loadMovies(for: .trending, page: currentPageTrending)
                   } else {
                       RenderMovies = trendingMovies
                       collectionView.reloadData()
                   }
        } else if item.title == "Now Playing" {
                   currentTab = .nowPlaying
                   if nowPlayingMovies.isEmpty {
                       loadMovies(for: .nowPlaying, page: currentPageNowPlaying)
                   } else {
                       RenderMovies = nowPlayingMovies
                       collectionView.reloadData()
                   }
               }
    }

}
//MARK: - MOVIE MANAGER
extension ViewController : MovieManagerDelegate{
    func didFailWithError(error: Error) {
        func didFailWithError(error: Error) {
            print("error : \(error)")
        }
    }
    
    func didUpadateMovies(movies: MovieModal) {
        DispatchQueue.main.async {
            print("movies in viewcontroller \(movies.numberOfMovies)")
            
            let newMovies = movies.movieResults.map { movieResult in
                            movieElements(
                                ID: movieResult.id,
                                Movie_Title: movieResult.original_title,
                                Movie_Discription: movieResult.overview,
                                Movie_Image: movieResult.poster_path
                            )
                        }
                        
                        switch self.currentTab {
                        case .trending:
                            self.trendingMovies.append(contentsOf: newMovies)
                            self.RenderMovies = self.trendingMovies
                        case .nowPlaying:
                            self.nowPlayingMovies.append(contentsOf: newMovies)
                            self.RenderMovies = self.nowPlayingMovies
                        case .search:
                            self.searchResults = newMovies
                            self.RenderMovies = self.searchResults
                        }
                        self.collectionView.reloadData()
                        self.isFetchingMoreMovies = false
                    }
        func didFailWithError(error: Error) {
                print("Error: \(error)")
                self.isFetchingMoreMovies = false
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue)
        if segue.identifier == "toDetailVC"
        {
            let destinationVC = segue.destination as! SecondScreenViewController
            destinationVC.MovieTitle = MovieTitle
            destinationVC.MovieLable = MovieLable
            destinationVC.MovieUrl = MovieUrl
            
        }
    }
}

//extension ViewController: MovieManagerDelegate {
//    func didUpadateMovies(movies: MovieModal) {
//        DispatchQueue.main.async {

//            self.RenderMovies = movies.movieResults.map { movieResult in
//                                return movieElements(
//                                    ID: movieResult.id,
//                                    Movie_Title: movieResult.original_title,
//                                    Movie_Discription: movieResult.overview,
//                                    Movie_Image: movieResult.poster_path
//                                )
//                            }
//                    self.collectionView.reloadData()
//            }
//            let newMovies = movies.movieResults.map { movieResult in
//                movieElements(ID: movieResult.id, Movie_Title: movieResult.original_title, Movie_Discription: movieResult.overview, Movie_Image: movieResult.poster_path)
//            }
//            self.RenderMovies.append(contentsOf: newMovies)
//            self.collectionView.reloadData()
//            self.isFetchingMoreMovies = false
//        }
//    }
//
//    func didFailWithError(error: Error) {
//        print("Error: \(error)")
//        self.isFetchingMoreMovies = false
//    }
//}



//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            let offsetY = scrollView.contentOffset.y
//            let contentHeight = scrollView.contentSize.height
//            let height = scrollView.frame.size.height
//
//            if offsetY > contentHeight - height {
//                if !isFetchingMoreMovies {
//                    isFetchingMoreMovies = true
//                    currentPage += 1
//                    movieManager.fetchTrendingMovies(page: currentPage)
//                }
//            }
//        }


//        if item.title == "Trending" {
//            movieManager.fetchTrendingMovies(page: 1);
//        }
//        else
//        {
//            movieManager.fetchNowPlayingMovies(page: 1)
//        }
