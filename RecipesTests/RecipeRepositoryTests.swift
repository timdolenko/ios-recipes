import Foundation
import XCTest

@testable import Recipes

class LocalRecipeDataSourceMock: LocalRecipeDataSourceProtocol {

    var fetchRecipesResult: [RecipeDTO] = []

    func fetchRecipes() throws -> [Recipes.RecipeDTO] {
        return fetchRecipesResult
    }

    func fetchRecipe(with id: String) throws -> Recipes.RecipeDetailDTO {
        RecipeDetailDTO(id: "", name: "", imageUrl: "", description: "", ingredients: [])
    }
}

class RecipeRepositoryTests: XCTestCase {
    
    var dataSource: LocalRecipeDataSourceMock!
    var repository: RecipeRepository!

    override func setUp() async throws {
        try await super.setUp()

        dataSource = LocalRecipeDataSourceMock()
        repository = RecipeRepository(dataSource: dataSource)
    }

    func test_whenSearchWithQuery_thenReturnFilteredResults() async throws {
        // given
        dataSource.fetchRecipesResult = [
            RecipeDTO(id: "1", name: "Cake", imageUrl: "", duration: 0),
            RecipeDTO(id: "2", name: "Coke", imageUrl: "", duration: 0)
        ]
        let query = "cake"

        // when
        let result = try await repository.search(with: query)

        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Cake")
    }
}
