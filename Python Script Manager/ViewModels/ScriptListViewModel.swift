// ScriptListViewModel.swift
import Foundation
import Combine

class ScriptListViewModel: ObservableObject {
    @Published private(set) var scripts: [Script] = []
    private var coordinator: ScriptCoordinatorService?
    private var cancellables = Set<AnyCancellable>()
    
    func updateScriptCoordinator(_ coordinator: ScriptCoordinatorService) {
        self.coordinator = coordinator
        setupBindings()
    }
    
    private func setupBindings() {
        guard let coordinator = coordinator else { return }
        coordinator.$scripts
            .assign(to: \.scripts, on: self)
            .store(in: &cancellables)
    }
    
    func runScript(_ script: Script) {
        do {
            let process = coordinator?.runScript(script)
            try process?.run()
        } catch {
            print("Error running script: \(error.localizedDescription)")
        }
    }
    
    func stopScript(_ script: Script) {
        coordinator?.stopScript(script)
    }
    
    func removeScript(_ script: Script) {
        coordinator?.removeScript(script)
    }
    
    func scheduleScript(_ script: Script) {
        coordinator?.scheduleScript(script)
    }
}
