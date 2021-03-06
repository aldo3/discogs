//
//  ViewController.swift
//  MyVinylCollection
//
//  Created by Antoine Proux on 03/06/2019.
//  Copyright © 2019 Antoine Proux. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON

class HomeViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    // FOR DESIGN
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userMemberDateLabel: UILabel!
    
    @IBOutlet weak var userSellerRateLabel: UILabel!
    @IBOutlet weak var userBuyerRateLabel: UILabel!
    
    @IBOutlet weak var starOneSellerImageView: UIImageView!
    @IBOutlet weak var starTwoSellerImageView: UIImageView!
    @IBOutlet weak var starThreeSellerImageView: UIImageView!
    @IBOutlet weak var starFourSellerImageView: UIImageView!
    @IBOutlet weak var starFiveSellerImageView: UIImageView!
    @IBOutlet weak var starOneBuyerImageView: UIImageView!
    @IBOutlet weak var starTwoBuyerImageView: UIImageView!
    @IBOutlet weak var starThreeBuyerImageView: UIImageView!
    @IBOutlet weak var starFourBuyerImageView: UIImageView!
    @IBOutlet weak var starFiveBuyerImageView: UIImageView!
    
    @IBOutlet weak var minCollectionValueLabel: UILabel!
    @IBOutlet weak var medCollectionValueLabel: UILabel!
    @IBOutlet weak var maxCollectionValueLabel: UILabel!
    
    @IBOutlet weak var collectionCountLabel: UILabel!
    @IBOutlet weak var wantlistCountLabel: UILabel!
    
    @IBOutlet weak var collectionCollectionView: UICollectionView!
    @IBOutlet weak var wantlistCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionSegueButton: UIButton!
    @IBOutlet weak var wantlistSegueButton: UIButton!
    
    // FOR DATA
    var userCollection: [Album] = []
    var wantlistCollection: [Album] = []
    var albumClicked: Album! = nil
    
    
    var userInfo: [String: Any] = [:]
    // userInfoKey
    let userPseudoKey = "userPseudoKey"
    let memberDateKey = "memberDateKey"
    let userAvatarKey = "userAvatarKey"
    let sellerRatingPourcentageKey = "sellerRatingPourcentageKey"
    let buyerRatingPourcentageKey = "buyerRatingPourcentageKey"
    let sellerRatingKey = "sellerRatingKey"
    let buyerRatingKey = "buyerRatingKey"
    let sellerStarsNumberKey = "sellerStarsNumberKey"
    let buyerStarsNumberKey = "buyerStarsNumberKey"
    let collectionCountKey = "collectionCountKey"
    let wantlistCountKey = "wantlistCountKey"
    // Static var
    enum CollectionType: Int {
        case collection = 0
        case wantlist = 1
    }
    typealias FinishedDownload = () -> ()
    let HomeCollectionViewCellIdentifier = "HomeCollectionViewCell"
    // Segue Id
    let toAlbumDetailSegueIdentifier = "toAlbumDetailSegue"
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        
        collectionCollectionView.dataSource = self
        collectionCollectionView.delegate = self
        let collectionLayout = collectionCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        collectionLayout.scrollDirection = .horizontal
        let wantlistLayout = wantlistCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        wantlistLayout.scrollDirection = .horizontal
        wantlistCollectionView.dataSource = self
        wantlistCollectionView.delegate = self
        
        getUserInformation()
        getUserCollections(type: CollectionType.collection.rawValue)
        getUserCollections(type: CollectionType.wantlist.rawValue)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-30)
    }
    
    
// MARK: - SetUpViews
    func refreshAllViews(){
        refreshCollectionViews()
        setUpUserInformations()
        setUpCollectionsUpperViews()
    }
    
    func refreshCollectionViews(){
        collectionCollectionView.reloadData()
        wantlistCollectionView.reloadData()
    }
    
    func setUpUserInformations(){
        userNameLabel.text = userInfo[self.userPseudoKey] as? String
        let st = userInfo[self.memberDateKey] as? String ?? "2019-01-07"
        let dateSt = st.prefix(10)
        let memberDateFormated = "Member since : " + dateSt
        userMemberDateLabel.text = memberDateFormated
        let sellerStarsCountD = userInfo[self.sellerStarsNumberKey] as? Double
        let sellerStarsCount = Int(sellerStarsCountD!)
        let buyerStarsCountD = userInfo[self.buyerStarsNumberKey] as? Double
        let buyerStarsCount = Int(buyerStarsCountD!)
        setUpUserStars(sellerCount: sellerStarsCount, buyerCount: buyerStarsCount)
        let sellRatPourc = userInfo[self.sellerRatingPourcentageKey] as? Double ?? 0.0
        let sellRat = userInfo[self.sellerRatingKey] as? Int ?? 0
        let sellerRatingString = String(sellRatPourc) + "% (" + String(sellRat) + " ratings)"
        let buyRatPourc = userInfo[self.buyerRatingPourcentageKey] as? Double ?? 0.0
        let buyRat = userInfo[self.buyerRatingKey] as? Int ?? 0
        let buyerRatingString = String(buyRatPourc) + "% (" + String(buyRat) + " ratings)"
        userSellerRateLabel.text = sellerRatingString
        userBuyerRateLabel.text = buyerRatingString
    }
    
    func setUpCollectionsUpperViews(){
        let collecCount = userInfo[collectionCountKey] as? Int ?? 0
        collectionCountLabel.text = "View all " +  String(collecCount)
        let wantlistCount = userInfo[wantlistCountKey] as? Int ?? 0
        wantlistCountLabel.text = "View all " +  String(wantlistCount)
    }
    
    func setUpUserStars(sellerCount: Int, buyerCount: Int){
        let starIn = "starYellowIcon"
        let starOut = "starGreyIcon"
        
        starOneSellerImageView.image = UIImage(named: starOut)
        starTwoSellerImageView.image = UIImage(named: starOut)
        starThreeSellerImageView.image = UIImage(named: starOut)
        starFourSellerImageView.image = UIImage(named: starOut)
        starFiveSellerImageView.image = UIImage(named: starOut)
        starOneBuyerImageView.image = UIImage(named: starOut)
        starTwoBuyerImageView.image = UIImage(named: starOut)
        starThreeBuyerImageView.image = UIImage(named: starOut)
        starFourBuyerImageView.image = UIImage(named: starOut)
        starFiveBuyerImageView.image = UIImage(named: starOut)
        
        switch sellerCount {
        case 5:
           starOneSellerImageView.image = UIImage(named: starIn)
           starTwoSellerImageView.image = UIImage(named: starIn)
           starThreeSellerImageView.image = UIImage(named: starIn)
           starFourSellerImageView.image = UIImage(named: starIn)
           starFiveSellerImageView.image = UIImage(named: starIn)
            break
        case 4:
            starOneSellerImageView.image = UIImage(named: starIn)
            starTwoSellerImageView.image = UIImage(named: starIn)
            starThreeSellerImageView.image = UIImage(named: starIn)
            starFourSellerImageView.image = UIImage(named: starIn)
            break
        case 3:
            starOneSellerImageView.image = UIImage(named: starIn)
            starTwoSellerImageView.image = UIImage(named: starIn)
            starThreeSellerImageView.image = UIImage(named: starIn)
            break
        case 2:
            starOneSellerImageView.image = UIImage(named: starIn)
            starTwoSellerImageView.image = UIImage(named: starIn)
            break
        case 1:
            starOneSellerImageView.image = UIImage(named: starIn)
            break
        default:
            break
        }
        
        switch buyerCount {
        case 5:
            starOneBuyerImageView.image = UIImage(named: starIn)
            starTwoBuyerImageView.image = UIImage(named: starIn)
            starThreeBuyerImageView.image = UIImage(named: starIn)
            starFourBuyerImageView.image = UIImage(named: starIn)
            starFiveBuyerImageView.image = UIImage(named: starIn)
            break
        case 4:
            starOneBuyerImageView.image = UIImage(named: starIn)
            starTwoBuyerImageView.image = UIImage(named: starIn)
            starThreeBuyerImageView.image = UIImage(named: starIn)
            starFourBuyerImageView.image = UIImage(named: starIn)
            break
        case 3:
            starOneBuyerImageView.image = UIImage(named: starIn)
            starTwoBuyerImageView.image = UIImage(named: starIn)
            starThreeBuyerImageView.image = UIImage(named: starIn)
            break
        case 2:
            starOneBuyerImageView.image = UIImage(named: starIn)
            starTwoBuyerImageView.image = UIImage(named: starIn)
            break
        case 1:
            starOneBuyerImageView.image = UIImage(named: starIn)
            break
        default:
            break
        }
    }
    
    
    // MARK: - CollectionViews Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionCollectionView {
            return 1
        } else if (collectionView == self.wantlistCollectionView) {
            return 1
        } else {
            return 0
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionCollectionView {
            if userCollection.count > 9 {
                return 10
            } else {
                return userCollection.count
            }
        } else if (collectionView == self.wantlistCollectionView) {
            if wantlistCollection.count > 9 {
                return 10
            } else {
                return wantlistCollection.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: homeCollectionViewCell!
        cell = (collectionView == self.collectionCollectionView) ?
            (self.collectionCollectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCellIdentifier, for: indexPath) as! homeCollectionViewCell)
            : (self.wantlistCollectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCellIdentifier, for: indexPath) as! homeCollectionViewCell)
        
        if (collectionView == self.collectionCollectionView){
            cell.albumTitleLabel.text = userCollection[indexPath.row].albumName
            cell.albumArtistLabel.text = userCollection[indexPath.row].artistsName
            if let urlSt = userCollection[indexPath.row].imageSmall {
                if let imageURL = URL(string: urlSt), let placeholder = UIImage(named: "platinIcon") {
                    cell.albumCoverImageView.af_setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
                }
            }
        } else if (collectionView == self.wantlistCollectionView) {
            cell.wAlbumTitleLabel.text = wantlistCollection[indexPath.row].albumName
            cell.wAlbumArtistLabel.text = wantlistCollection[indexPath.row].artistsName
            if let urlSt = wantlistCollection[indexPath.row].imageSmall {
                if let imageURL = URL(string: urlSt), let placeholder = UIImage(named: "platinIcon") {
                    cell.wAlbumCoverImageView.af_setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
                }
            }
        }
          return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        albumClicked = (collectionView == self.collectionCollectionView) ? userCollection[indexPath.row] : wantlistCollection[indexPath.row]
        let cell: homeCollectionViewCell!
        if (collectionView == self.collectionCollectionView){
            cell  = collectionCollectionView.cellForItem(at: indexPath) as? homeCollectionViewCell
        } else {
            cell = wantlistCollectionView.cellForItem(at: indexPath) as? homeCollectionViewCell
        }
        selectedImageView = cell.albumCoverImageView
        
        performSegue(withIdentifier: toAlbumDetailSegueIdentifier, sender: self)
    }
    
    
    // MARK: - Navigators
    
    @IBAction func toCollectionViewControllerButtonClicked(_ sender: Any) {
        tabBarController?.selectedIndex = 1
        //performSegue(withIdentifier: toCollectionVCSegueIdentifier, sender: self)
    }
    
    @IBAction func toWantlistViewControllerButtonClicked(_ sender: Any) {
        tabBarController?.selectedIndex = 2
        //performSegue(withIdentifier: toWantlistVCSegueIdentifier, sender: self)
    }
    
    
    @IBAction func toSearchBarCodeButtonClicked(_ sender: Any) {
        tabBarController?.selectedIndex = 3
    }
    
    // MARK: - Navigators
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case toAlbumDetailSegueIdentifier:
            if let albumDetailVC = segue.destination as? AlbumDetailViewController{
                albumDetailVC.album = albumClicked
                albumDetailVC.largeImageView = selectedImageView
            }
            break
        default:
            break
        }
    }
        
    
    // MARK: - Discogs Request
    func refreshCollectionAlbumList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let typePredicate = NSPredicate(format: "albumInCollection = %@", "true")
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        fetchRequest.predicate = typePredicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            userCollection = try context.fetch(fetchRequest) as! [Album]
        } catch {
            print("Context could not send data")
        }
        refreshAllViews()
    }
    
    func refreshWantlistAlbumList(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let typePredicate = NSPredicate(format: "albumInCollection = %@", "false")
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        fetchRequest.predicate = typePredicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            wantlistCollection = try context.fetch(fetchRequest) as! [Album]
        } catch {
            print("Context could not send data")
        }
        refreshAllViews()
    }
    
    
    func getUserCollections(type: Int) {
        
        
        let discogsUserCollectionURL = (type == CollectionType.collection.rawValue) ? DISCOGS_USER_COLLECTION_URL : DISCOGS_USER_WANTLIST_URL
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
        
//          var allPagesIsDone: Bool = false
          var pageNumber: Int = 1
        
        //repeat {
            let url = discogsUserCollectionURL + String(pageNumber) + "&per_page=100" + DISCOGS_KEY_SECRET_FORMAT
        Alamofire.request(url)
            .responseJSON { response in
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /todos/1")
                    print(response.result.error!)
                    return
                }
                
                // make sure we got some JSON since that's what we expect
                guard let albumsJsonArray = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    return
                }
                
//                if let pagination = albumsJsonArray["pagination"] as? [String: Any] {
//                    if let numberOfPage = pagination["pages"] as? Int {
//                        if (pageNumber == numberOfPage) {
//                            allPagesIsDone = true
//                        } else {
//                            pageNumber += 1
//                        }
//                    }
//                }
                
                let arrayGroupName = (type == CollectionType.collection.rawValue) ? "releases" : "wants"
                if let releases = albumsJsonArray[arrayGroupName] as? [[String: Any]] {
                    
                    for release in releases {
                        guard let albumId = release["id"] as? Int else {
                            continue
                        }
                        
                        var album = self.albumAlreadyExists(listType: type, id: String(albumId))
                        if album == nil {
                            album = NSManagedObject(entity: entity!, insertInto: context) as? Album
                            album?.id = String(albumId)
                        }
                        // AlbumList
                        album?.albumInCollection = (type == CollectionType.collection.rawValue) ? "true" : "false"
                        // Date Added
                        if let date = release["date_added"] as? String {
                            album?.dateAdded = date
                        }
                        // Gp : Basic Info
                        if let info = release["basic_information"] as? [String: Any]{
                            // Album name
                            if let title = info["title"] as? String {
                                album?.albumName = title
                            }
                            // Gp Artists
                            if let artists = info["artists"] as? [[String: Any]]{
                                if let artistName = artists[0]["name"] as? String {
                                    album?.artistsName = artistName
                                }
                                if let artistId = artists[0]["id"] as? Int {
                                    album?.artistsId = String(artistId)
                                }
                            }
                            // Gp Label
                            if let labels = info["labels"] as? [[String: Any]]{
                                if let labelName = labels[0]["name"] as? String {
                                    album?.labelName = labelName
                                }
                            } 
                            // Album year
                            if let year = info["year"] as? Int {
                                album?.year = String(year)
                            }
                            // Image album
                            if let image = info["cover_image"] as? String {
                                album?.image = image
                            }
                            // Small Image album
                            if let imageSmall = info["thumb"] as? String {
                                album?.imageSmall = imageSmall
                            }
                            // Gp : Format:
                            if let formats = info["formats"] as? [String: Any]{
                                if let formatName = formats["name"] as? String {
                                    album?.formatsName = formatName
                                }
                            }
                            // Track url
                            if let tracksURL = info["resource_url"] as? String {
                                album?.tracksURL = tracksURL
                            }
                        }
                    }
                }
                do {
                    try context.save()
                } catch {
                    print("context could not save data")
                }
                
                if (type == CollectionType.collection.rawValue) {
                    self.refreshCollectionAlbumList()
                } else {
                    self.refreshWantlistAlbumList()
                }
            }
        //}while allPagesIsDone
            
        
    }
    
    func albumAlreadyExists(listType: Int, id: String) -> Album?{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let idPredicate = NSPredicate(format: "id == %@", id)
        let listTypeBool: String = (listType == CollectionType.collection.rawValue) ? "true" : "false"
        let typePredicate = NSPredicate(format: "albumInCollection = %@", listTypeBool)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [idPredicate, typePredicate])
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        fetchRequest.predicate = andPredicate
        
        
        if (listType == CollectionType.collection.rawValue) {
            do {
                userCollection = try context.fetch(fetchRequest) as! [Album]
                
                if (userCollection.count > 0){
                    return userCollection.first
                }
            } catch {
                print("context could not save data")
            }
            return nil
        } else {
            do {
                wantlistCollection = try context.fetch(fetchRequest) as! [Album]
                
                if (wantlistCollection.count > 0){
                    return wantlistCollection.first
                }
            } catch {
                print("context could not save data")
            }
            return nil
        }
    }
    
    

    func getUserInformation() {
        
        let userInfoURL = DISCOGS_USER_INFORMATION
        
        Alamofire.request(userInfoURL)
            .responseJSON { response in
                
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /todos/1")
                    print(response.result.error!)
                    return
                }
                
                // make sure we got some JSON since that's what we expect
                guard let userInfoJsonArray = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    return
                }
                if let memberDate = userInfoJsonArray["registered"] as? String {
                    self.userInfo[self.memberDateKey] = memberDate
                }
                if let userPseudo = userInfoJsonArray["username"] as? String {
                    self.userInfo[self.userPseudoKey] = userPseudo
                }
                if let userAvatar = userInfoJsonArray["avatar_url"] as? String {
                    self.userInfo[self.userAvatarKey] = userAvatar
                }
                if let sellerRatingPourcentage = userInfoJsonArray["seller_rating"] as? Double {
                    self.userInfo[self.sellerRatingPourcentageKey] = sellerRatingPourcentage
                }
                if let buyerRatingPourcentage = userInfoJsonArray["buyer_rating"] as? Double {
                    self.userInfo[self.buyerRatingPourcentageKey] = buyerRatingPourcentage
                }
                if let sellerRating = userInfoJsonArray["seller_num_rating"] as? Int {
                    self.userInfo[self.sellerRatingKey] = sellerRating
                }
                if let buyerRating = userInfoJsonArray["buyer_num_ratings"] as? Int {
                    self.userInfo[self.buyerRatingKey] = buyerRating
                }
                if let sellerStarsNumber = userInfoJsonArray["seller_rating_stars"] as? Double {
                    self.userInfo[self.sellerStarsNumberKey] = sellerStarsNumber
                }
                if let buyerStarsNumber = userInfoJsonArray["buyer_rating_stars"] as? Double {
                    self.userInfo[self.buyerStarsNumberKey] = buyerStarsNumber
                }
                if let collectionCount = userInfoJsonArray["num_collection"] as? Int {
                    self.userInfo[self.collectionCountKey] = collectionCount
                }
                if let wantlistCount = userInfoJsonArray["num_wantlist"] as? Int {
                    self.userInfo[self.wantlistCountKey] = wantlistCount
                }
        }
    }
}

