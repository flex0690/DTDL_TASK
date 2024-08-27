import UIKit

class SecondScreenViewController: UIViewController {

    @IBOutlet weak var moiveImage: UIImageView!
    @IBOutlet weak var moiveTitle: UILabel!
    @IBOutlet weak var movieLable: UILabel!

    var MovieTitle: String?
    var MovieUrl: String?
    var MovieLable: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let title = MovieTitle, let url = MovieUrl, let label = MovieLable {
                    moiveTitle.text = title
                    movieLable.text = label
                    loadImage(from: url)
                } else {
                    print("Error: Data not passed correctly.")
                    // Optionally, you can show an error message or a placeholder
                }
    }
    
    func setupUI() {
           // Set background color
           view.backgroundColor = UIColor.systemBackground
           
           // Customize movie image view
           moiveImage.layer.borderColor = UIColor.lightGray.cgColor
           moiveImage.layer.borderWidth = 1
           
           // Add shadow to movie image view
           moiveImage.layer.shadowColor = UIColor.black.cgColor
           moiveImage.layer.shadowOpacity = 0.25
           moiveImage.layer.shadowOffset = CGSize(width: 0, height: 2)
           moiveImage.layer.shadowRadius = 5
           moiveImage.layer.masksToBounds = false

           // Customize title label
           moiveTitle.font = UIFont.boldSystemFont(ofSize: 24)
           moiveTitle.textColor = UIColor.label
           moiveTitle.textAlignment = .center

           // Customize movie label
           movieLable.font = UIFont.systemFont(ofSize: 16)
           movieLable.textColor = UIColor.secondaryLabel
           movieLable.numberOfLines = 0
           movieLable.lineBreakMode = .byWordWrapping
           
           
           NSLayoutConstraint.activate([
               moiveTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
               moiveTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
               movieLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
               movieLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
           ])
       }
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return
        }
        // Start an asynchronous task to download the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors and ensure we have data
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("No image data or failed to convert data to UIImage.")
                return
            }
            // Update the UIImageView on the main thread
            DispatchQueue.main.async {
                self.moiveImage.image = image
            }
        }.resume()
    }
}

//    var MovieTitle = "Demo Title"
//    var MovieUrl = "https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg"
//    var MovieLable  = "Demo Lable"
