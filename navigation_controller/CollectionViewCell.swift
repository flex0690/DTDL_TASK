import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var MovieImage: UIImageView!
    @IBOutlet weak var MovieTitle: UILabel!
    @IBOutlet weak var MovieDiscription: UILabel!

    @IBOutlet weak var MovieDiscriptionLable: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func setupUI() {
        // Cell Styling
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 8
        self.layer.masksToBounds = false

        // Image Styling
//        MovieImage.layer.cornerRadius = 10
//        MovieImage.clipsToBounds = true

        // Title Styling
        MovieTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        MovieTitle.textColor = UIColor.black
    }

    func configure(with title: String,discription:String, imageUrl: String) {
        MovieTitle.text = title
        
        // Load image from URL
        if let url = URL(string: imageUrl) {
            downloadImage(from: url)
        }
        MovieDiscription.text = discription
    }

    private func downloadImage(from url: URL) {
        // Fetch the image data asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image data.")
                return
            }

            // Update UIImageView on the main thread
            DispatchQueue.main.async {
                self.MovieImage.image = image
            }
        }.resume()
    }
}
