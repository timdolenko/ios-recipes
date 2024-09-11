import Foundation
import XCTest

@testable import Recipes

enum MockError: Error {
    case mock
}

class RecipeRepositoryMock: RecipeRepositoryProtocol {

    var fetchRecipesResult: [Recipe] = []
    var didFetchRecipes: Int = 0
    var shouldFetchRecipesFail: Bool = false

    func fetchRecipes() async throws -> [Recipes.Recipe] {
        didFetchRecipes += 1

        if shouldFetchRecipesFail {
            throw MockError.mock
        }

        return fetchRecipesResult
    }

    func fetchRecipe(id: String) async throws -> Recipes.RecipeDetail {
        RecipeDetail(id: "", name: "", imageUrl: "", description: "", ingredients: [])
    }

    var searchWithQueryResults: [Recipe] = []

    func search(with query: String) async throws -> [Recipes.Recipe] {
        return searchWithQueryResults
    }
}

extension Recipe {
    static var mock: Recipe {
        Recipe(id: "0", name: "Lemonade", imageUrl: "", duration: 10)
    }
}

class HomeViewModelTests: XCTestCase {

    private var viewModel: HomeViewModel!
    private var repository: RecipeRepositoryMock!

    override func setUp() async throws {
        try await super.setUp()

        repository = RecipeRepositoryMock()
        viewModel = HomeViewModel(repository: repository)
    }

    func test_whenFetchIsCalled_thenRepositoryFetchIsCalledAndDataIsSaved() async {
        // given
        let fetchResults = [Recipe.mock]
        repository.fetchRecipesResult = fetchResults

        // when
        await viewModel.loadRecipes()

        // then
        XCTAssertEqual(viewModel.recipes.count, fetchResults.count)
        XCTAssertEqual(repository.didFetchRecipes, 1)
    }

    func test_whenFetchFails_thenErrorIsShown() async {
        // given
        repository.shouldFetchRecipesFail = true

        let expectation = self.expectation(description: "error shown")
        var showErrorText: String?
        viewModel.showError = { text in
            expectation.fulfill()
            showErrorText = text
        }

        // when
        await viewModel.loadRecipes()

        // then
        await fulfillment(of: [expectation], timeout: 0.5)
        XCTAssertTrue(showErrorText!.contains("error.fetch-recipes".localized))
    }
}
