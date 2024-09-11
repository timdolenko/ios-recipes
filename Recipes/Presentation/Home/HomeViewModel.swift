import Foundation

class HomeViewModel {

    private let repository: RecipeRepositoryProtocol

    var recipes: [Recipe] = []
    var showError: ((String) -> Void)?
    var didSelectRecipe: ((Recipe) -> Void)?

    init(repository: RecipeRepositoryProtocol) {
        self.repository = repository
    }

    func loadRecipes() async {
        do {
            let recipes = try await repository.fetchRecipes()
            self.recipes = recipes
        } catch {
            showError?("error.fetch-recipes".localized + " " + error.localizedDescription)
        }
    }

    func searchRecipes(query: String) async {
        do {
            guard !query.isEmpty else {
                await loadRecipes()
                return
            }

            let recipes = try await repository.search(with: query)
            self.recipes = recipes
        } catch {
            showError?("error.search-recipes".localized + " " + error.localizedDescription)
        }
    }
}
