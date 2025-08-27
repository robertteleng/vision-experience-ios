import SwiftUI

struct IllnessListView: View {
    @EnvironmentObject var globalViewModel: MainViewModel
    @EnvironmentObject var router: AppRouter

    // Lista de enfermedades usando el modelo Illness
    let illnesses: [Illness] = [
        Illness(name: "Cataracts", description: "Simulates cataracts vision.", filterType: .cataracts),
        Illness(name: "Glaucoma", description: "Simulates glaucoma vision.", filterType: .glaucoma),
        Illness(name: "Macular Degeneration", description: "Simulates macular degeneration vision.", filterType: .macularDegeneration)
    ]

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 28) {
                ForEach(illnesses) { illness in
                    FloatingGlassButton(title: illness.name, iconName: "eye") {
                        globalViewModel.selectedIllness = illness
                        router.currentRoute = .camera
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}
