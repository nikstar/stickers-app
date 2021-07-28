
import SwiftUI

struct ErrorView: View {
    var body: some View {
        Image(systemName: "nosign")
            .resizable()
            .foregroundColor(.tertiaryLabel)
            .aspectRatio(1, contentMode: .fit)
            .padding(10)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
