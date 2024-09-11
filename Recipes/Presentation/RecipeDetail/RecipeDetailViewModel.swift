import UIKit

class RecipeDetailViewModel {
    var recipeDetail: RecipeDetail?
    var showError: ((String) -> Void)?
    var isRecipeBookmarked = false

    private let repository: RecipeRepositoryProtocol
    private let bookmarkRepository: BookmarkRepositoryProtocol
    private let id: String

    init(id: String, container: DependencyContainer) {
        self.id = id
        self.repository = container.recipeRepository
        self.bookmarkRepository = container.bookmarkRepository
    }

    func loadRecipeDetail() async {
        do {
            let recipeDetail = try await repository.fetchRecipe(id: id)
            let isRecipeBookmarked = bookmarkRepository.isRecipeBookmarked(id: id)
            await MainActor.run {
                self.recipeDetail = recipeDetail
                self.isRecipeBookmarked = isRecipeBookmarked
            }
        } catch {
            showError?("\("error.fetch-recipe-detail".localized) \(error.localizedDescription)")
        }
    }

    func toggleBookmark() {
        if isRecipeBookmarked {
            bookmarkRepository.unbookmarkRecipe(id: id)
        } else {
            bookmarkRepository.bookmarkRecipe(id: id)
        }

        isRecipeBookmarked.toggle()
    }
}
