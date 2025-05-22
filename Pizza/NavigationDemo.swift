@Reducer
struct NavigationDemo {
    @Reducer
    enum Path {
        case screenA(ScreenA)
        case screenB(ScreenB)
        case screenC(ScreenC)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }

    enum Action {
        case goBackToScreen(id: StackElementID)
        case goToABCButtonTapped
        case path(StackActionOf<Path>)
        case popToRoot
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .goBackToScreen(id):
                state.path.pop(to: id)
                return .none

            case .goToABCButtonTapped:
                state.path.append(.screenA(ScreenA.State()))
                state.path.append(.screenB(ScreenB.State()))
                state.path.append(.screenC(ScreenC.State()))
                return .none

            case let .path(action):
                switch action {
                case .element(id: _, action: .screenB(.screenAButtonTapped)):
                    state.path.append(.screenA(ScreenA.State()))
                    return .none

                case .element(id: _, action: .screenB(.screenBButtonTapped)):
                    state.path.append(.screenB(ScreenB.State()))
                    return .none

                case .element(id: _, action: .screenB(.screenCButtonTapped)):
                    state.path.append(.screenC(ScreenC.State()))
                    return .none

                default:
                    return .none
                }

            case .popToRoot:
                state.path.removeAll()
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
