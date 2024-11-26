import SwiftUI

//Dinosaur Game Content View
// GIFImageView Implementation
struct GIFImageView: UIViewRepresentable {
    let gifName: String
    let size: CGSize
    
    init(gifName: String, size: CGSize = CGSize(width: 150, height: 150)) {
        self.gifName = gifName
        self.size = size
    }
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        if let gif = UIImage.gifImageWithName(gifName, targetSize: size) {
            imageView.image = gif
        }
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Update code if needed
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// UIImage Extension for GIF Support
extension UIImage {
    static func gifImageWithName(_ name: String, targetSize: CGSize = CGSize(width: 150, height: 150)) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        return gifImageWithData(imageData, targetSize: targetSize)
    }
    
    static func gifImageWithData(_ data: Data, targetSize: CGSize = CGSize(width: 150, height: 150)) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)
        
        // Get total duration from GIF properties
        let properties = CGImageSourceCopyProperties(source, nil) as? [String: Any]
        let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
        let frameDuration = gifProperties?[kCGImagePropertyGIFDelayTime as String] as? Double ?? 0.1
        
        // Calculate total duration and adjust for desired speed
        let speedMultiplier = 0.2 // Adjust this value to make it faster (lower) or slower (higher)
        let totalDuration = Double(count) * frameDuration * speedMultiplier
        
        // Create options for thumbnail creation
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height)
        ]
        
        for i in 0..<count {
            if let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(source, i, options as CFDictionary) {
                let resizedImage = UIImage(cgImage: thumbnailRef)
                images.append(resizedImage)
            }
        }
        
        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
}

struct DinosaurTutorialScreen: View {
    @Binding var isVisible: Bool
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Main container with white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Cómo Jugar")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    // 1. Drawing Tutorial GIF
                    // In DinosaurTutorialScreen
                    VStack(spacing: 0) {
                        GIFContainer(name: "DrawTut", size: CGSize(width: 150, height: 150))
                            .frame(height: 150)
                            .padding(.horizontal)
                        
                        Text("Dibuja sobre el cráneo para revelarlo")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.darkGray)
                    }
                    .padding(.bottom, 30)  // Add bottom padding to create space between sections

                    // 2. Rotation Tutorial GIF
                    VStack(spacing: 10) {
                        GIFContainer(name: "RotateTut", size: CGSize(width: 150, height: 150))
                            .frame(width: 100, height: 100)
                            .padding(.horizontal)
                            .padding(.bottom, 10)  // Add padding to move gif up away from text
                        
                        Text("Desliza para rotar el cráneo")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.darkGray)
                    }
                    
                    // 3. Skull Tutorial Container
                    VStack(spacing: 10) {
                        ZStack {
                            Image("SkullTut")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                            
                            // Question mark with animation - now after the Image so it appears on top
                            Text("❓")
                                .font(.system(size: 60))  // Made it bigger
                                .offset(y: -40)  // Adjusted position for larger size
                                .modifier(PulseAnimation())
                        }
                        .padding()
                        
                        Text("Identifica el cráneo del dinosaurio correcto")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.darkGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Continue Button
                    Button(action: {
                        withAnimation {
                            isVisible = false
                            onDismiss()
                            NotificationCenter.default.post(name: Notification.Name("QuizDidEnd"), object: nil)
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("¡Comenzar!")
                                .font(.title3.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.accent)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .transition(.opacity)
    }
}

struct GIFContainer: View {
    let name: String
    let size: CGSize
    
    init(name: String, size: CGSize = CGSize(width: 150, height: 150)) {
        self.name = name
        self.size = size
    }
    
    var body: some View {
        GeometryReader { geometry in
            GIFImageView(gifName: name, size: size)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct DinosaurTutorialScreen_Previews: PreviewProvider {
    static var previews: some View {
        DinosaurTutorialScreen(isVisible: .constant(true), onDismiss: {})
    }
}

// Extension for custom colors if needed
extension Color {
    static let darkGray = Color(UIColor.darkGray)
}

struct ScoreScreen: View {
    let correctAnswers: Int
    let totalQuizzes: Int
    let onRestart: () -> Void
    let onDismiss: () -> Void
    
    @State private var badgeScale: CGFloat = 0.1
    @State private var badgeRotation: Double = -180
    @State private var badgeOpacity: Double = 0
    @State private var shineOpacity: Double = 0
    @State private var isFloating: Bool = false
    @State private var hasRecordedBadge: Bool = false
    
    private var deservesBadge: Bool {
        correctAnswers >= 3
    }
    
    private func InsertRegistro(user_id: UUID, exhibicion_id: Int) async {
            let registro = RegistroAlmanaque(id_usuario: user_id, id_exhibicion: exhibicion_id)
            
            do {
                try await supabase
                    .from("RegistrosAlmanaque")
                    .insert(registro)
                    .execute()
            } catch {
                print("Error al insertar registro en la base de datos: \(error)")
            }
        }
        
    private struct RegistroAlmanaque: Encodable {
        let id_usuario: UUID
        let id_exhibicion: Int
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if deservesBadge {
                // Badge container with animations
                ZStack {
                    // Shine effect
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.4),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 100
                    )
                    .scaleEffect(1.5)
                    .opacity(shineOpacity)
                    
                    // Badge image
                    Image("badge_dino") // Make sure to add this image to your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .scaleEffect(badgeScale)
                        .rotationEffect(.degrees(badgeRotation))
                        .opacity(badgeOpacity)
                        .offset(y: isFloating ? -10 : 10)
                } //ZStack
                .frame(height: 160)
                .onAppear {
                        if deservesBadge && !hasRecordedBadge {
                            // Record the badge achievement
                            Task {
                                await self.InsertRegistro(user_id: UserManage.loadActiveUser()?.userId ?? UUID(), exhibicion_id: 34)
                                    print("Successfully recorded badge achievement")
                            }
                        }
                    }
            } else {
                // Original trophy/medal image for lower scores
                Image(systemName: getScoreImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(getScoreColor())
                    .shadow(radius: 10)
            }
            
            Text("¡Fin del juego!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            
            VStack(spacing: 15) {
                Text("Has acertado")
                    .font(.title2)
                    .foregroundColor(.black.opacity(0.7))
                
                Text("\(correctAnswers) de \(totalQuizzes)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(getScoreColor())
                
                Text(getFeedbackMessage())
                    .font(.title3)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                Button(action: onRestart) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.title2)
                        Text("Volver a jugar")
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(.accent)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
                Button(action: onDismiss) {
                    HStack {
                        Image(systemName: "chevron.backward.circle.fill")
                            .font(.title2)
                        Text("Pantalla Principal")
                            .font(.title3.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color.gray)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
            }
            .padding(.top, 20)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 20)
        )
        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
        .onAppear {
            if deservesBadge {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                    badgeScale = 1.0
                    badgeRotation = 0
                    badgeOpacity = 1.0
                }
                
                // Shine animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        shineOpacity = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            shineOpacity = 0
                        }
                    }
                }
                
                // Start floating animation
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isFloating = true
                }
            }
        }
    }
    
    // Existing helper functions remain the same
    private func getScoreImage() -> String {
        let percentage = Double(correctAnswers) / Double(totalQuizzes)
        switch percentage {
            case 1.0: return "crown.fill"
            case 0.75...: return "star.fill"
            case 0.5...: return "hand.thumbsup.fill"
            default: return "flag.fill"
        }
    }
    
    private func getScoreColor() -> Color {
        let percentage = Double(correctAnswers) / Double(totalQuizzes)
        switch percentage {
            case 1.0: return .yellow
            case 0.75...: return .orange
            case 0.5...: return .blue
            default: return .gray
        }
    }
    
    private func getFeedbackMessage() -> String {
        let percentage = Double(correctAnswers) / Double(totalQuizzes)
        switch percentage {
            case 1.0: return "¡Perfecto! ¡Eres un experto paleontólogo!"
            case 0.75...: return "¡Muy bien! Tienes un gran conocimiento sobre dinosaurios."
            case 0.5...: return "¡Buen trabajo! Sigue aprendiendo sobre estos fascinantes animales."
            default: return "¡Sigue intentándolo! Cada intento es una oportunidad para aprender más."
        }
    }
}

extension View {
    @ViewBuilder func display(_ shouldDisplay: Bool) -> some View {
        if shouldDisplay {
            self
        }
    }
}

struct ConfettiView: View {
    @State private var particles: [(UUID, CGPoint, Double, Color, Double, Double)] = []
    @State private var timer: Timer?
    let colors: [Color] = [.blue, .red, .green, .yellow, .purple, .orange, .pink]

    var body: some View {
        ZStack {
            ForEach(particles, id: \.0) { particle in
                Rectangle()
                    .fill(particle.3)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(particle.4))
                    .position(particle.1)
                    .opacity(particle.2)
            }
        }
        .onAppear {
            createParticles()
        }
    }

    func createParticles() {
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2

        for _ in 0...150 {
            let angle = Double.random(in: 0...2 * .pi)
            let velocity = Double.random(in: 10...20)
            let rotation = Double.random(in: 0...360)
            let particle = (
                UUID(),
                CGPoint(x: centerX, y: centerY),
                1.0,
                colors.randomElement() ?? .blue,
                rotation,
                velocity
            )
            particles.append(particle)
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            particles = particles.compactMap { particle in
                let angle = Double.random(in: 0...2 * .pi)
                let dx = particle.5 * cos(angle)
                let dy = particle.5 * sin(angle) + 2

                let newX = particle.1.x + CGFloat(dx)
                let newY = particle.1.y + CGFloat(dy)
                let newOpacity = particle.2 - 0.01
                let newRotation = particle.4 + 5

                if newOpacity <= 0 {
                    return nil
                }

                return (
                    particle.0,
                    CGPoint(x: newX, y: newY),
                    newOpacity,
                    particle.3,
                    newRotation,
                    max(particle.5 - 0.1, 1)
                )
            }

            if particles.isEmpty {
                timer?.invalidate()
            }
        }
    }
}

// Define SkullModel struct
struct SkullModel {
    let name: String
    var modelName: String  // Name of the 3D model file
    let options: [String]  // Quiz options
    let correctAnswerIndex: Int
    let images: (dino: String, skull: String)
}

struct ContentViewDino: View {
    @Environment(\.dismiss) var dismiss
    @State private var showQuiz = false
    @State private var selectedOption: Int? = nil
    @State private var showCorrectNotification = false
    @State private var shake = false
    @State private var showFeedback = false
    @State private var quizOffset: CGFloat = 1000
    @State private var showConfetti = false
    @State private var wrongAnswers: Set<Int> = []
    @State private var quizExitOffset: CGFloat = 0
    @State private var imageOpacity: Double = 1.0
    @State private var showingSkull = false
    @State private var showArrowButton = false
    @State private var currentSkullIndex: Int = 0
    @State private var skullModelName: String = "Trex.usdz"
    @State private var correctAnswersCount: Int = 0
    @State private var showScoreScreen: Bool = false
    @State private var currentQuizAnswered: Bool = false
    // Modified tutorial state variables
    @AppStorage("tutorialShown") private var tutorialShown = false
    @State private var showTutorial = false
    @State private var shouldShowTutorial = false
    @State private var scoreScreenScale: CGFloat = 0.5
    
    // Define skullModels with the new models
    @State private var skullModels: [SkullModel] = [
            SkullModel(
                name: "Tyrannosaurus Rex",
                modelName: "Trex.usdz",
                options: ["Brachiosaurus", "Tyrannosaurus Rex", "Velociraptor", "Stegosaurus"],
                correctAnswerIndex: 1,
                images: (dino: "TyrannosaurusRex", skull: "TyrannosaurusRexSkull")
            ),
            SkullModel(
                name: "Quetzalcoatlus",
                modelName: "Quetzalcoatlus.usdz",
                options: ["Pteranodon", "Quetzalcoatlus", "Spinosaurus", "Parasaurolophus"],
                correctAnswerIndex: 1,
                images: (dino: "Quetzalcoatlus", skull: "QuetzalcoatlusSkull")
            ),
            SkullModel(
                name: "Plesiosaur",
                modelName: "Plesiosaur.usdz",
                options: ["Plesiosaur", "Mosasaur", "Diplodocus", "Triceratops"],
                correctAnswerIndex: 0,
                images: (dino: "Plesiosaur", skull: "PlesiosaurSkull")
            ),
            SkullModel(
                name: "Apatosaurus",
                modelName: "Apatosaur.usdz",
                options: ["Brachiosaurus", "Diplodocus", "Apatosaurus", "Stegosaurus"],
                correctAnswerIndex: 2,
                images: (dino: "Apatosaurus", skull: "ApatosaurusSkull")
            )
        ]

    var currentSkullModel: SkullModel {
        skullModels[currentSkullIndex % skullModels.count]
    }

    @State private var options: [String] = []
    @State private var correctAnswerIndex: Int = 0

    // Include the options array
    let allOptions = [
            "Brachiosaurus",
            "Diplodocus",
            "Mosasaur",
            "Parasaurolophus",
            "Pteranodon",
            "Spinosaurus",
            "Stegosaurus",
            "Triceratops",
            "Velociraptor"
        ]

    // Include the dinosaurImages dictionary
    let dinosaurImages: [String: (dino: String, skull: String)] = [
            "Brachiosaurus": (dino: "Brachiosaurus", skull: "BrachiosaurusSkull"),
            "Diplodocus": (dino: "Diplodocus", skull: "DiplodocusSkull"),
            "Mosasaur": (dino: "Mosasaur", skull: "MosasaurSkull"),
            "Parasaurolophus": (dino: "Parasaurolophus", skull: "ParasaurolophusSkull"),
            "Pteranodon": (dino: "Pteranodon", skull: "PteranodonSkull"),
            "Spinosaurus": (dino: "Spinosaur", skull: "SpinosaurSkull"),
            "Stegosaurus": (dino: "Stegosaurus", skull: "StegosaurusSkull"),
            "Triceratops": (dino: "Triceratops", skull: "TriceratopsSkull"),
            "Velociraptor": (dino: "Velociraptor", skull: "VelociraptorSkull")
        ]

    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ARViewContainerDino(showQuiz: $showQuiz,
                           skullModelName: $skullModelName,
                           showTutorial: $showTutorial)
            .edgesIgnoringSafeArea(.all)
            
            // Change the condition to use the new state variable
            if shouldShowTutorial {
                DinosaurTutorialScreen(isVisible: $shouldShowTutorial) {
                    tutorialShown = true
                    shouldShowTutorial = false
                }
                .transition(.opacity)
                .zIndex(2)
            }
            
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .zIndex(2)
            }
            
            if showQuiz {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("¿A qué dinosaurio pertenece este cráneo?")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top)
                        
                        ForEach(0..<options.count, id: \.self) { index in
                                    Button(action: {
                                        self.selectedOption = index
                                        if index == self.correctAnswerIndex {
                                            // Only increment score if this is the first attempt
                                            if !currentQuizAnswered {
                                                self.correctAnswersCount += 1
                                            }
                                            withAnimation {
                                                self.showConfetti = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                self.showCorrectNotification = true
                                            }
                                        } else {
                                            withAnimation(.default) {
                                                self.shake = true
                                                self.wrongAnswers.insert(index)
                                                self.currentQuizAnswered = true  // Mark that they've attempted this quiz
                                            }
                                            withAnimation(.spring()) {
                                                self.showFeedback = true
                                            }
                                        }
                                    }) {
                                Text(self.options[index])
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(self.buttonBackgroundColor(for: index))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(showFeedback || wrongAnswers.contains(index))
                            .modifier(ShakeEffect(shakes: shake && selectedOption == index ? 2 : 0))
                            .opacity(wrongAnswers.contains(index) ? 0.6 : 1.0)
                        }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.9))
                                .shadow(radius: 10)
                        )
                        .padding()
                        .offset(y: quizOffset + quizExitOffset)
                        .onAppear {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                quizOffset = 0
                            }
                        }
                    }
                
                if showScoreScreen {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showScoreScreen)
                    
                    ScoreScreen(
                        correctAnswers: correctAnswersCount,
                        totalQuizzes: skullModels.count,
                        onRestart: {  // This needs to be labeled
                            // Zoom out animation before resetting
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                scoreScreenScale = 0.5
                                // Fade out the background
                                showScoreScreen = false
                            }
                            
                            // Wait for animation to complete before resetting
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                scoreScreenScale = 0.5  // Reset scale for next time
                                correctAnswersCount = 0
                                currentSkullIndex = 0
                                currentQuizAnswered = false
                                skullModels.shuffle()
                                updateCurrentSkull()
                                
                                // Reset other necessary state
                                showConfetti = false
                                selectedOption = nil
                                showQuiz = false
                                showFeedback = false
                                shake = false
                                wrongAnswers.removeAll()
                                quizOffset = UIScreen.main.bounds.height
                                showingSkull = false
                                showArrowButton = false
                                
                                NotificationCenter.default.post(name: Notification.Name("QuizDidEnd"), object: nil)
                            }
                        },
                        onDismiss: {
                            dismiss()
                        }
                    )
                    .scaleEffect(scoreScreenScale)
                    .onAppear {
                        // Zoom in animation when appearing
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            scoreScreenScale = 1.0
                        }
                    }
                }
           
                
                if showFeedback {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring()) {
                                    self.showFeedback = false
                                }
                                self.selectedOption = nil
                                self.shake = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title)
                                    .padding([.top, .trailing])
                            }
                        }
                        
                        if let selectedOption = selectedOption,
                           let dinosaurName = options[safe: selectedOption],
                           let images = dinosaurImages[dinosaurName] {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ZStack {
                                        Image(images.dino)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .opacity(showingSkull ? 0 : imageOpacity)
                                        
                                        Image(images.skull)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .opacity(showingSkull ? imageOpacity : 0)
                                    }
                                    .animation(.easeInOut(duration: 1), value: showingSkull)
                                    
                                    getFeedbackMessage(for: dinosaurName)
                                        .foregroundColor(.black)
                                        .padding(.horizontal)
                                        .padding(.bottom)
                                }
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.95))
                            .shadow(radius: 10)
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                    .fixedSize(horizontal: false, vertical: true)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                    .onReceive(timer) { _ in
                        withAnimation {
                            showingSkull.toggle()
                        }
                    }
                }
            }
            
            if showArrowButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.resetQuiz()
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            self.skullModels.shuffle()
            updateCurrentSkull()
            self.shouldShowTutorial = true  // Force show tutorial
            
            // Add a slight delay to ensure AR View is properly initialized
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showTutorial = true
            }
        }
        .alert(isPresented: $showCorrectNotification) {
            Alert(
                title: Text("¡Correcto!"),
                message: Text("¡Este es efectivamente un cráneo de \(currentSkullModel.name)!"),
                dismissButton: .default(Text("OK")) {
                    // Slide down animation
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        quizOffset = UIScreen.main.bounds.height  // Slide down off screen
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        if currentSkullIndex == skullModels.count - 1 {
                            scoreScreenScale = 0.5  // Reset scale before showing
                            showScoreScreen = true
                        } else {
                            showArrowButton = true
                        }
                    }
                }
            )
        }
    }

    private func buttonBackgroundColor(for index: Int) -> Color {
        if wrongAnswers.contains(index) {
            return Color.red
        } else if let selected = selectedOption {
            if selected == index {
                return index == correctAnswerIndex ? Color.green : Color.red
            } else {
                return Color.blue
            }
        } else {
            return Color.blue
        }
    }

    private func resetQuiz() {
        // First check if this was the last quiz
        if currentSkullIndex == skullModels.count - 1 {
            withAnimation {
                showScoreScreen = true
            }
            return
        }

        // Slide current quiz down
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            quizOffset = UIScreen.main.bounds.height  // Slide current quiz down
        }
        
        // After animation completes, reset state and prepare next quiz
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.showConfetti = false
            self.selectedOption = nil
            self.showQuiz = false
            self.showFeedback = false
            self.shake = false
            self.wrongAnswers.removeAll()
            self.showingSkull = false
            self.showArrowButton = false
            self.currentQuizAnswered = false

            self.currentSkullIndex = (self.currentSkullIndex + 1) % self.skullModels.count
            updateCurrentSkull()
            
            // Reset offset for next quiz
            self.quizOffset = UIScreen.main.bounds.height
            
            NotificationCenter.default.post(name: Notification.Name("QuizDidEnd"), object: nil)
        }
    }
    
    private func updateCurrentSkull() {
        self.options = currentSkullModel.options
        self.correctAnswerIndex = currentSkullModel.correctAnswerIndex
        self.skullModelName = currentSkullModel.modelName  // Update the model name
    }

    // Include the getFeedbackMessage function
    func getFeedbackMessage(for dinosaur: String) -> some View {
            switch dinosaur {
            case "Brachiosaurus":
                return VStack(spacing: 16) {
                    Text("Brachiosaurus")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Brachiosaurus era uno de los dinosaurios más altos que jamás existió. Su largo cuello le permitía alcanzar las hojas más altas de los árboles.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Podía alcanzar alturas de hasta 16 metros, similar a un edificio de 4 pisos!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Diplodocus":
                return VStack(spacing: 16) {
                    Text("Diplodocus")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Diplodocus tenía uno de los cuellos más largos entre todos los dinosaurios. Era un herbívoro pacífico que vivía en manadas.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Su cola era tan larga que podía usarla como un látigo para defenderse!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Mosasaur":
                return VStack(spacing: 16) {
                    Text("Mosasaurio")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Mosasaurio era un depredador marino gigante que dominaba los océanos prehistóricos. Tenía una segunda hilera de dientes en el paladar.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Podía abrir su mandíbula como una serpiente para tragar presas grandes enteras!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Parasaurolophus":
                return VStack(spacing: 16) {
                    Text("Parasaurolophus")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Parasaurolophus tenía una cresta tubular única en su cabeza que usaba para comunicarse con otros de su especie.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Su cresta funcionaba como un instrumento musical prehistórico!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Pteranodon":
                return VStack(spacing: 16) {
                    Text("Pteranodon")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Pteranodon era un reptil volador con una cresta distintiva en su cabeza y sin dientes. Pescaba en los océanos prehistóricos.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Su envergadura podía alcanzar los 7 metros, como una avioneta pequeña!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Spinosaurus":
                return VStack(spacing: 16) {
                    Text("Spinosaurio")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Spinosaurio tenía una gran vela en su espalda y un hocico largo como el de un cocodrilo. Era un cazador tanto en tierra como en agua.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Era más grande que el T-Rex y podía nadar como un experto!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Stegosaurus":
                return VStack(spacing: 16) {
                    Text("Stegosaurus")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Stegosaurus tenía dos filas de placas en su espalda y espinas en la cola. Era un herbívoro pacífico pero bien defendido.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Sus placas podían cambiar de color para regular su temperatura!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Triceratops":
                return VStack(spacing: 16) {
                    Text("Triceratops")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Triceratops tenía tres cuernos y un gran volante óseo en su cabeza. Era un herbívoro que usaba sus cuernos para defenderse.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Su cabeza era una de las más grandes entre los dinosaurios terrestres!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            case "Velociraptor":
                return VStack(spacing: 16) {
                    Text("Velociraptor")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("El Velociraptor era un dinosaurio pequeño pero ágil, con una garra retráctil en cada pie. Cazaba en manadas.")
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 4) {
                            Text("Dato curioso:")
                                .bold()
                            Text("¡Tenía plumas y era del tamaño de un pavo grande!")
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

            default:
                return Text("Información no disponible")
            }
        }
}

// Include the ShakeEffect struct
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakes: Int = 3
    var animatableData: CGFloat

    init(shakes: Int) {
        self.shakes = shakes
        self.animatableData = CGFloat(shakes)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// Safe array indexing
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
