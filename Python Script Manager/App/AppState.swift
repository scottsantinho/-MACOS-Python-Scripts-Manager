import Foundation

class AppState: ObservableObject {
    @Published var scriptCoordinator: ScriptCoordinatorService
    
    init() {
        scriptCoordinator = ScriptCoordinatorService()
    }
}
