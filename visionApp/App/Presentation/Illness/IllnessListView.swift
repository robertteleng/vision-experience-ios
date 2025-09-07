import SwiftUI

struct IllnessListView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var router: AppRouter

    // Lista de enfermedades usando el modelo Illness
    let illnesses: [Illness] = [
        Illness(name: "Cataracts", description: "Simulates cataracts vision.", filterType: .cataracts),
        Illness(name: "Glaucoma", description: "Simulates glaucoma vision.", filterType: .glaucoma),
        Illness(name: "Macular degeneration", description: "Simulates macular degeneration vision.", filterType: .macularDegeneration),
        Illness(name: "Tunnel Vision", description: "Simulates strong tunnel vision.", filterType: .tunnelVision),

        // Nuevas problemáticas
        Illness(name: "Blurry Vision", description: "Simulates global blurry vision.", filterType: .blurryVision),
        Illness(name: "Central Scotoma", description: "Simulates a central scotoma (central blind spot).", filterType: .centralScotoma),
        Illness(name: "Hemianopsia", description: "Simulates hemianopsia (half visual field loss).", filterType: .hemianopsia)
    ]

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 28) {
                ForEach(illnesses) { illness in
                    FloatingGlassButton(title: illness.name, iconName: "eye") {
                        mainViewModel.selectedIllness = illness
                        router.currentRoute = .camera
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    IllnessListView()
        .environmentObject(MainViewModel())
        .environmentObject(AppRouter())
}
