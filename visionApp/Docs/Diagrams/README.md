# VisionApp - Diagramas UML

Este directorio contiene los diagramas PlantUML para la presentación de VisionApp.

## Cómo visualizar los diagramas

### Opción 1: Online (más rápido)
1. Ve a http://www.plantuml.com/plantuml/uml/
2. Copia y pega el contenido de cualquier archivo .puml
3. El diagrama se generará automáticamente

### Opción 2: VS Code
1. Instala la extensión "PlantUML" en VS Code
2. Abre cualquier archivo .puml
3. Presiona `Alt+D` (Windows/Linux) o `Option+D` (Mac) para preview

### Opción 3: Comando de línea (requiere instalación)
```bash
# Instalar PlantUML (requiere Java)
brew install plantuml

# Generar PNG desde un archivo
plantuml diagrama.puml

# Generar todos los diagramas
plantuml *.puml
```

## Listado de Diagramas

### 01. Arquitectura General (`01_arquitectura_general.puml`)
Vista de alto nivel de las capas de la aplicación:
- Presentation Layer
- Domain Layer
- Services Layer
- Image Processing
- Utils

**Ideal para**: Explicar la estructura general del proyecto.

---

### 02. Flujo de Usuario (`02_flujo_usuario.puml`)
Diagrama de actividad que muestra el recorrido del usuario:
- Splash → Home
- Selección de modo (Normal/VR/Lista)
- Aplicación de filtros
- Interacción por voz o manual

**Ideal para**: Demostrar la experiencia de usuario paso a paso.

---

### 03. Componentes Principales (`03_componentes_principales.puml`)
Muestra los módulos principales y sus relaciones:
- Main Module (HomeView, MainViewModel)
- Camera Module (CameraView, CameraService)
- Cardboard Module (Vista VR estereoscópica)
- Image Processing (CIProcessor)
- UI Components (FloatingMenu, Filters)
- Voice Control (Speech Recognition)

**Ideal para**: Explicar cómo se comunican los componentes.

---

### 04. Diagrama de Clases (`04_diagrama_clases.puml`)
Clases principales con atributos y métodos:
- MainViewModel
- CameraViewModel
- CameraService
- CIProcessor
- Illness, IllnessSettings
- SpeechRecognitionService
- Enums (IllnessFilterType, Panel)

**Ideal para**: Presentación técnica detallada.

---

### 05. Secuencia: Aplicar Filtro (`05_secuencia_aplicar_filtro.puml`)
Diagrama de secuencia mostrando:
1. Usuario selecciona enfermedad
2. Usuario activa filtro
3. CameraService captura frames
4. CIProcessor aplica efectos
5. Renderizado en pantalla en tiempo real

**Ideal para**: Explicar el procesamiento frame por frame.

---

### 06. Secuencia: Comandos de Voz (`06_secuencia_voz.puml`)
Flujo completo del control por voz:
1. Usuario dice comando
2. SpeechRecognitionService procesa
3. MainViewModel actualiza estado
4. UI refleja cambios
5. Feedback auditivo (TTS)

**Ideal para**: Demostrar la accesibilidad y control hands-free.

---

### 07. Diagrama de Estados (`07_diagrama_estados.puml`)
Estados de la aplicación y transiciones:
- Splash → Home
- Modos: CameraNormal, CameraCardboard, ListaEnfermedades
- Estados de filtros: SinFiltro ↔ FiltroActivo
- Sub-estados: Cataratas, Glaucoma, Macular, Túnel

**Ideal para**: Mostrar los diferentes modos de la app.

---

### 08. Casos de Uso (`08_casos_uso.puml`)
Actores y casos de uso:
- **Usuario general**: Visualizar, navegar, ajustar
- **Usuario con discapacidad visual**: Control por voz
- **Profesional de salud**: Demostración a pacientes, empatía

**Ideal para**: Explicar los diferentes perfiles de usuario.

---

### 09. Despliegue y Módulos (`09_despliegue_modulos.puml`)
Estructura de deployment:
- Capas de la aplicación
- Frameworks de iOS utilizados
- Hardware del dispositivo
- Integración con el sistema

**Ideal para**: Presentación técnica sobre tecnologías usadas.

---

### 10. Flujo de Datos (`10_flujo_datos.puml`)
Pipeline completo de procesamiento:
- Captura: AVCaptureSession → frames
- Conversión: Buffer → CGImage
- Estado: MainViewModel (settings, illness)
- Procesamiento: CIProcessor + Core Image
- Renderizado: SwiftUI Canvas
- Control: Menu + Voice

**Ideal para**: Explicar el flujo de datos end-to-end.

---

## Recomendaciones para la Presentación

### Para Audiencia No Técnica:
- **02_flujo_usuario.puml** - Muestra la experiencia del usuario
- **08_casos_uso.puml** - Explica para quién es la app
- **07_diagrama_estados.puml** - Modos y funcionalidades

### Para Audiencia Técnica:
- **01_arquitectura_general.puml** - Visión general técnica
- **04_diagrama_clases.puml** - Implementación detallada
- **05_secuencia_aplicar_filtro.puml** - Procesamiento en tiempo real
- **09_despliegue_modulos.puml** - Stack tecnológico

### Para Demostración de Innovación:
- **06_secuencia_voz.puml** - Control por voz (accesibilidad)
- **03_componentes_principales.puml** - Modo VR Cardboard
- **10_flujo_datos.puml** - Procesamiento GPU en tiempo real

---

## Características Destacadas en los Diagramas

✅ **4 Enfermedades Simuladas**: Cataratas, Glaucoma, Degeneración Macular, Visión Túnel
✅ **Modo VR Inmersivo**: Vista estereoscópica para Google Cardboard
✅ **Control por Voz**: Manos libres y accesible
✅ **Procesamiento en Tiempo Real**: ~30 FPS con Core Image (GPU)
✅ **Arquitectura en Capas**: Presentation, Domain, Services, Processing
✅ **Tecnologías iOS**: SwiftUI, AVFoundation, Core Image, Speech Framework, Combine

---

## Notas Técnicas

- **Performance**: Core Image utiliza GPU para procesamiento en tiempo real
- **Reactive**: Combine framework para flujo de datos reactivo
- **Accesibilidad**: VoiceOver compatible, control por voz
- **Modular**: Arquitectura limpia con separación de responsabilidades
- **Extensible**: Fácil añadir nuevos filtros o enfermedades

---

*Generado el 18 de Diciembre de 2025*
