import Foundation
import SwiftUI

final class AlertCenter: ObservableObject {
    struct Message: Identifiable {
        let id = UUID()
        let title: String
        let body: String?
    }
    @Published var message: Message?

    func show(title: String, body: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.message = Message(title: title, body: body)
        }
    }
}
