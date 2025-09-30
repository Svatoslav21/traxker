import Foundation

enum Fmt {
    static let date: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
    static let dateShort: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    static let number: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
}

extension Array where Element == String {
    var commaString: String { self.joined(separator: ", ") }
}

extension Array where Element == UUID {
    var countString: String { "\(self.count)" }
}
