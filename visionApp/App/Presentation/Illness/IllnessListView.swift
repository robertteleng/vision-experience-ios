import SwiftUI

struct IllnessListView: View {
    @EnvironmentObject var globalViewModel: MainViewModel
    @EnvironmentObject var router: AppRouter

    // Lista de enfermedades usando el modelo Illness
    let illnesses: [Illness] = [
        Illness(name: "Cataracts", description: "Simulates cataracts vision.", filterType: .cataracts),
        Illness(name: "Glaucoma", description: "Simulates glaucoma vision.", filterType: .glaucoma),
        Illness(name: "Macular degeneration", description: "Simulates macular degeneration vision.", filterType: .macularDegeneration),
        Illness(name: "Tunnel Vision", description: "Simulates strong tunnel vision.", filterType: .tunnelVision)
    ]

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 28) {
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
        .ignoresSafeArea()
    }
}

#Preview {
    IllnessListView()
        .environmentObject(MainViewModel())
        .environmentObject(AppRouter())
}
