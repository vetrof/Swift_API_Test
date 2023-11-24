import SwiftUI

struct Article: Identifiable, Decodable {
    //MARK: - struct
    let id: Int
    let title: String
    let image_cover: String
    let text: String
//    let like_count: Int
    
}

class ArticleViewModel: ObservableObject {
    @Published var articles: [Article] = []

    init() {
        fetchData()
    }

    func fetchData() {
        
        //MARK: - API URL
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/article_list/") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([Article].self, from: data)
                DispatchQueue.main.async {
                    self.articles = decodedData
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
//ListView
//MARK: - List view variable
struct ContentView: View {
    @ObservedObject var viewModel = ArticleViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.articles) { article in
                NavigationLink(destination: ArticleDetail(article: article)) {
                    ArticleTile(article: article)
                }
            }
            .navigationBarTitle("Article List")
        }
    }
}


import SwiftUI
import UIKit

struct HTMLTextView: UIViewRepresentable {
    var htmlString: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            if let attributedString = htmlString.htmlToAttributedString {
                uiView.attributedText = attributedString
            } else {
                uiView.text = htmlString
            }
        }
    }
}

struct ArticleTile: View {
    let article: Article
    @State private var imageData: Data? = nil

    var body: some View {
        HStack(spacing: 16) {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 150)
                    .clipped()
            } else {
                Text("Loading Image...")
                    .frame(width: 200, height: 200)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(article.title)")
                    .font(.headline)

                HTMLTextView(htmlString: article.text)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxHeight: .infinity)
            }
        }
        .padding()
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = URL(string: article.image_cover) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }

}

// Метод для конвертации HTML в NSAttributedString
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}





//DetailView
struct ArticleDetail: View {
    let article: Article
    @State private var imageData: Data? = nil

    var body: some View {
        VStack {

            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            } else {
                Text("Loading Image...")
            }
            
            //MARK: - Detail view variable
            
            Text("ID: \(article.id)").font(.headline)
            
            HTMLTextView(htmlString: article.text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxHeight: .infinity)
            
            Spacer() // Добавленный Spacer для размещения содержимого внизу
        }
        .navigationBarTitle("\(article.title)")
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let url = URL(string: article.image_cover) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

