//
//  VoiceCommandsTestView.swift
//  VisionExperience
//
//  Vista para testear comandos de voz - Actualizada para nueva arquitectura
//

import SwiftUI

// Fallback definition in case SpeechRecognitionContext isn't available in this target
#if swift(>=5.0)
public enum SpeechRecognitionContext {
    case splash
    case illnessList
    case camera
}
#endif

struct VoiceCommandsTestView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var speechViewModel: SpeechRecognitionViewModel
    
    let testCommands = [
        ("Cataratas", "cataratas"),
        ("Glaucoma", "glaucoma"),
        ("Macular", "degeneración macular"),
        ("Túnel", "visión de túnel"),
        ("Más intenso", "más"),
        ("Menos intenso", "menos"),
        ("Activar", "activar filtro"),
        ("Desactivar", "desactivar filtro"),
        ("Atrás", "volver"),
        ("VR", "realidad virtual"),
        ("Ayuda", "ayuda")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Text("🎤 Test de Comandos de Voz")
                        .font(.title2)
                        .bold()
                    
                    Text("Toca los botones para simular comandos de voz")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Estado del speech recognition
                    HStack {
                        Circle()
                            .fill(speechViewModel.isListening ? .green : .red)
                            .frame(width: 8, height: 8)
                        Text(speechViewModel.isListening ? "Escuchando" : "Detenido")
                            .font(.caption)
                        
                        Spacer()
                        
                        Button(speechViewModel.isListening ? "Parar" : "Iniciar") {
                            speechViewModel.toggleListening()
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(speechViewModel.isListening ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    
                    // Contexto actual
                    HStack {
                        Text("Contexto:")
                            .font(.caption)
                        Text(displayName(for: speechViewModel.currentContext))
                            .font(.caption)
                            .bold()
                        Spacer()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Estado de la app
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 Estado Actual")
                        .font(.headline)
                    
                    Group {
                        InfoRow(label: "Ruta", value: displayName(for: mainViewModel.currentRoute))
                        InfoRow(label: "Enfermedad", value: mainViewModel.selectedIllness?.name ?? "Ninguna")
                        InfoRow(label: "Filtro", value: mainViewModel.filterEnabled ? "Activado" : "Desactivado")
                        InfoRow(label: "Intensidad", value: String(format: "%.1f", mainViewModel.centralFocus))
                        InfoRow(label: "Modo VR", value: mainViewModel.isCardboardMode ? "Activado" : "Desactivado")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Comandos de test
                VStack(alignment: .leading, spacing: 8) {
                    Text("🧪 Comandos de Prueba")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(testCommands, id: \.0) { command in
                            Button(action: {
                                speechViewModel.simulateCommand(command.1)
                            }) {
                                VStack(spacing: 4) {
                                    Text(command.0)
                                        .font(.subheadline)
                                        .bold()
                                    Text(command.1)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Último comando detectado
                if !speechViewModel.lastDetectedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🗣️ Último Texto Detectado")
                            .font(.headline)
                        
                        Text(speechViewModel.lastDetectedText)
                            .font(.body)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                // Errores
                if let error = speechViewModel.error {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⚠️ Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(error)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                // Comandos válidos por contexto
                VStack(alignment: .leading, spacing: 8) {
                    Text("📋 Comandos Válidos para \(displayName(for: speechViewModel.currentContext))")
                        .font(.headline)
                    
                    Text(getValidCommandsForContext())
                        .font(.caption)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private func getValidCommandsForContext() -> String {
        switch speechViewModel.currentContext {
        case .splash:
            return "Ningún comando disponible"
        case .illnessList:
            return "cataratas, glaucoma, macular, túnel, ayuda"
        case .camera:
            return "cataratas, glaucoma, macular, túnel, más, menos, activar, desactivar, volver, realidad, ayuda"
        case .home:
            return "Navegación general"
        case .immersiveVideo:
            return "Comandos de video inmersivo"
        }
    }
    
    private func displayName(for route: AppRoute) -> String {
        switch route {
        case .splash:
            return "Inicio"
        case .illnessList:
            return "Lista de enfermedades"
        case .camera:
            return "Cámara"
        case .home:
            return "Home"
        case .immersiveVideo:
            return "Video Inmersivo"
        }
    }

    private func displayName(for context: SpeechRecognitionContext) -> String {
        switch context {
        case .splash:
            return "Inicio"
        case .illnessList:
            return "Lista de enfermedades"
        case .camera:
            return "Cámara"
        @unknown default:
            return String(describing: context)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.primary)
        }
    }
}

//#Preview {
//    VoiceCommandsTestView(
//        mainViewModel: MainViewModel(),
//        speechViewModel: SpeechRecognitionViewModel()
//    )
//}

