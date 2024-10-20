import SwiftUI

protocol Routing {
    associatedtype Route
    associatedtype View: SwiftUI.View

    @ViewBuilder func view(for route: Route) -> Self.View
}

class CustomNavPathProvider<Path: Hashable>: ObservableObject {
    @Published var path = [Path]()

    init() {}

    init(path: Path...) {
        push(path)
    }

    var canPop: Bool {
        !path.isEmpty
    }

    func setTo(_ path: Path...) {
        self.path = path
    }

    func setTo(_ path: [Path]) {
        self.path = path
    }

    func push(_ path: Path...) {
        self.path.append(contentsOf: path)
    }

    func push(_ path: [Path]) {
        self.path.append(contentsOf: path)
    }

    func popToRoot() {
        // debugPrint(#fileID, #line, "Dropping all:", path)
        path = [Path]()
    }

    func pop() {
        guard canPop else { return }
        // debugPrint(#fileID, #line, "Dropping last from:", path)
        path.removeLast()
    }

    @discardableResult
    func popTo(_ path: Path) -> Bool {
        popToMatching(comparer: { $0 == path })
    }

    @discardableResult
    func popToMatching(comparer: @escaping (Path) -> Bool) -> Bool {
        guard let endIndex = path.lastIndex(where: comparer) else {
            return false
        }
        if endIndex > 0 {
            path = Array(path[0 ... endIndex])
        } else {
            path = [path[0]]
        }
        return true
    }
}
