//
//  ViewController.swift
//  TechTestLeonardoJose
//
//  Created by Leonardo Jose Gunawan on 22/05/24.
//

import UIKit

class CRUDViewController: UIViewController {
    
    var images = [ImgurImage]()
    let imgurAPI = ImgurAPI()
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgurAPI.fetchImages { [weak self] fetchedImages in
            DispatchQueue.main.async {
                if let fetchedImages = fetchedImages {
                    self?.images = fetchedImages
                    self?.collectionView.reloadData()
                }
            }
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
}

extension CRUDViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height * 0.8))
        imageView.contentMode = .scaleAspectFit
        cell.contentView.addSubview(imageView)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: cell.contentView.bounds.height * 0.8, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height * 0.2))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.text = images[indexPath.item].title
        cell.contentView.addSubview(titleLabel)
        
        let imageUrl = URL(string: images[indexPath.item].link)!
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Error creating image from data")
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
}

