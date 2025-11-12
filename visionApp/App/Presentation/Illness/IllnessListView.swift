import SwiftUI

struct IllnessListView: View {
    @EnvironmentObject var globalViewModel: MainViewModel
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(globalViewModel.illnesses) { illness in
                        FloatingGlassButton(title: illness.name, iconName: illness.filterType.symbolName) {
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
