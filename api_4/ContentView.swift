import SwiftUI

struct Article: Identifiable, Decodable {
    let id: Int
    let name: String
    let price: Int
//    let image: String
}

class ArticleViewModel: ObservableObject {
    @Published var articles: [Article] = []

    init() {
        fetchData()
    }

    func fetchData() {
        guard let url = URL(string: "https://8739-5-144-118-1.ngrok-free.app/api/games/") else {
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

struct ContentView: View {
    @ObservedObject var viewModel = ArticleViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.articles) { article in
                NavigationLink(destination: ArticleDetail(article: article)) {
                    VStack(alignment: .leading) {
                        Text("ID: \(article.id)")
                            .font(.headline)
                        Text("Text: \(article.name)")
                            .font(.subheadline)
                        Text("Like Count: \(article.price)")
                            .font(.subheadline)
                    }
                }
            }
            .navigationBarTitle("Article List")
        }
    }
}

struct ArticleDetail: View {
    let article: Article

    var body: some View {
        VStack {
            Text("ID: \(article.id)")
                .font(.headline)
            Text("Text: \(article.name)")
                .font(.subheadline)
            Text("Like Count: \(article.price)")
                .font(.subheadline)
        }
        .navigationBarTitle("Article Detail")
    }
}

