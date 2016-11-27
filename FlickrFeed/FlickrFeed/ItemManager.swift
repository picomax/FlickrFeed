//
//  ItemManager.swift
//  FlickrFeed
//
//  Created by picomax on 2016. 11. 27..
//  Copyright © 2016년 picomax. All rights reserved.
//

import Foundation

protocol ItemManagerDelegate {
    func itemCountChanged(count: Int)
}

let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"

class ItemManager {
    
    // MARK: - Properties
    private var imageItems = [ItemModel]()
    public var delegate: ItemManagerDelegate?
    
    // MARK: - Public Function
    public func start() {
        self.getList()
    }
    
    public func count() -> Int {
        return self.completeItems().count
    }
    /*
    public func getImage(index: Int) -> UIImage? {
        let completeItems = self.completeItems()
        
        guard index >= 0, index < completeItems.count else { return nil }
        
        let item = completeItems[index]
        
        guard let path = item.path else { return nil }
        
        return UIImage(contentsOfFile: path)
    }
    */
    public func getItemModel(index: Int) -> ItemModel? {
        let completeItems = self.completeItems()
        
        guard index >= 0, index < completeItems.count else { return nil }
        
        let item = completeItems[index]
        
        return item
    }
    
    // MARK: - Private Function
    private func completeItems() -> [ItemModel] {
        return self.imageItems.filter { (item) -> Bool in
            return item.isDownloadComplete
        }
    }
    
    private func getList() {
        guard let url = URL(string: urlString) else { return }
        
        self.imageItems.removeAll()
        self.delegate?.itemCountChanged(count: self.count())
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let dict = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? NSDictionary,
                let items = dict["items"] as? [NSDictionary]
                else { return }
            
            for item in items {
                if let media = item["media"] as? NSDictionary,
                    let m = media["m"] as? String,
                    let url = URL(string: m) {
                    
                    let imageItem = ItemModel(url: url)
                    self.imageItems.append(imageItem)
                }
            }
            
            self.downloadAllImages()
            }.resume()
    }
    
    private func downloadAllImages() {
        for imageItem in self.imageItems {
            self.downloadImage(item: imageItem)
        }
    }
    
    private func downloadImage(item: ItemModel) {
        let request = URLRequest(url: item.url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data, error == nil
                else { return }
            
            let path = self.getFilePath(url: item.url)
            
            if FileManager.default.fileExists(atPath: path) {
                try? FileManager.default.removeItem(atPath: path)
            }
            
            if FileManager.default.createFile(atPath: path, contents: data, attributes: [:]) {
                item.isDownloadComplete = true
                item.path = path
                
                DispatchQueue.main.async {
                    self.delegate?.itemCountChanged(count: self.count())
                }
            }
            }.resume()
    }
    
    private func getFilePath(url: URL) -> String {
        let fileName = url.lastPathComponent
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        return "\(documentsPath)/\(fileName)"
    }
}
