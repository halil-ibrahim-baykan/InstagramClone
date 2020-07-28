//
//  PhotoSelectController.swift
//  InstagramCloneProject
//
//  Created by halil ibrahim baykan on 23/07/2020.
//  Copyright © 2020 halil ibrahim baykan. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectController: UICollectionViewController {
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var photosArr = [UIImage]()
    
    var selectedPhoto:UIImage?
    
    var assests  = [PHAsset]()
    
    var header : PhotoSelectHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        addButtons()
        fetchPhotos()
        collectionView.register(PhotoSelectCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(PhotoSelectHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
    }
    
    fileprivate func addButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonClicked))
    }
    // when you press it, it dismiss current view immediately
    @objc func cancelButtonClicked(){
        dismiss(animated: true, completion: nil)
    }
    @objc func nextButtonClicked(){
        let photoShareController = PhotoShareController()
        navigationController?.pushViewController(photoShareController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        selectedPhoto = photosArr[indexPath.row]
        collectionView.reloadData()
        let indexTop = IndexPath(item:0, section:0)
        collectionView.scrollToItem(at: indexTop, at: .bottom, animated: true)
    }
    
    fileprivate func fetchPhotosOptions()->PHFetchOptions{
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        
        let sortConfig = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortConfig]
        
        return fetchOptions
    }
    
    fileprivate func fetchPhotos(){
        
        let photos = PHAsset.fetchAssets(with: .image, options: fetchPhotosOptions())
        
        DispatchQueue.global(qos: .background).async {
            photos.enumerateObjects { (asset, number, stoppingPoint) in
                //asset: all photos comes in asset variable. it comes one by one. we limited them as 30 above
                //number: which photo fetching. it starts 0
                //stoppingPoint: keeps the info/address of stopping point
                print("\(number). photo fetching")
                let imageManager = PHImageManager.default()
                
                let imageSize = CGSize(width: 200, height: 200)
                
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: requestOptions) { (image, imageInfo) in
                    if let photo = image{
                        self.photosArr.append(photo)
                        
                        self.assests.append(asset)
                        
                        if self.selectedPhoto == nil{
                            self.selectedPhoto = image
                        }
                        
                    }
                    if number == photos.count - 1{
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
             
            }
        }
    
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectHeader
//        header.imgHeader.image = selectedPhoto
        
        self.header = header
        header.imgHeader.image = selectedPhoto
        
        if let selectedPhoto = selectedPhoto{
            if let index = self.photosArr.firstIndex(of: selectedPhoto){
                let selectedAsset = self.assests[index]
                
                let photoManager = PHImageManager()
                let size = CGSize(width: 600, height: 600)
                photoManager.requestImage(for: selectedAsset, targetSize: size, contentMode: .default, options: nil) { (photo, info) in
                    header.imgHeader.image = photo
                }
            }
        }
        return header
    }
    // it triggers to execute creating header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width * 0.8
        return CGSize(width: width, height: width)
    }
    // it uses for useally give some spaces inside of this item.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArr.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectCell
        cell.imgPhoto.image = photosArr[indexPath.row]
        return cell
    }
    // it doesn't work at first we need config navbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension UINavigationController{
    open override var childForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
}
extension PhotoSelectController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}