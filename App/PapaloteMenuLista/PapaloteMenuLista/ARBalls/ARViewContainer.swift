import SwiftUI
import RealityKit
import ARKit
import CoreMotion

struct ARViewContainer: UIViewRepresentable {
    var onDismiss: () -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = GameARView(frame: .zero)
        arView.mainMenuCallback = onDismiss
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

class GameARView: ARView, ARSessionDelegate {
    var gameAnchor: AnchorEntity?
    var platformEntity: ModelEntity?
    var leftBin: ModelEntity?
    var rightBin: ModelEntity?
    var previewEntity: ModelEntity?
    var nextIsRed: Bool = Bool.random()
    var motionManager: CMMotionManager!
    private var previewImageView: UIImageView?
    private var previewContainer: UIView?
    private var previewLabel: UILabel?
    private var imageContainer: UIView? // New container just for the image
    private var lives = 3
    private var livesLabel: UILabel?
    private var heartsContainer: UIStackView?
    private var heartViews: [UILabel] = []
    var mainMenuCallback: (() -> Void)?
    private var coachingOverlay: ARCoachingOverlayView!
    private var tapInstructionView: UIView?
    private var hasShownTapInstruction = false
    private var wasGameEverSetup = false  // Add this new property
    private var ballsRemaining = 10
    private var isShowingGameOver = false // Add this new property
    private var ballCountLabel: UILabel?
    private lazy var redMaterial: SimpleMaterial = {
        var material = SimpleMaterial()
        material.baseColor = MaterialColorParameter.color(.red)
        material.roughness = 0.2
        material.metallic = 1.0
        return material
    }()
    
    private lazy var blueMaterial: SimpleMaterial = {
        var material = SimpleMaterial()
        material.baseColor = MaterialColorParameter.color(.blue)
        material.roughness = 0.2
        material.metallic = 1.0
        return material
    }()
    
    // Modify the material creation to support all ball types
    private lazy var ballMaterials: [String: SimpleMaterial] = {
        var materials: [String: SimpleMaterial] = [:]
        
        for ballType in ballTypes {
            var material = SimpleMaterial()
            do {
                let texture = try TextureResource.load(named: ballType.textureName)
                material.baseColor = MaterialColorParameter.texture(texture)
                material.roughness = 0.2
                material.metallic = 1.0
            } catch {
                print("Failed to load texture for \(ballType.textureName): \(error)")
                // Fallback color based on category
                let fallbackColor: UIColor = ballType.category == .red ? .red : .blue
                material.baseColor = MaterialColorParameter.color(fallbackColor)
            }
            materials[ballType.textureName] = material
        }
        return materials
    }()
  
    private var redBallsInRedBucket = 0
    private var gameOver = false
    private var gameOverText: ModelEntity?
    private var gameTimer: Timer?
    private var isGameSetup = false
    private var planeDetected = false
    private var tutorialState = TutorialState()
    private var tutorialView: UIView?
    
    private struct TutorialState {
        var isShowing = false
        var currentStep = 0
        var hasBeenShown = false
    }

    
    // Add new properties for ball types
    private struct BallType {
        let textureName: String
        let category: BallCategory
    }
    
    private enum BallCategory {
        case red
        case blue
    }
    
    private func togglePreviewVisibility(show: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.previewContainer?.alpha = show ? 1 : 0
        }
    }
    
    private let ballTypes: [BallType] = [
        // Red category balls
        BallType(textureName: "Takis", category: .red), // Orange basketball
        BallType(textureName: "Cheetos", category: .red), // White/red volleyball
        BallType(textureName: "Pepsi", category: .red), // White baseball with red stitching
        BallType(textureName: "Coca-Cola", category: .red),
        BallType(textureName: "Nestle", category: .red),
        BallType(textureName: "McDonalds", category: .red),
        BallType(textureName: "Starbucks", category: .red),
        BallType(textureName: "Monster", category: .red),
            
        // Blue category balls
        BallType(textureName: "Manzana", category: .blue), // Tennis ball (yellow-green)
        BallType(textureName: "Naranja", category: .blue), // Soccer ball (black/white)
        BallType(textureName: "Ziploc", category: .blue),  // Golf ball (white)
        BallType(textureName: "Clif Bar", category: .blue),
        BallType(textureName: "Arroz", category: .blue),
        BallType(textureName: "Miel", category: .blue),
        BallType(textureName: "Avena", category: .blue),
        BallType(textureName: "Ben & Jerrys", category: .blue),
    ]
    
    private var currentBallType: BallType!
    private var redCategoryBallsCaptured: Set<String> = []
    private var blueCategoryBallsCaptured: Set<String> = []
  // Add these properties to GameARView
  private var failedBalls: [(textureName: String, timestamp: Date)] = []
  private var summaryView: UIView?

  // Also, let's modify the recordFailedBall function to limit to 3 balls if needed
  private func recordFailedBall(textureName: String, category: BallCategory) {
      // Keep only the last 3 failed balls
      if failedBalls.count >= 3 {
          failedBalls.removeFirst()
      }
      failedBalls.append((textureName, Date()))
  }
    
    private func showTutorialScreen() {
        tutorialView?.removeFromSuperview()
            
            // Create main container with white background
            let container = UIView(frame: bounds)
            container.backgroundColor = .white  // Changed to white
            container.alpha = 0
            container.layer.zPosition = 100
            
            // Create scroll view for content
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create content stack with reduced spacing
            let contentStack = UIStackView()
            contentStack.axis = .vertical
            contentStack.spacing = 20  // Reduced from 30 to 20
            contentStack.alignment = .center
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            
            // Title - updated color for white background
            let titleLabel = UILabel()
            titleLabel.text = "Cómo Jugar"
            titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
            titleLabel.textColor = .black  // Changed to black for white background
            titleLabel.textAlignment = .center
        
        // 1. Instruction GIF
        let gifContainer = UIView()
            gifContainer.translatesAutoresizingMaskIntoConstraints = false
            
            if let gifImage = UIImage.gifImageWithName("instruction") {
                let imageView = UIImageView(image: gifImage)
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                gifContainer.addSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: gifContainer.topAnchor),
                    imageView.leadingAnchor.constraint(equalTo: gifContainer.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: gifContainer.trailingAnchor),
                    imageView.bottomAnchor.constraint(equalTo: gifContainer.bottomAnchor),
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.6)
                ])
            } else {
                print("Failed to load instruction.gif")
            }
        
        let gifLabel = createInstructionLabel(text: "Inclina tu dispositivo para mover la plataforma")
        
        // 2. Game Bar
        let gameBarContainer = createImageContainer(imageName: "GameBar")
        let gameBarLabel = createInstructionLabel(text: "Pon atención a el próximo producto y tus vidas restantes")
        
        // 3. Shopping Basket and Trash Can Container
        let basketTrashContainer = UIView()
        basketTrashContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Shopping Basket with checkmark
        let basketStack = UIStackView()
        basketStack.axis = .vertical
        basketStack.spacing = 8
        basketStack.alignment = .center
        basketStack.translatesAutoresizingMaskIntoConstraints = false
        
        let basketImageView = UIImageView(image: UIImage(named: "ShoppingBasket"))
        basketImageView.contentMode = .scaleAspectFit
        basketImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let checkmarkLabel = UILabel()
        checkmarkLabel.text = "✅"
        checkmarkLabel.font = .systemFont(ofSize: 40)
        
        basketStack.addArrangedSubview(basketImageView)
        basketStack.addArrangedSubview(checkmarkLabel)
        
        // Trash Can with cross
        let trashStack = UIStackView()
        trashStack.axis = .vertical
        trashStack.spacing = 8
        trashStack.alignment = .center
        trashStack.translatesAutoresizingMaskIntoConstraints = false
        
        let trashImageView = UIImageView(image: UIImage(named: "TrashCan"))
        trashImageView.contentMode = .scaleAspectFit
        trashImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let crossLabel = UILabel()
        crossLabel.text = "❌"
        crossLabel.font = .systemFont(ofSize: 40)
        
        trashStack.addArrangedSubview(trashImageView)
        trashStack.addArrangedSubview(crossLabel)
        
        // Add both stacks to container
        basketTrashContainer.addSubview(basketStack)
        basketTrashContainer.addSubview(trashStack)
        
        // Set up constraints for basket and trash containers
        NSLayoutConstraint.activate([
            basketStack.centerXAnchor.constraint(equalTo: basketTrashContainer.centerXAnchor),
            basketStack.centerYAnchor.constraint(equalTo: basketTrashContainer.centerYAnchor),
            basketStack.widthAnchor.constraint(equalTo: basketTrashContainer.widthAnchor, multiplier: 0.8),
            
            trashStack.centerXAnchor.constraint(equalTo: basketTrashContainer.centerXAnchor),
            trashStack.centerYAnchor.constraint(equalTo: basketTrashContainer.centerYAnchor),
            trashStack.widthAnchor.constraint(equalTo: basketTrashContainer.widthAnchor, multiplier: 0.8),
            
            basketImageView.heightAnchor.constraint(equalTo: basketImageView.widthAnchor),
            trashImageView.heightAnchor.constraint(equalTo: trashImageView.widthAnchor)
        ])
        
        // Initially hide trash stack
        trashStack.alpha = 0
        
        // Set up animation
        func animateContainers() {
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [.curveEaseInOut]) {
                basketStack.alpha = 0
                trashStack.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 1.0, delay: 1.0, options: [.curveEaseInOut]) {
                    basketStack.alpha = 1
                    trashStack.alpha = 0
                } completion: { _ in
                    // Repeat animation
                    animateContainers()
                }
            }
        }
        
        // Start animation
        animateContainers()
        
        let containerLabel = createInstructionLabel(text: "Deposita los productos en el contenedor correcto; Productos que dañan el medio ambiente van en la basura.")
        
        // Continue button
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("¡Comenzar!", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        continueButton.backgroundColor = .accent
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 25
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 30)
        
        // Add tap handler
        continueButton.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    container.alpha = 0
                } completion: { _ in
                    container.removeFromSuperview()
                    // Restore preview container z-index
                    
                    self.tutorialState.hasBeenShown = true
                    self.isGameSetup = true
                    self.wasGameEverSetup = true
                    self.startGameLoop()
                }
            }, for: .touchUpInside)
        
        // Add all elements to content stack
        // Add all elements to content stack
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(15, after: titleLabel)  // Custom spacing after title

        contentStack.addArrangedSubview(gifContainer)
        contentStack.setCustomSpacing(10, after: gifContainer)  // Less space between gif and its label

        contentStack.addArrangedSubview(gifLabel)
        contentStack.setCustomSpacing(-30, after: gifLabel)  // More space after gif section

        contentStack.addArrangedSubview(gameBarContainer)
        contentStack.setCustomSpacing(-65, after: gameBarContainer)  // Less space between GameBar and its label

        contentStack.addArrangedSubview(gameBarLabel)
        contentStack.setCustomSpacing(60, after: gameBarLabel)  // More space after GameBar section

        contentStack.addArrangedSubview(basketTrashContainer)
        contentStack.setCustomSpacing(35, after: basketTrashContainer)  // Space between basket/trash and its label

        contentStack.addArrangedSubview(containerLabel)
        contentStack.setCustomSpacing(30, after: containerLabel)  // More space before button

        contentStack.addArrangedSubview(continueButton)
        
        // Add content stack to scroll view
        scrollView.addSubview(contentStack)
        container.addSubview(scrollView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            basketTrashContainer.heightAnchor.constraint(equalTo: basketTrashContainer.widthAnchor, multiplier: 0.8),
            basketTrashContainer.widthAnchor.constraint(equalTo: contentStack.widthAnchor, multiplier: 0.8)
        ])
        
        // Add container to view and animate in
        addSubview(container)
        tutorialView = container
        
        UIView.animate(withDuration: 0.3) {
            container.alpha = 1
        }
    }
    
    
    private func createInstructionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .darkGray  // Changed to dark gray for white background
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private func createImageContainer(imageName: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        if let image = UIImage(named: imageName) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: container.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.6)
            ])
        }
        
        return container
    }
    
    private func showGameOverSummary() {
        togglePreviewVisibility(show: false)
        let container = UIView(frame: bounds)
        container.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        addSubview(container)
        
        // Check if any red balls were involved in the failure
        let containsRedBalls = failedBalls.contains { ball in
            ballTypes.first(where: { $0.textureName == ball.textureName })?.category == .red
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "¡Perdiste!"
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = containsRedBalls ?
            "Cuidado con estos productos:" :
            "Tiraste los productos saludables a la basura"
        subtitleLabel.font = .systemFont(ofSize: 22, weight: .medium)
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create centered container for balls
        let ballsContainer = UIView()
        ballsContainer.translatesAutoresizingMaskIntoConstraints = false
        ballsContainer.alpha = containsRedBalls ? 1 : 0 // Hide if no red balls
        
        // Description container setup
        let descriptionContainer = UIView()
        descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        descriptionContainer.layer.cornerRadius = 12
        descriptionContainer.alpha = 0  // Start with alpha 0 and don't show it at all for blue balls

        // Product title label
        let productTitleLabel = UILabel()
        productTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        productTitleLabel.textColor = .white
        productTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        productTitleLabel.textAlignment = .center

        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16)

        // Stats container
        let statsContainer = UIStackView()
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.axis = .vertical
        statsContainer.spacing = 8
        statsContainer.alignment = .center
        statsContainer.alpha = containsRedBalls ? 0 : 1
        
        let waterStatsLabel = UILabel()
        let waterEmojis = UIStackView()
        let carbonStatsLabel = UILabel()
        let carbonEmojis = UIStackView()
        
        // Configure water stats
        waterStatsLabel.text = "Consumo de agua:"
        waterStatsLabel.textColor = .white
        waterStatsLabel.font = .systemFont(ofSize: 14)
        
        waterEmojis.spacing = 4
        waterEmojis.alignment = .center
        
        // Configure carbon stats
        carbonStatsLabel.text = "Producción de carbono:"
        carbonStatsLabel.textColor = .white
        carbonStatsLabel.font = .systemFont(ofSize: 14)
        
        carbonEmojis.spacing = 4
        carbonEmojis.alignment = .center
        
        // Clear existing emojis first
        waterEmojis.arrangedSubviews.forEach { $0.removeFromSuperview() }
        carbonEmojis.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Calculate totals for all red balls
        let redBalls = failedBalls.filter { ball in
            ballTypes.first(where: { $0.textureName == ball.textureName })?.category == .red
        }

        redBalls.forEach { ball in
            let waterCount = Int(getWaterImpact(for: ball.textureName) * 10)
            let carbonCount = Int(getCarbonImpact(for: ball.textureName) * 10)
            
            // Add water emojis
            for _ in 0..<waterCount {
                let emoji = UILabel()
                emoji.text = "💧"
                emoji.font = .systemFont(ofSize: 20)
                waterEmojis.addArrangedSubview(emoji)
            }
            for _ in 0..<carbonCount {
                let emojiLabel = UILabel()
                emojiLabel.text = "🏭"
                emojiLabel.font = .systemFont(ofSize: 20)
                carbonEmojis.addArrangedSubview(emojiLabel)
            }
        }
    
                
        if containsRedBalls {
            let lastThreeBalls = Array(failedBalls.suffix(3))
            let containerWidth = bounds.width / 3.5 // Width for each ball container
            let spacing: CGFloat = 10 // Reduced spacing between containers
            let totalWidth = CGFloat(lastThreeBalls.count) * containerWidth + CGFloat(max(0, lastThreeBalls.count - 1)) * spacing
            let startX = (bounds.width - totalWidth) / 2
            
            for (index, ball) in lastThreeBalls.enumerated() {
                let ballContainer = createEnvironmentalImpactContainer(
                    ball: ball,
                    size: CGSize(width: containerWidth, height: containerWidth), // Square size based on width
                    index: index,
                    onTap: { [weak descriptionLabel, weak descriptionContainer, weak productTitleLabel, weak statsContainer] in
                        let description = self.getEnvironmentalDescription(for: ball.textureName)
                        descriptionLabel?.text = description
                        productTitleLabel?.text = ball.textureName
                        
                        // Clear existing emoji stacks
                        statsContainer?.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        
                        // Recreate water stats
                        let waterStatsLabel = UILabel()
                        waterStatsLabel.text = "Consumo de agua:"
                        waterStatsLabel.textColor = .white
                        waterStatsLabel.font = .systemFont(ofSize: 14)
                        statsContainer?.addArrangedSubview(waterStatsLabel)
                        
                        // Create new water emojis
                        let waterEmojis = UIStackView()
                        waterEmojis.spacing = 4
                        waterEmojis.alignment = .center
                        let waterCount = Int(self.getWaterImpact(for: ball.textureName) * 10)
                        for _ in 0..<waterCount {
                            let emoji = UILabel()
                            emoji.text = "💧"
                            emoji.font = .systemFont(ofSize: 20)
                            waterEmojis.addArrangedSubview(emoji)
                        }
                        statsContainer?.addArrangedSubview(waterEmojis)
                        
                        // Create carbon stats
                        let carbonStatsLabel = UILabel()
                        carbonStatsLabel.text = "Producción de carbono:"
                        carbonStatsLabel.textColor = .white
                        carbonStatsLabel.font = .systemFont(ofSize: 14)
                        statsContainer?.addArrangedSubview(carbonStatsLabel)
                        
                        // Create new carbon emojis
                        let carbonEmojis = UIStackView()
                        carbonEmojis.spacing = 4
                        carbonEmojis.alignment = .center
                        let carbonCount = Int(self.getCarbonImpact(for: ball.textureName) * 10)
                        for _ in 0..<carbonCount {
                            let emojiLabel = UILabel()
                            emojiLabel.text = "🏭"
                            emojiLabel.font = .systemFont(ofSize: 20)
                            carbonEmojis.addArrangedSubview(emojiLabel)
                        }
                        statsContainer?.addArrangedSubview(carbonEmojis)
                        
                        // Prepare containers
                        descriptionContainer?.alpha = 0
                        statsContainer?.alpha = 0
                        let transform = CGAffineTransform(translationX: 0, y: 30)
                        descriptionContainer?.transform = transform
                        
                        // Animate description appearance
                        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut) {
                            descriptionContainer?.alpha = 1
                            descriptionContainer?.transform = .identity
                            statsContainer?.alpha = 1
                        } completion: { _ in
                            // Animate emojis
                            waterEmojis.arrangedSubviews.enumerated().forEach { index, emoji in
                                UIView.animate(withDuration: 0.2, delay: Double(index) * 0.1) {
                                    emoji.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                } completion: { _ in
                                    UIView.animate(withDuration: 0.2) {
                                        emoji.transform = .identity
                                    }
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                carbonEmojis.arrangedSubviews.enumerated().forEach { index, emoji in
                                    UIView.animate(withDuration: 0.2, delay: Double(index) * 0.1) {
                                        emoji.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                                    } completion: { _ in
                                        UIView.animate(withDuration: 0.2) {
                                            emoji.transform = .identity
                                        }
                                    }
                                }
                            }
                        }
                    }
                )
                
                ballContainer.frame.origin.x = startX + CGFloat(index) * (containerWidth + spacing)
                ballsContainer.addSubview(ballContainer)
            }
            descriptionContainer.alpha = 0  // Start hidden, will be shown on tap
        } else {
            // Create sad face for blue ball failure case
            let sadFaceLabel = UILabel()
            sadFaceLabel.text = "😢"
            sadFaceLabel.font = .systemFont(ofSize: 120)
            sadFaceLabel.textAlignment = .center
            sadFaceLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Create empty containers just for proper layout but keep them hidden
            let ballsContainer = UIView()
            ballsContainer.translatesAutoresizingMaskIntoConstraints = false
            ballsContainer.isHidden = true
            
            let descriptionContainer = UIView()
            descriptionContainer.translatesAutoresizingMaskIntoConstraints = false
            descriptionContainer.isHidden = true
            
            let statsContainer = UIStackView()
            statsContainer.translatesAutoresizingMaskIntoConstraints = false
            statsContainer.isHidden = true
            
            container.addSubview(sadFaceLabel)
            container.addSubview(ballsContainer)
            container.addSubview(descriptionContainer)
            container.addSubview(statsContainer)
            
            NSLayoutConstraint.activate([
                sadFaceLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                sadFaceLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            // Add bounce animation to sad face
            UIView.animate(
                withDuration: 1.5,
                delay: 0.5,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [.repeat, .autoreverse]
            ) {
                sadFaceLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            }
        }
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.alignment = .center
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonWidth = min(bounds.width * 0.8, 400)
        
        let playAgainButton = createStyledButton(
            title: "Volver a jugar",
            symbolName: "arrow.counterclockwise.circle.fill",
            backgroundColor: .systemBlue,
            width: buttonWidth
        ) { [weak self] in
            self?.resetGame()
        }
        
        let mainMenuButton = createStyledButton(
            title: "Pantalla Principal",
            symbolName: "chevron.backward.circle.fill",
            backgroundColor: .systemGray,
            width: buttonWidth
        ) { [weak self] in
            self?.mainMenuCallback?()
        }
        
        buttonsStack.addArrangedSubview(playAgainButton)
        buttonsStack.addArrangedSubview(mainMenuButton)
        
        // Add all elements to container
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(ballsContainer)
        container.addSubview(descriptionContainer)
        container.addSubview(buttonsStack)
        
        // Add elements to description container
        descriptionContainer.addSubview(productTitleLabel)
        descriptionContainer.addSubview(descriptionLabel)
        descriptionContainer.addSubview(statsContainer)
        
        // Add stats to stats container
        statsContainer.addArrangedSubview(waterStatsLabel)
        statsContainer.addArrangedSubview(waterEmojis)
        statsContainer.addArrangedSubview(carbonStatsLabel)
        statsContainer.addArrangedSubview(carbonEmojis)
        
        NSLayoutConstraint.activate([
            // Container
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // Balls container
            ballsContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            ballsContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            ballsContainer.heightAnchor.constraint(equalToConstant: 200),
            ballsContainer.widthAnchor.constraint(equalTo: container.widthAnchor),
            
            // Description container
            descriptionContainer.topAnchor.constraint(equalTo: ballsContainer.bottomAnchor, constant: -120),
            descriptionContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            descriptionContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // Product title
            productTitleLabel.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 16),
            productTitleLabel.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 16),
            productTitleLabel.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -16),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: productTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -16),
            
            // Stats container
            statsContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            statsContainer.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 16),
            statsContainer.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor, constant: -16),
            statsContainer.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor, constant: -16),
            
            // Buttons stack
            buttonsStack.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonsStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5
        ) {
            container.alpha = 1
            container.transform = .identity
        }
        
        summaryView = container
    }
    
    private struct AssociatedKeys {
        static var tapCallback = "tapCallback"
        static var hasAnimated = "hasAnimated"
    }

    private func createEnvironmentalImpactContainer(ball: (textureName: String, timestamp: Date), size: CGSize, index: Int, onTap: @escaping () -> Void) -> UIView {
        let containerWidth = UIScreen.main.bounds.width / 3.5
        let container = UIView(frame: CGRect(origin: .zero, size: CGSize(width: containerWidth, height: 160)))
        container.alpha = 0
        
        // Make container tappable
        container.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleContainerTap(_:)))
        container.addGestureRecognizer(tapGesture)
        
        
        // Store both the callback and animation state
        objc_setAssociatedObject(container, &AssociatedKeys.tapCallback, onTap, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(container, &AssociatedKeys.hasAnimated, false, .OBJC_ASSOCIATION_RETAIN)
        
        // Ball image with adjusted size
        let imageSize = CGSize(width: containerWidth * 0.8, height: containerWidth * 0.8)
        let imageView = UIImageView(image: UIImage(named: ball.textureName))
        imageView.frame = CGRect(origin: CGPoint(x: (containerWidth - imageSize.width)/2, y: 0), size: imageSize)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageSize.width / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        // Rest of the UI setup...
        let nameLabel = UILabel(frame: CGRect(x: 0, y: imageSize.height + 8, width: containerWidth, height: 20))
        nameLabel.text = ball.textureName
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        
        let waterContainer = createImpactBar(
            emoji: "💧",
            title: "Consumo de agua",
            value: getWaterImpact(for: ball.textureName),
            color: .systemBlue,
            frame: CGRect(x: 0, y: imageSize.height + 36, width: containerWidth, height: 24)
        )
        
        let carbonContainer = createImpactBar(
            emoji: "🏭",
            title: "Producción de carbono",
            value: getCarbonImpact(for: ball.textureName),
            color: .systemGray,
            frame: CGRect(x: 0, y: imageSize.height + 68, width: containerWidth, height: 24)
        )
        
        container.addSubview(imageView)
        container.addSubview(nameLabel)
        container.addSubview(waterContainer)
        container.addSubview(carbonContainer)
        
        // Animate each container
        UIView.animate(
            withDuration: 0.5,
            delay: Double(index) * 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            container.alpha = 1
        }
        
        return container
    }
  

    @objc private func handleContainerTap(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view else { return }
        
        // Get the stored callback
        if let callback = objc_getAssociatedObject(container, &AssociatedKeys.tapCallback) as? () -> Void {
            // Check if we've already animated
            let hasAnimated = (objc_getAssociatedObject(container, &AssociatedKeys.hasAnimated) as? Bool) ?? false
            
            if hasAnimated {
                // If already animated, just execute the callback
                callback()
                return
            }
            
            // Mark as animated
            objc_setAssociatedObject(container, &AssociatedKeys.hasAnimated, true, .OBJC_ASSOCIATION_RETAIN)
            
            // First, scale up the balls container
            if let ballsContainer = container.superview {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                    ballsContainer.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                } completion: { _ in
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                        ballsContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            .translatedBy(x: 0, y: -130)
                    }
                    
                    // Execute the callback after a slight delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        callback()
                    }
                }
            }
        }
    }

    private func getEnvironmentalDescription(for brand: String) -> String {
        switch brand {
        case "Pepsi":
            return "Pepsi contribuye significativamente al uso excesivo de agua y la producción de plástico. Una botella de 500ml requiere 3 litros de agua en su producción. Además, PepsiCo genera más de 2.3 millones de toneladas de plástico al año."
        case "Cheetos":
            return "La producción de Cheetos tiene un alto impacto ambiental debido al aceite de palma utilizado, que contribuye a la deforestación. También genera una significativa huella de carbono en su proceso de fabricación y empaquetado."
        case "Takis":
            return "Takis utiliza aceites procesados y empaques no biodegradables que contribuyen a la contaminación. Su producción requiere grandes cantidades de energía y agua, además de generar emisiones significativas de gases de efecto invernadero."
        case "Coca-Cola":
            return "Coca-Cola es uno de los mayores productores de residuos plásticos a nivel mundial. Sus botellas de plástico contribuyen a la contaminación por plástico, y el uso de agua de la compañía ha generado preocupaciones sobre el agotamiento de los recursos hídricos locales."
        case "Nestle":
            return "Nestlé ha sido criticada por sus prácticas de embotellamiento de agua, que pueden agotar los suministros de agua locales. La compañía también genera una cantidad sustancial de residuos plásticos a través de sus empaques."
        case "McDonalds":
            return "El impacto ambiental de McDonald's incluye emisiones significativas de gases de efecto invernadero por la ganadería para la producción de carne de res. La compañía contribuye a la deforestación y genera grandes cantidades de residuos de empaques."
        case "Starbucks":
            return "Starbucks ha enfrentado críticas por sus vasos desechables y popotes de plástico, contribuyendo a los desechos y la contaminación. Las operaciones globales de la compañía también contribuyen a las emisiones de carbono."
        case "Monster":
            return "Monster Beverage produce bebidas energéticas enlatadas y embotelladas en plástico de un solo uso, contribuyendo a los residuos. El proceso de producción también consume energía y recursos."
        default:
            return "Este producto tiene un impacto significativo en el medio ambiente a través de su producción y empaquetado."
        }
    }

  private func createImpactBar(emoji: String, title: String, value: CGFloat, color: UIColor, frame: CGRect) -> UIView {
      let container = UIView(frame: frame)
      
      let titleStack = UIStackView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 16))
      titleStack.axis = .horizontal
      titleStack.spacing = 4
      
      let emojiLabel = UILabel()
      emojiLabel.text = emoji
      emojiLabel.font = .systemFont(ofSize: 14)
      
      let titleLabel = UILabel()
      titleLabel.text = title
      titleLabel.font = .systemFont(ofSize: 12)
      titleLabel.textColor = .white
      
      titleStack.addArrangedSubview(emojiLabel)
      titleStack.addArrangedSubview(titleLabel)
      
      let progressBar = UIProgressView(progressViewStyle: .default)
      progressBar.frame = CGRect(x: 0, y: 20, width: frame.width, height: 4)
      progressBar.progressTintColor = color
      progressBar.progress = Float(value)
      progressBar.layer.cornerRadius = 2
      progressBar.clipsToBounds = true
      
      container.addSubview(titleStack)
      container.addSubview(progressBar)
      
      return container
  }

    private func getWaterImpact(for brand: String) -> CGFloat {
        // Return water impact values between 0 and 1
        switch brand {
        case "Pepsi":
            return 0.8
        case "Cheetos":
            return 0.6
        case "Takis":
            return 0.7
        case "Coca-Cola":
            return 0.85
        case "Nestle":
            return 0.9
        case "McDonalds":
            return 0.75
        case "Starbucks":
            return 0.7
        case "Monster":
            return 0.65
        default:
            return 0.5
        }
    }

    private func getCarbonImpact(for brand: String) -> CGFloat {
        // Return carbon impact values between 0 and 1
        switch brand {
        case "Pepsi":
            return 0.9
        case "Cheetos":
            return 0.7
        case "Takis":
            return 0.8
        case "Coca-Cola":
            return 0.95
        case "Nestle":
            return 0.85
        case "McDonalds":
            return 0.8
        case "Starbucks":
            return 0.75
        case "Monster":
            return 0.7
        default:
            return 0.6
        }
    }

  // Helper function to calculate dynamic ball size based on number of balls
  private func calculateBallSize(for ballCount: Int) -> CGSize {
      let screenWidth = bounds.width
      let availableWidth = screenWidth * 0.8 // 80% of screen width
      
      switch ballCount {
      case 1:
          return CGSize(width: 120, height: 120)
      case 2:
          return CGSize(width: 100, height: 100)
      case 3:
          return CGSize(width: 90, height: 90)
      default:
          return CGSize(width: 90, height: 90)
      }
  }

  // Helper function to create ball container with dynamic sizing
  private func createBallContainer(ball: (textureName: String, timestamp: Date), size: CGSize, index: Int) -> UIView {
      let ballContainer = UIView()
      ballContainer.translatesAutoresizingMaskIntoConstraints = false
      ballContainer.alpha = 0
      
      // Ball image
      let imageView = UIImageView(image: UIImage(named: ball.textureName))
      imageView.contentMode = .scaleAspectFit
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.layer.cornerRadius = size.width / 2
      imageView.clipsToBounds = true
      imageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
      
      // Ball label
      let label = UILabel()
      label.text = ball.textureName
      label.font = .systemFont(ofSize: min(22, size.width / 4), weight: .medium)
      label.textColor = .white
      label.textAlignment = .center
      label.translatesAutoresizingMaskIntoConstraints = false
      
      ballContainer.addSubview(imageView)
      ballContainer.addSubview(label)
      
      NSLayoutConstraint.activate([
          imageView.centerXAnchor.constraint(equalTo: ballContainer.centerXAnchor),
          imageView.topAnchor.constraint(equalTo: ballContainer.topAnchor),
          imageView.widthAnchor.constraint(equalToConstant: size.width),
          imageView.heightAnchor.constraint(equalToConstant: size.height),
          
          label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
          label.centerXAnchor.constraint(equalTo: ballContainer.centerXAnchor),
          label.bottomAnchor.constraint(equalTo: ballContainer.bottomAnchor),
          
          ballContainer.widthAnchor.constraint(equalToConstant: size.width * 1.5),
          ballContainer.heightAnchor.constraint(equalToConstant: size.height * 1.5)
      ])
      
      // Animate each ball container
      UIView.animate(
          withDuration: 0.5,
          delay: Double(index) * 0.2 + 0.3,
          usingSpringWithDamping: 0.7,
          initialSpringVelocity: 0.5
      ) {
          ballContainer.alpha = 1
      }
      
      return ballContainer
  }

  // Helper method to create styled buttons
  // Updated createStyledButton with width parameter
  private func createStyledButton(
      title: String,
      symbolName: String,
      backgroundColor: UIColor,
      width: CGFloat,
      action: @escaping () -> Void
  ) -> UIButton {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      
      // Create symbol image configuration
      let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
      let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)
      
      // Create attachment for symbol
      let imageAttachment = NSTextAttachment()
      imageAttachment.image = symbolImage?.withTintColor(.white)
      let imageString = NSAttributedString(attachment: imageAttachment)
      
      // Create title attributes
      let titleAttributes: [NSAttributedString.Key: Any] = [
          .font: UIFont.systemFont(ofSize: 20, weight: .bold),
          .foregroundColor: UIColor.white
      ]
      let titleString = NSAttributedString(string: " " + title, attributes: titleAttributes)
      
      // Combine symbol and title
      let combinedString = NSMutableAttributedString()
      combinedString.append(imageString)
      combinedString.append(titleString)
      
      button.setAttributedTitle(combinedString, for: .normal)
      button.backgroundColor = backgroundColor
      button.layer.cornerRadius = 15
      button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 40, bottom: 15, right: 40)
      button.layer.shadowColor = UIColor.black.cgColor
      button.layer.shadowOffset = CGSize(width: 0, height: 2)
      button.layer.shadowRadius = 5
      button.layer.shadowOpacity = 0.2
      
      // Add action
      button.addAction(UIAction { _ in action() }, for: .touchUpInside)
      
      // Set dynamic width
      button.widthAnchor.constraint(equalToConstant: width).isActive = true
      
      return button
  }
        
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor is ARPlaneAnchor {
                planeDetected = true  // Set this to true when a plane is detected
                // Don't show tap instruction immediately - it will be shown when coaching overlay deactivates
            }
        }
    }
    
    private func showTapInstruction() {
        // Remove old instruction if it exists
        tapInstructionView?.removeFromSuperview()
        
        // Create container without blur
        let instructionView = UIView()
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        instructionView.alpha = 0
        
        // Create stack view for vertical arrangement
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create large tap icon
        let tapIcon = UIImageView(image: UIImage(systemName: "hand.tap.fill"))
        tapIcon.contentMode = .scaleAspectFit
        tapIcon.tintColor = .white
        tapIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // Create instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Toca para jugar"
        instructionLabel.font = .systemFont(ofSize: 17, weight: .medium)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to hierarchy
        stackView.addArrangedSubview(tapIcon)
        stackView.addArrangedSubview(instructionLabel)
        instructionView.addSubview(stackView)
        addSubview(instructionView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            instructionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            instructionView.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            instructionView.heightAnchor.constraint(equalToConstant: 160),
            
            stackView.centerXAnchor.constraint(equalTo: instructionView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: instructionView.centerYAnchor),
            
            tapIcon.widthAnchor.constraint(equalToConstant: 60),
            tapIcon.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Update the stored reference (change the type in your property declaration if needed)
        self.tapInstructionView = instructionView
        
        // Animate appearance
        instructionView.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            instructionView.alpha = 1
            instructionView.transform = .identity
        }
        
        // Add pulsing animation to tap icon
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        tapIcon.layer.add(pulseAnimation, forKey: "pulse")
    }
    

    
  // Modify the init method to setup lives display
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        currentBallType = ballTypes.randomElement()
        setupMotionManager()
        setupAR()
        setupPreviewImage()
        setupCoachingOverlay()
    }
    
    private func setupCoachingOverlay() {
        coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = session
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.delegate = self
        
        // Make the coaching overlay transparent
        coachingOverlay.backgroundColor = .clear
        
        // Function to recursively clear backgrounds
        func clearBackgrounds(in view: UIView) {
            view.backgroundColor = .clear
            if let effectView = view as? UIVisualEffectView {
                effectView.effect = nil
            }
            for subview in view.subviews {
                clearBackgrounds(in: subview)
            }
        }
        
        // Initial clear
        clearBackgrounds(in: coachingOverlay)
        
        // Delayed clear to catch any dynamically added views
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            clearBackgrounds(in: self.coachingOverlay)
        }
        
        addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: centerYAnchor),
            coachingOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            coachingOverlay.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // Add method to set up lives display
    private func setupLivesDisplay() {
        let container = UIStackView()
        container.axis = .horizontal  // Changed to horizontal
        container.spacing = 4
        container.distribution = .fillEqually
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.layer.cornerRadius = 12
        container.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        container.isLayoutMarginsRelativeArrangement = true
        container.alpha = 0.0
        
        // Create hearts
        heartViews.removeAll()
        for i in 0..<3 {
            let heartLabel = UILabel()
            heartLabel.text = i < lives ? "💚" : "🖤"
            heartLabel.font = .systemFont(ofSize: 20) // Slightly smaller hearts
            heartLabel.textAlignment = .center
            
            container.addArrangedSubview(heartLabel)
            heartViews.append(heartLabel)
        }

        // Create blur effect background for all top UI elements
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0.8
        blurView.layer.cornerRadius = 12
        blurView.clipsToBounds = true
        
        addSubview(blurView)
        addSubview(container)
        self.heartsContainer = container

        NSLayoutConstraint.activate([
            // Blur view constraints to cover all top UI elements
            blurView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            blurView.heightAnchor.constraint(equalToConstant: 60),

            // Hearts container
            container.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            container.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Update preview container and ball counter constraints to align with blur background
        if let previewContainer = previewContainer {
            previewContainer.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
            previewContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        }
        
        if let ballCountLabel = ballCountLabel?.superview {
            ballCountLabel.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
            ballCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        }

        // Animate in the hearts display
        UIView.animate(withDuration: 0.5) {
            container.alpha = 1.0
        }
    }
    
    // Replace your current updateLivesDisplay method with this one:
    private func updateLivesDisplay() {
        guard let container = heartsContainer else { return }
        
        // Remove existing hearts
        container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        heartViews.removeAll()
        
        // Create new hearts
        for i in 0..<3 {
            let heartLabel = UILabel()
            heartLabel.text = i < lives ? "💚" : "🖤"
            heartLabel.font = .systemFont(ofSize: 24)
            heartLabel.textAlignment = .center
            
            // Add to container and array
            container.addArrangedSubview(heartLabel)
            heartViews.append(heartLabel)
            
            // Animate new hearts
            heartLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(
                withDuration: 0.5,
                delay: Double(i) * 0.15,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5
            ) {
                heartLabel.transform = .identity
            }
        }
    }
  
    private func animateLostLife() {
            guard lives >= 0, lives < heartViews.count else { return }
            
            let heartToAnimate = heartViews[lives]
            
            // Sequence of animations
            UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [], animations: {
                // First keyframe: Expand
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
                    heartToAnimate.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }
                
                // Second keyframe: Shake
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                    heartToAnimate.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                        .rotated(by: .pi / 8)
                }
                
                // Third keyframe: Shake other direction
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.2) {
                    heartToAnimate.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                        .rotated(by: -.pi / 8)
                }
                
                // Final keyframe: Return to normal size with gray heart
                UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                    heartToAnimate.transform = .identity
                    heartToAnimate.text = "🖤"
                }
            })
        }
    
    private func setupPreviewImage() {
        // Create container with blur background
        let containerView = UIView()
        containerView.alpha = 0
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create horizontal stack view to hold name and image
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4  // Reduced spacing from 8 to 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up name label
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.text = currentBallType?.textureName ?? ""
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up image container view with clear background
        let imageContainerView = UIView()
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.clipsToBounds = true
        imageContainerView.backgroundColor = .clear
        
        // Set up image view
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        
        // Set initial image
        if let currentBallType = currentBallType {
            imageView.image = UIImage(named: currentBallType.textureName)
        }
        
        // Add views to hierarchy
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        containerView.addSubview(stackView)
        
        // Ensure the preview stays on top of other views
        containerView.layer.zPosition = 2
        
        addSubview(containerView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 18),
            containerView.widthAnchor.constraint(equalToConstant: 120),  // Slightly reduced width since we reduced spacing
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Stack view constraints
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),  // Reduced padding
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),  // Reduced padding
            
            // Image container constraints
            imageContainerView.widthAnchor.constraint(equalToConstant: 30),
            imageContainerView.heightAnchor.constraint(equalToConstant: 30),
            
            // Image view constraints
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 25),
            imageView.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        previewImageView = imageView
        previewContainer = containerView
        imageContainer = imageContainerView
        previewLabel = nameLabel
        
        // Make sure initial image is set
        updatePreviewImage(animated: false)
    }

    private func updatePreviewImage(animated: Bool = true) {
        guard let currentBallType = currentBallType,
              let newImage = UIImage(named: currentBallType.textureName) else {
            print("Failed to load image for ball type: \(String(describing: currentBallType?.textureName))")
            return
        }
        
        // Update the name label
        previewLabel?.text = currentBallType.textureName
        
        if animated {
            guard let imageContainer = imageContainer else { return }
            
            let newImageView = UIImageView(image: newImage)
            newImageView.contentMode = .scaleAspectFit
            newImageView.translatesAutoresizingMaskIntoConstraints = false
            newImageView.clipsToBounds = true
            newImageView.alpha = 0
            
            imageContainer.addSubview(newImageView)
            
            NSLayoutConstraint.activate([
                newImageView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
                newImageView.widthAnchor.constraint(equalToConstant: 35),
                newImageView.heightAnchor.constraint(equalToConstant: 35)
            ])
            
            let horizontalConstraint = newImageView.centerXAnchor.constraint(
                equalTo: imageContainer.centerXAnchor,
                constant: 100
            )
            horizontalConstraint.isActive = true
            
            imageContainer.layoutIfNeeded()
            
            // Animate old image out
            if let oldImageView = previewImageView {
                UIView.animate(withDuration: 0.3, animations: {
                    oldImageView.alpha = 0
                    oldImageView.transform = CGAffineTransform(translationX: -100, y: 0)
                }) { _ in
                    oldImageView.removeFromSuperview()
                }
            }
            
            // Animate new image in
            UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseOut, animations: {
                newImageView.alpha = 1
                horizontalConstraint.constant = 0
                imageContainer.layoutIfNeeded()
                
                // Animate the text change
                self.previewLabel?.alpha = 0
                self.previewLabel?.text = currentBallType.textureName
                self.previewLabel?.alpha = 1
            }) { _ in
                self.previewImageView = newImageView
            }
        } else {
            previewImageView?.image = newImage
            previewLabel?.text = currentBallType.textureName
        }
    }
    
    private func setupAR() {
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            session.delegate = self
            session.run(config)
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapRecognizer)
        }
    
        
    private func showInstructions() {
        let instructionText = "Tap on a horizontal surface to place the game"
        
        // Create a UILabel
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: frame.width, height: 50))
        label.text = instructionText
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.tag = 100 // For easy removal later
        
        DispatchQueue.main.async {
            if let rootView = self.window?.rootViewController?.view {
                rootView.addSubview(label)
            }
        }
    }

    
    private func removeInstructions() {
        DispatchQueue.main.async {
            if let rootView = self.window?.rootViewController?.view {
                rootView.viewWithTag(100)?.removeFromSuperview()
            }
        }
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        // First check if the game was ever set up
        if wasGameEverSetup {
            if gameOver {
                resetGame()
            }
            return
        }
        
        // Check if game is already running
        if isGameSetup {
            return
        }
        
        // Make sure we've detected a plane
        guard planeDetected else { return }
        
        let tapLocation = recognizer.location(in: self)
        
        if let result = raycast(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
            // Remove tap instruction first
            removeTapInstruction()
            
            // Set up anchor and game elements
            let anchor = AnchorEntity(world: result.worldTransform)
            gameAnchor = anchor
            setupGameElements(anchor: anchor)
            scene.addAnchor(anchor)
            
            // Set up UI elements first
            createPreviewObject()
            setupLivesDisplay()
            setupBallCounter()
            
            // Animate in the UI elements
            UIView.animate(withDuration: 0.5) {
                self.previewContainer?.alpha = 1
                self.heartsContainer?.alpha = 0.0
            } completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.3) {
                    self.heartsContainer?.alpha = 1.0
                }
            }
            
            // Show tutorial or start game
            if !tutorialState.hasBeenShown {
                showTutorialScreen()
            } else {
                isGameSetup = true
                wasGameEverSetup = true
                startGameLoop()
            }
        }
    }
    
    
    private func removeTapInstruction() {
        guard let tapInstructionView = tapInstructionView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            tapInstructionView.alpha = 0
            tapInstructionView.transform = CGAffineTransform(translationX: 0, y: 50)
        }) { _ in
            tapInstructionView.removeFromSuperview()
            self.tapInstructionView = nil
        }
    }
    
        
    private func setupGameElements(anchor: AnchorEntity) {
        // Create platform
        let platformMesh = MeshResource.generateBox(width: 0.8, height: 0.02, depth: 0.15)
        platformEntity = ModelEntity(mesh: platformMesh, materials: [SimpleMaterial(color: .white, isMetallic: true)])
        platformEntity?.generateCollisionShapes(recursive: true)
        platformEntity?.orientation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        
        var platformPhysics = PhysicsBodyComponent()
        platformPhysics.mode = .kinematic
        platformEntity?.components[PhysicsBodyComponent.self] = platformPhysics
        
        // Create side barrier walls
        let wallHeight: Float = 1.0// Height of the barrier
        let wallThickness: Float = 0.02 // Thickness of the barrier
        let platformWidth: Float = 0.8 // Match the platform width
        let platformDepth: Float = 0.15 // Match the platform depth
        
        // Create front barrier wall (closer to camera)
        let frontWallMesh = MeshResource.generateBox(width: platformWidth, height: wallHeight, depth: wallThickness)
        let invisibleMaterial = UnlitMaterial(
            color: .clear.withAlphaComponent(0)
        )

        let frontWall = ModelEntity(
            mesh: frontWallMesh,
            materials: [invisibleMaterial]
        )
        frontWall.position = [0, wallHeight/2, platformDepth/2]
        frontWall.generateCollisionShapes(recursive: true)
        var frontWallPhysics = PhysicsBodyComponent()
        frontWallPhysics.mode = .kinematic
        frontWall.components[PhysicsBodyComponent.self] = frontWallPhysics

        // Create back barrier wall (farther from camera)
        let backWallMesh = MeshResource.generateBox(width: platformWidth, height: wallHeight, depth: wallThickness)
        let backWall = ModelEntity(
            mesh: backWallMesh,
            materials: [invisibleMaterial]  // Use the same invisible material
        )
        backWall.position = [0, wallHeight/2, -platformDepth/2]
        backWall.generateCollisionShapes(recursive: true)
        var backWallPhysics = PhysicsBodyComponent()
        backWallPhysics.mode = .kinematic
        backWall.components[PhysicsBodyComponent.self] = backWallPhysics
        
        leftBin = createBucket(color: redMaterial, position: [-0.5, -1.0, 0], isRed: true)
        rightBin = createBucket(color: blueMaterial, position: [0.5, -1.0, 0], isRed: false)
        
        // Add elements to platform
        if let platform = platformEntity {
            platform.position = [0, -0.2, 0]
            
            // Add walls as children of the platform so they move with it
            platform.addChild(frontWall)
            platform.addChild(backWall)
            
            // Add platform to anchor
            anchor.addChild(platform)
            
            // Add bins
            if let left = leftBin, let right = rightBin {
                anchor.addChild(left)
                anchor.addChild(right)
            }
        }
    }
        
        private func startGameLoop() {
            // Clear any existing timer
            gameTimer?.invalidate()
            gameTimer = nil
            
            // Start new timer
            gameTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                self?.dropCurrentObject()
            }
        }
        
    // Modify resetGame to remove all balls
    private func resetGame() {
            togglePreviewVisibility(show: false)
            // Remove all game over views with animation
            if let summaryView = summaryView {
                UIView.animate(
                    withDuration: 0.3,
                    animations: {
                        summaryView.alpha = 0
                        summaryView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }
                ) { _ in
                    summaryView.removeFromSuperview()
                    self.summaryView = nil
                }
            }
            
            // Remove game over text entity
            gameOverText?.removeFromParent()
            gameOverText = nil
            
            // Reset game state
            isGameSetup = true
            gameOver = false
            isShowingGameOver = false // Reset this flag
            lives = 3
            ballsRemaining = 10
            failedBalls.removeAll()
            redCategoryBallsCaptured.removeAll()
            blueCategoryBallsCaptured.removeAll()
            
            // Update UI elements
            updateLivesDisplay()
            updateBallCounter()
            pulseRemainingHearts()
            
            // Clean up scene
            gameAnchor?.children.forEach { entity in
                if entity != platformEntity && entity != leftBin && entity != rightBin {
                    entity.removeFromParent()
                }
            }
            
            // Set up new preview
            currentBallType = ballTypes.randomElement()
            createPreviewObject()
            updatePreviewImage(animated: true)
            
            // Animate UI elements
            UIView.animate(withDuration: 0.5) {
                self.previewContainer?.alpha = 1
            }
            
            // Add visual feedback for reset
            let flashView = UIView(frame: bounds)
            flashView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            flashView.alpha = 0
            addSubview(flashView)
            
            UIView.animate(withDuration: 0.3, animations: {
                flashView.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, animations: {
                    flashView.alpha = 0
                }) { _ in
                    flashView.removeFromSuperview()
                }
            }
            
            // Restart game loop
            startGameLoop()
        }
      
    // Store ball types using a tag component
    private struct BallTypeComponent: Component {
            var textureName: String
            var category: BallCategory
        }
    
    private func checkBallPosition(_ ball: ModelEntity) {
        guard !gameOver,
              let leftBin = leftBin,
              let ballType = ball.components[BallTypeComponent.self] else { return }
        
        let ballWorldPosition = ball.position(relativeTo: gameAnchor)
        let bucketWorldPosition = leftBin.position(relativeTo: gameAnchor)
        
        // Adjusted bucket detection ranges for more accurate detection
        let bucketRadius: Float = 0.4  // Increased detection radius
        let bucketDepth: Float = 0.4   // Depth of detection zone
        let bucketHeight: Float = 0.6  // Increased height check
        
        // More precise bucket detection with expanded range
        let isInRedBucket = abs(ballWorldPosition.x - bucketWorldPosition.x) < bucketRadius &&
                           abs(ballWorldPosition.z - bucketWorldPosition.z) < bucketDepth &&
                           ballWorldPosition.y < bucketWorldPosition.y + bucketHeight
        
        let rightBucketPosition = rightBin?.position(relativeTo: gameAnchor) ?? .zero
        let isInBlueBucket = abs(ballWorldPosition.x - rightBucketPosition.x) < bucketRadius &&
                            abs(ballWorldPosition.z - rightBucketPosition.z) < bucketDepth &&
                            ballWorldPosition.y < rightBucketPosition.y + bucketHeight
        
        // Only process the ball once
        if ball.components[BallCountedComponent.self] == nil {
            // Handle ball landing in red bucket
            if isInRedBucket {
                ball.components[BallCountedComponent.self] = BallCountedComponent()
                
                if ballType.category == .blue {
                    showLifeLostEffect()
                    animateLostLife()
                    
                    DispatchQueue.main.async {
                        self.lives -= 1
                        self.updateLivesDisplay()
                        
                        if self.lives <= 0 {
                            self.gameOver = true
                            self.showGameOver()
                        }
                    }
                } else {
                    redCategoryBallsCaptured.insert(ballType.textureName)
                }
            }
            // Handle ball landing in blue bucket
            else if isInBlueBucket {
                ball.components[BallCountedComponent.self] = BallCountedComponent()
                
                if ballType.category == .red {
                    if !failedBalls.contains(where: { $0.textureName == ballType.textureName }) {
                        recordFailedBall(textureName: ballType.textureName, category: ballType.category)
                    }
                    
                    showLifeLostEffect()
                    animateLostLife()
                    
                    DispatchQueue.main.async {
                        self.lives -= 1
                        self.updateLivesDisplay()
                        
                        if self.lives <= 0 {
                            self.gameOver = true
                            self.showGameOver()
                        }
                    }
                } else {
                    blueCategoryBallsCaptured.insert(ballType.textureName)
                    if blueCategoryBallsCaptured.count >= 5 {
                        gameOver = true
                        showGameOver()
                    }
                }
            }
        }
    }


    // Add a new component to mark balls as fully processed
    private struct ProcessedComponent: Component {
        init() {}
    }
    
  
    // Add pulse animation for remaining hearts when game starts/resets
    private func pulseRemainingHearts() {
        for (index, heartView) in heartViews.enumerated() {
            if index < lives {
                UIView.animate(
                    withDuration: 0.3,
                    delay: Double(index) * 0.1,
                    options: [.autoreverse, .repeat, .curveEaseInOut],
                    animations: {
                        heartView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    }
                )
                
                // Stop the animation after 3 pulses
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    UIView.animate(withDuration: 0.2) {
                        heartView.transform = .identity
                    }
                }
            }
        }
    }
    
    // Add visual effect for losing a life
    private func showLifeLostEffect() {
        let flashView = UIView(frame: bounds)
        flashView.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        flashView.alpha = 0
        addSubview(flashView)
        
        UIView.animate(withDuration: 0.2, animations: {
            flashView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                flashView.alpha = 0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }
    }
  
    private func printBallPositions() {
        guard let gameAnchor = gameAnchor else { return }
        
        gameAnchor.children.forEach { entity in
            if let ball = entity as? ModelEntity,
               let ballType = ball.components[BallTypeComponent.self] {
                let position = ball.position(relativeTo: gameAnchor)
                print("Ball \(ballType.textureName) position: x:\(position.x), y:\(position.y), z:\(position.z)")
            }
        }
    }
    
    // Add a new component to track counted balls
    private struct BallCountedComponent: Component {
        init() {}
    }
    
    private func showVictoryScreen() {
        togglePreviewVisibility(show: false)
        
        // Create the main container
        let container = UIView(frame: bounds)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Create and configure blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a white overlay to make the blur more white
        let whiteOverlay = UIView()
        whiteOverlay.translatesAutoresizingMaskIntoConstraints = false
        whiteOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        // Add views to hierarchy
        container.addSubview(blurView)
        container.addSubview(whiteOverlay)
        addSubview(container)
        
        // Title setup
        let titleLabel = UILabel()
        titleLabel.text = "¡Felicitaciones!"
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = .black // Changed to black for white background
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Has ganado una insignia de comprador consciente"
        subtitleLabel.font = .systemFont(ofSize: 22, weight: .medium)
        subtitleLabel.textColor = .darkGray // Changed to dark gray for white background
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Badge container setup
        let badgeContainer = UIView()
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create shine view with mask
        let shineView = UIView()
        shineView.alpha = 0
        shineView.translatesAutoresizingMaskIntoConstraints = false
        
        let shineLayer = CAGradientLayer()
        shineLayer.type = .radial
        shineLayer.colors = [
            UIColor.white.withAlphaComponent(0.8).cgColor,
            UIColor.white.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        
        let shineMaskLayer = CAShapeLayer()
        let maskPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 1, height: 1))
        shineMaskLayer.path = maskPath.cgPath
        shineMaskLayer.fillRule = .evenOdd
        shineView.layer.mask = shineMaskLayer
        shineView.layer.addSublayer(shineLayer)
        
        let badgeImageView = UIImageView(image: UIImage(named: "badge_shop"))
        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        badgeImageView.alpha = 0
        badgeImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: -CGFloat.pi)
        
        // Buttons setup
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 16
        buttonsStack.alignment = .center
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonWidth = min(bounds.width * 0.8, 400)
        
        let playAgainButton = createStyledButton(
            title: "Volver a jugar",
            symbolName: "arrow.counterclockwise.circle.fill",
            backgroundColor: .systemBlue,
            width: buttonWidth
        ) { [weak self] in
            self?.resetGame()
        }
        
        let mainMenuButton = createStyledButton(
            title: "Pantalla Principal",
            symbolName: "chevron.backward.circle.fill",
            backgroundColor: .systemGray,
            width: buttonWidth
        ) { [weak self] in
            self?.mainMenuCallback?()
        }
        
        buttonsStack.addArrangedSubview(playAgainButton)
        buttonsStack.addArrangedSubview(mainMenuButton)
        
        // Add all elements to container
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(badgeContainer)
        badgeContainer.addSubview(shineView)
        badgeContainer.addSubview(badgeImageView)
        container.addSubview(buttonsStack)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Blur view and white overlay
            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            whiteOverlay.topAnchor.constraint(equalTo: container.topAnchor),
            whiteOverlay.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            whiteOverlay.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            whiteOverlay.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            // Container
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // Badge container
            badgeContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            badgeContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            badgeContainer.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.6),
            badgeContainer.heightAnchor.constraint(equalTo: badgeContainer.widthAnchor),
            
            // Badge image
            badgeImageView.centerXAnchor.constraint(equalTo: badgeContainer.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalTo: badgeContainer.widthAnchor),
            badgeImageView.heightAnchor.constraint(equalTo: badgeContainer.heightAnchor),
            
            // Shine view
            shineView.centerXAnchor.constraint(equalTo: badgeContainer.centerXAnchor),
            shineView.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            shineView.widthAnchor.constraint(equalTo: badgeContainer.widthAnchor),
            shineView.heightAnchor.constraint(equalTo: badgeContainer.heightAnchor),
            
            // Buttons stack
            buttonsStack.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonsStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
        ])
        
        // Animate the container
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5
        ) {
            container.alpha = 1
            container.transform = .identity
        } completion: { _ in
            // Animate the badge appearance with spring effect
            UIView.animate(
                withDuration: 1.0,
                delay: 0.2,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5
            ) {
                badgeImageView.alpha = 1
                badgeImageView.transform = .identity
            }
            
            // Update shine layer frame and start shine animation
            DispatchQueue.main.async {
                shineLayer.frame = shineView.bounds
                shineLayer.startPoint = CGPoint(x: 0, y: 0.5)
                shineLayer.endPoint = CGPoint(x: 1, y: 0.5)
                shineMaskLayer.frame = shineView.bounds
                
                let shineAnimation = CABasicAnimation(keyPath: "position.x")
                shineAnimation.fromValue = -shineView.bounds.width
                shineAnimation.toValue = shineView.bounds.width * 2
                shineAnimation.duration = 1.5
                shineAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                
                UIView.animate(withDuration: 0.3, delay: 1.2) {
                    shineView.alpha = 1
                } completion: { _ in
                    shineLayer.add(shineAnimation, forKey: "shineEffect")
                    UIView.animate(withDuration: 0.3, delay: 1.0) {
                        shineView.alpha = 0
                    }
                }
            }
            
            // Add subtle floating animation to badge
            let floatingAnimation = CABasicAnimation(keyPath: "transform.translation.y")
            floatingAnimation.duration = 2.0
            floatingAnimation.fromValue = -10
            floatingAnimation.toValue = 10
            floatingAnimation.autoreverses = true
            floatingAnimation.repeatCount = .infinity
            badgeImageView.layer.add(floatingAnimation, forKey: "floating")
        }
        
        summaryView = container
    }


    
  // Modify showGameOver to show different messages based on game end condition
    private func showGameOver() {
            guard !isShowingGameOver else { return }
            isShowingGameOver = true
            
            // Cancel the game timer first
            gameTimer?.invalidate()
            gameTimer = nil
            
            // Cancel any scheduled ball checks
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            
            // Remove preview entity if it exists
            previewEntity?.removeFromParent()
            
            // Remove existing balls
            gameAnchor?.children.forEach { entity in
                if entity != platformEntity && entity != leftBin && entity != rightBin && entity != gameOverText {
                    entity.removeFromParent()
                }
            }
            
            // Show appropriate screen based on game end condition
            if lives <= 0 {
                // Lost the game - show game over summary
                showGameOverSummary()
                
                // Add 3D game over text only for loss condition
                let gameOverMessage = "GAME OVER!\nNo Lives Left"
                let mesh = MeshResource.generateText(
                    gameOverMessage,
                    extrusionDepth: 0.01,
                    font: .systemFont(ofSize: 0.1, weight: .bold),
                    containerFrame: .zero,
                    alignment: .center,
                    lineBreakMode: .byWordWrapping
                )
                
                let material = SimpleMaterial(color: .red, isMetallic: false)
                gameOverText = ModelEntity(mesh: mesh, materials: [material])
                
                if let gameOverText = gameOverText {
                    gameOverText.position = [0, 0.3, -0.5]
                    gameOverText.scale = [0.3, 0.3, 0.3]
                    gameAnchor?.addChild(gameOverText)
                }
            } else {
                // Won the game - only show victory screen
                showVictoryScreen()
            }
        }
    
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMotionManager() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let motion = motion else { return }
            
            let roll = motion.attitude.roll
            let maxTilt: Float = .pi / 4
            let tilt = Float(roll).clamped(to: -maxTilt...maxTilt)
            
            let rotation = simd_quatf(angle: tilt, axis: [0, 0, 1])
            self?.platformEntity?.orientation = rotation
        }
    }
    
    private func setupBallCounter() {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.layer.cornerRadius = 12
        container.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        container.isLayoutMarginsRelativeArrangement = true
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0.0

        let ballIcon = UILabel()
        ballIcon.text = "🟢"
        ballIcon.font = .systemFont(ofSize: 20)

        let ballLabel = UILabel()
        ballLabel.text = "\(ballsRemaining)"
        ballLabel.font = .systemFont(ofSize: 18, weight: .bold)
        ballLabel.textColor = .white
        ballLabel.textAlignment = .left
        ballCountLabel = ballLabel

        container.addArrangedSubview(ballIcon)
        container.addArrangedSubview(ballLabel)
        addSubview(container)

        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: heartsContainer?.centerYAnchor ?? topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            container.heightAnchor.constraint(equalToConstant: 40)
        ])

        UIView.animate(withDuration: 0.5, delay: 0.3) {
            container.alpha = 1.0
        }
    }
    
    // Fix the updateBallCounter method
    private func updateBallCounter() {
        ballCountLabel?.text = "\(ballsRemaining)"
        
        // Animate the counter - fixed typo in CGAffineTransform
        ballCountLabel?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            self.ballCountLabel?.transform = .identity
        }
    }
    
    private func createBucket(color: SimpleMaterial, position: SIMD3<Float>, isRed: Bool) -> ModelEntity {
        // Create a container entity for the bucket
        let bucket = ModelEntity()
        
        // Create the completely invisible material once
        let invisibleMaterial = UnlitMaterial(
            color: .clear.withAlphaComponent(0)
        )
        
        // Different dimensions for red and blue buckets
        let dimensions = isRed ? (
            width: Float(0.5),    // Red bucket dimensions
            depth: Float(0.5),
            height: Float(0.4),
            thickness: Float(0.03)
        ) : (
            width: Float(0.6),    // Blue bucket dimensions - wider
            depth: Float(0.4),
            height: Float(0.4),
            thickness: Float(0.03)
        )

        // Function to create collision walls based on bucket type
        func createCollisionWalls() -> [ModelEntity] {
            if isRed {
                // For red bucket walls:
                let bottom = ModelEntity(
                    mesh: .generateBox(width: dimensions.width * 0.8, height: 0.02, depth: dimensions.depth * 0.8),
                    materials: [invisibleMaterial]
                )

                let leftWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.thickness, height: dimensions.height * 5.0, depth: dimensions.depth * 0.8),
                    materials: [invisibleMaterial]
                )

                let rightWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.thickness, height: dimensions.height * 1.5, depth: dimensions.depth * 0.8),
                    materials: [invisibleMaterial]
                )

                let backWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.width * 0.8, height: dimensions.height * 5.0, depth: dimensions.thickness),
                    materials: [invisibleMaterial]
                )

                let frontWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.width * 0.8, height: dimensions.height * 5.0, depth: dimensions.thickness),
                    materials: [invisibleMaterial]
                )
                
                // Position walls with slight angle for red bucket
                let angleOffset: Float = 0.1 // Adjust this value to change the angle
                leftWall.position = [-dimensions.width/2 + angleOffset, dimensions.height/2, 0]
                rightWall.position = [dimensions.width/2 - angleOffset, dimensions.height/2, 0]
                backWall.position = [0, dimensions.height/2, -dimensions.depth/2 + angleOffset]
                frontWall.position = [0, dimensions.height/2, dimensions.depth/2 - angleOffset]
                
                // Add slight rotation to walls for red bucket
                let angle: Float = 0.1 // Adjust this value to change the tilt
                leftWall.orientation = simd_quatf(angle: angle, axis: [0, 0, 1])
                rightWall.orientation = simd_quatf(angle: -angle, axis: [0, 0, 1])
                backWall.orientation = simd_quatf(angle: -angle, axis: [1, 0, 0])
                frontWall.orientation = simd_quatf(angle: angle, axis: [1, 0, 0])
                
                return [bottom, leftWall, rightWall, backWall, frontWall]
            } else {
                // And for blue bucket walls:
                let bottom = ModelEntity(
                    mesh: .generateBox(width: dimensions.width, height: 0.02, depth: dimensions.depth),
                    materials: [invisibleMaterial]
                )

                let leftWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.thickness, height: dimensions.height * 1.5, depth: dimensions.depth),
                    materials: [invisibleMaterial]
                )

                let rightWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.thickness, height: dimensions.height * 5.0, depth: dimensions.depth),
                    materials: [invisibleMaterial]
                )

                let backWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.width, height: dimensions.height * 5.0, depth: dimensions.thickness),
                    materials: [invisibleMaterial]
                )

                let frontWall = ModelEntity(
                    mesh: .generateBox(width: dimensions.width, height: dimensions.height * 5.0, depth: dimensions.thickness),
                    materials: [invisibleMaterial]
                )
                
                // Standard positioning for blue bucket
                leftWall.position = [-dimensions.width/2, dimensions.height/2, 0]
                rightWall.position = [dimensions.width/2, dimensions.height/2, 0]
                backWall.position = [0, dimensions.height/2, -dimensions.depth/2]
                frontWall.position = [0, dimensions.height/2, dimensions.depth/2]
                
                return [bottom, leftWall, rightWall, backWall, frontWall]
            }
        }
        
        // Load 3D model
        if let modelURL = Bundle.main.url(forResource: isRed ? "RedBucketModel" : "BlueBucketModel", withExtension: "usdz") {
            do {
                let entity = try Entity.load(contentsOf: modelURL)
                let modelEntity = ModelEntity()
                entity.children.forEach { child in
                    modelEntity.addChild(child)
                }
                
                let scale: Float = isRed ? 0.25 : 20.0
                modelEntity.scale = [scale, scale, scale]
                
                if !isRed {
                    modelEntity.orientation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
                }
                
                modelEntity.position = [0, 0, 0]
                bucket.addChild(modelEntity)
            } catch {
                print("Failed to load bucket model: \(error)")
            }
        }
        
        // Create and add collision walls
        let collisionWalls = createCollisionWalls()
        for wall in collisionWalls {
            wall.generateCollisionShapes(recursive: true)
            let physicsBody = PhysicsBodyComponent(
                massProperties: .default,
                material: .generate(
                    friction: isRed ? 0.3 : 0.5,
                    restitution: isRed ? 0.4 : 0.2
                ),
                mode: .static
            )
            wall.components[PhysicsBodyComponent.self] = physicsBody
            bucket.addChild(wall)
        }
        
        // Set bucket position
        bucket.position = position
        
        return bucket
    }
    
    private func setupGame() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        gameAnchor = AnchorEntity(plane: .horizontal)
        
        let platformMesh = MeshResource.generateBox(width: 0.8, height: 0.02, depth: 0.15)
        platformEntity = ModelEntity(mesh: platformMesh, materials: [SimpleMaterial(color: .gray, isMetallic: true)])
        platformEntity?.generateCollisionShapes(recursive: true)
        platformEntity?.orientation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        
        var platformPhysics = PhysicsBodyComponent()
        platformPhysics.mode = .kinematic
        platformEntity?.components[PhysicsBodyComponent.self] = platformPhysics
        
        leftBin = createBucket(color: redMaterial, position: [-0.5, -1.0, 0], isRed: true)
        rightBin = createBucket(color: blueMaterial, position: [0.5, -1.0, 0], isRed: false)
        
        if let anchor = gameAnchor,
           let platform = platformEntity {
            platform.position = [0, -0.2, 0]
            anchor.addChild(platform)
            
            if let left = leftBin, let right = rightBin {
                anchor.addChild(left)
                anchor.addChild(right)
            }
            
            scene.addAnchor(anchor)
        }
        
        createPreviewObject()
        startGameLoop()
    }
    
    // Add orientation component to make textures visible from all angles
    private struct OrientationComponent: Component {
        var orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
    }
    
    // Update the preview object creation as well
    private func createPreviewObject() {
        previewEntity?.removeFromParent()
        
        let objectMesh = MeshResource.generateSphere(radius: 0.05)
        let material = ballMaterials[currentBallType.textureName] ?? SimpleMaterial(color: .gray, isMetallic: true)
        
        previewEntity = ModelEntity(mesh: objectMesh, materials: [material])
        previewEntity?.components[BallTypeComponent.self] = BallTypeComponent(
            textureName: currentBallType.textureName,
            category: currentBallType.category
        )
        previewEntity?.components[OrientationComponent.self] = OrientationComponent()
        
        if let preview = previewEntity {
            preview.position = [0, 0.8, 0]
            gameAnchor?.addChild(preview)
        }
    }

    // Modify the dropCurrentObject method to improve ball checking
    // Also update the dropCurrentObject method to add the PhysicsMotion component
    private func dropCurrentObject() {
        guard !gameOver else { return }
        guard ballsRemaining > 0 else {
            if lives > 0 {
                gameOver = true
                showGameOver()
            }
            return
        }
        
        let objectMesh = MeshResource.generateSphere(radius: 0.05)
        let material = ballMaterials[currentBallType.textureName] ?? SimpleMaterial(color: .gray, isMetallic: true)
        
        let fallingObject = ModelEntity(mesh: objectMesh, materials: [material])
        fallingObject.components[BallTypeComponent.self] = BallTypeComponent(
            textureName: currentBallType.textureName,
            category: currentBallType.category
        )
        
        fallingObject.generateCollisionShapes(recursive: true)
        var objectPhysics = PhysicsBodyComponent()
        objectPhysics.mode = .dynamic
        objectPhysics.massProperties = .init(mass: 0.5)
        objectPhysics.material = .generate(friction: 0.5, restitution: 0.3)
        fallingObject.components[PhysicsBodyComponent.self] = objectPhysics
        
        fallingObject.position = [0, 0.8, 0]
        gameAnchor?.addChild(fallingObject)
        
        // Decrease ball count and update display
        ballsRemaining -= 1
        updateBallCounter()
        
        // More frequent checks at shorter intervals
        let checkIntervals = [0.3, 0.6, 0.9, 1.2, 1.5, 1.8]
        for interval in checkIntervals {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
                self?.checkBallPosition(fallingObject)
            }
        }
        
        // Select next random ball type
        currentBallType = ballTypes.randomElement()
        updatePreviewImage(animated: true)
    }
    
    // Add this method to help with debugging
    private func printBucketContents() {
        guard let anchor = gameAnchor else { return }
        var redCategoryCount = 0
        var blueCategoryCount = 0
        var redUniqueTypes = Set<String>()
        var blueUniqueTypes = Set<String>()
        
        anchor.children.forEach { entity in
            if let ball = entity as? ModelEntity,
               let ballType = ball.components[BallTypeComponent.self] {
                let ballPos = ball.position(relativeTo: anchor)
                if let leftBin = leftBin {
                    let bucketPos = leftBin.position(relativeTo: anchor)
                    let isNearBucket = abs(ballPos.x - bucketPos.x) < 0.3 &&
                                     abs(ballPos.z - bucketPos.z) < 0.3 &&
                                     ballPos.y < bucketPos.y + 0.5
                    if isNearBucket {
                        switch ballType.category {
                        case .red:
                            redCategoryCount += 1
                            redUniqueTypes.insert(ballType.textureName)
                        case .blue:
                            blueCategoryCount += 1
                            blueUniqueTypes.insert(ballType.textureName)
                        }
                    }
                }
            }
        }
        
        print("Current bucket contents:")
        print("Red category - Total balls: \(redCategoryCount), Unique types: \(redUniqueTypes.count)")
        print("Blue category - Total balls: \(blueCategoryCount), Unique types: \(blueUniqueTypes.count)")
        print("Red unique balls: \(redUniqueTypes)")
        print("Blue unique balls: \(blueUniqueTypes)")
    }

    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension GameARView: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        UIView.animate(withDuration: 0.5) {
            coachingOverlayView.alpha = 0
        } completion: { _ in
            // Only show tap instruction if we haven't already shown it and haven't set up the game
            if !self.hasShownTapInstruction && !self.isGameSetup && self.planeDetected {
                self.hasShownTapInstruction = true
                self.showTapInstruction()
            }
        }
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        // Remove tap instruction if it exists when coaching overlay appears
        if let tapInstructionView = tapInstructionView {
            UIView.animate(withDuration: 0.3) {
                tapInstructionView.alpha = 0
            } completion: { _ in
                tapInstructionView.removeFromSuperview()
            }
        }
        
        // Clear backgrounds when the overlay activates
        func clearBackgrounds(in view: UIView) {
            view.backgroundColor = .clear
            if let effectView = view as? UIVisualEffectView {
                effectView.effect = nil
            }
            for subview in view.subviews {
                clearBackgrounds(in: subview)
            }
        }
        clearBackgrounds(in: coachingOverlayView)
    }
}

extension UIImage {
    static func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    static func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        var images = [UIImage]()
        var duration: Double = 0
        
        let imageCount = CGImageSourceGetCount(source)
        
        // Get total duration of the gif
        for i in 0 ..< imageCount {
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                
                if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                    duration += delayTime
                }
                
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                }
            }
        }
        
        if images.isEmpty {
            return nil
        }
        
        // If we couldn't get a valid duration, default to a reasonable frame rate
        if duration == 0 {
            duration = Double(imageCount) * (1.0 / 30.0) // 30 fps default
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}


extension ModelEntity {
    static func loadModelAsync(named name: String) async throws -> ModelEntity {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                // Load as Entity first
                let entity = try Entity.load(named: name)
                
                // Create a ModelEntity and transfer the content
                let modelEntity = ModelEntity()
                entity.children.forEach { child in
                    modelEntity.addChild(child)
                }
                
                continuation.resume(returning: modelEntity)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

extension UILabel {
    var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets.zero
        }
        set {
            let paddingView = UIView()
            paddingView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(paddingView)
            
            NSLayoutConstraint.activate([
                paddingView.topAnchor.constraint(equalTo: self.topAnchor, constant: -newValue.top),
                paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: newValue.bottom),
                paddingView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: -newValue.left),
                paddingView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: newValue.right)
            ])
        }
    }
}
