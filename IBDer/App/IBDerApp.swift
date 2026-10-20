import SwiftUI

@main
struct IBDerApp: App {
    @State private var model = RecordsModel.live()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
        }
    }
}
