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
struct ContentView: View {
    @ObservedObject var viewModel = ArticleViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.articles) { article in
                NavigationLink(destination: ArticleDetail(article: article)) {
                    VStack(alignment: .leading) {
                        
                        //MARK: - List view variable
                        
                        Text("\(article.id). \(article.title)")
                            .font(.headline)
//                        Text("\(article.like_count) Like")
//                            .font(.subheadline)
//                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarTitle("Article List")
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
            Text("\(article.text)").font(.subheadline)
//            Text("Like Count=\(article.like_count)").font(.headline)
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

