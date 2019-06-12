//
//  ContentView.swift
//  Dynamic Table
//
//  Created by Javier Angel Varela Cebey on 12/06/2019.
//  Copyright © 2019 Javier Angel Varela Cebey. All rights reserved.
//

import SwiftUI
import Combine

struct Photo: Decodable {
    let id: Int
    let title, url: String
}

class NetworkManager: BindableObject {
    var didChange = PassthroughSubject<NetworkManager, Never>()
    
    var photos = [Photo]() {
        didSet {
            didChange.send(self)
        }
    }
    
    init() {
        guard let url = URL(string: "https://javiervarela.github.io/docs/photos/") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            let photos = try! JSONDecoder().decode([Photo].self, from: data)
            
            DispatchQueue.main.async {
                self.photos = photos
            }
            
            print("JSON loaded")
        }.resume()
    }
}

struct ContentView : View {
    @State var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            List (networkManager.photos.identified(by: \.id)) { photo in
                PhotoRowView(photo: photo)
            }.navigationBarTitle(Text("Remote Photo List"))
        }
    }
}

struct PhotoRowView: View {
    let photo: Photo
    
    var body: some View {
        HStack {
            ImageViewWidget(url: photo.url)
            Text(photo.title)
        }
    }
}

class ImageLoader: BindableObject {
    var didChange = PassthroughSubject<Data, Never>()
    
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(url: String) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                self.data = data
            }
        }.resume()
    }
}

struct ImageViewWidget: View {
    @ObjectBinding var imageLoader: ImageLoader
    
    init(url: String) {
        imageLoader = ImageLoader(url: url)
    }
    
    var body: some View {
        Image(uiImage: (imageLoader.data.count == 0) ? UIImage(named: "descarga")! : UIImage(data: imageLoader.data)!)
            .resizable()
            .frame(width: 100, height: 100)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
