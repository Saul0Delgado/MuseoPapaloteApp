import SwiftUI
import ARKit
import SceneKit
import SpriteKit

//Dinosaur Game AR View Container

struct ARViewContainerDino: UIViewRepresentable {
    @Binding var showQuiz: Bool
    @Binding var skullModelName: String  // Make skullModelName a @Binding variable
    @Binding var showTutorial: Bool

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.autoenablesDefaultLighting = true

        let scene = SCNScene()
        sceneView.scene = scene

        context.coordinator.sceneView = sceneView

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)

        // Add erasing pan gesture recognizer
        context.coordinator.addErasingPanGesture()

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update skull model if it has changed
        context.coordinator.skullModelName = skullModelName
    }

    func makeCoordinator() -> Coordinator {
            Coordinator(showQuiz: $showQuiz,
                       skullModelName: $skullModelName,
                       showTutorial: $showTutorial)
    }
    
    

    class Coordinator: NSObject, ARSCNViewDelegate {
        @Binding var showQuiz: Bool
        @Binding var skullModelName: String
        @Binding var showTutorial: Bool
        
        var sceneView: ARSCNView?
        var skullNode: SCNNode?
        var overlayNode: SCNNode?
        var lastDrawPoint: CGPoint?
        var maskScenes: [SKScene] = []
        
        // Variables to track erased area
        var totalErasedArea: CGFloat = 0.0
        var totalOverlayArea: CGFloat = 0.0
        var overlayRemoved = false
        
        // Gesture recognizers
        var erasingPanGesture: UIPanGestureRecognizer?
        var rotationGesture: UIPanGestureRecognizer?
        
        init(showQuiz: Binding<Bool>,
             skullModelName: Binding<String>,
             showTutorial: Binding<Bool>) {
            _showQuiz = showQuiz
            _skullModelName = skullModelName
            _showTutorial = showTutorial
            super.init()
            
            // Add observers after super.init()
            NotificationCenter.default.addObserver(self,
                                                 selector: #selector(sessionDidBecomeActive),
                                                 name: UIScene.didActivateNotification,
                                                 object: nil)
            NotificationCenter.default.addObserver(self,
                                                 selector: #selector(quizDidEnd),
                                                 name: Notification.Name("QuizDidEnd"),
                                                 object: nil)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func sessionDidBecomeActive() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.skullNode?.removeFromParentNode()  // Add this line to remove existing skull
                self?.setupScene()
            }
        }

        @objc func quizDidEnd() {
            DispatchQueue.main.async {
                // Remove existing skull and overlay nodes
                self.skullNode?.removeFromParentNode()
                self.overlayNode?.removeFromParentNode()
                self.skullNode = nil
                self.overlayNode = nil
                

                // Remove rotation gesture
                if let rotationGesture = self.rotationGesture {
                    self.sceneView?.removeGestureRecognizer(rotationGesture)
                    self.rotationGesture = nil
                }

                // Re-add erasing pan gesture
                self.addErasingPanGesture()
            

                // Setup the scene again with the skull
                self.setupScene()
                
                
            }
        }

        func setupScene() {
            loadSkullModel()
            createOverlay()
        }

        func loadSkullModel() {
            // Remove existing skull if any
            skullNode?.removeFromParentNode()
            
            guard let skullScene = SCNScene(named: skullModelName) else {
                print("Failed to load skull model: \(skullModelName)")
                return
            }

            let newSkullNode = skullScene.rootNode.clone()
            skullNode = newSkullNode

            // Position and scale the skull
            newSkullNode.scale = SCNVector3(0.1, 0.1, 0.1)
            newSkullNode.position = SCNVector3(0, -0.1, -1.0)

            // Make skull initially invisible
            newSkullNode.opacity = 0.0

            sceneView?.scene.rootNode.addChildNode(newSkullNode)
        }

        func createOverlay() {
            guard let skullNode = skullNode else { return }

            // Get skull dimensions
            let (min, max) = skullNode.boundingBox
            let width = CGFloat(max.x - min.x) * CGFloat(skullNode.scale.x) * 1.5
            let height = CGFloat(max.y - min.y) * CGFloat(skullNode.scale.y) * 1.5
            let depth = CGFloat(max.z - min.z) * CGFloat(skullNode.scale.z) * 1.5

            // Create box geometry
            let boxGeometry = SCNBox(
                width: width,
                height: height,
                length: depth,
                chamferRadius: 0
            )

            // Load the overlay texture
            guard let overlayTexture = UIImage(named: "overlay_texture.jpg") else {
                print("Failed to load overlay texture")
                return
            }

            // Create mask scenes for each face
            let maskSceneSize = CGSize(width: 2048, height: 2048)
            maskScenes = (0..<6).map { _ in
                let scene = SKScene(size: maskSceneSize)
                scene.backgroundColor = .black
                return scene
            }

            // Initialize total overlay area and erased area
            totalOverlayArea = CGFloat(maskScenes.count) * maskSceneSize.width * maskSceneSize.height
            totalErasedArea = 0.0
            overlayRemoved = false

            // Create materials for each face of the cube
            var materials = [SCNMaterial]()
            for maskScene in maskScenes {
                let material = SCNMaterial()
                material.diffuse.contents = overlayTexture
                material.transparent.contents = maskScene
                material.transparencyMode = .rgbZero
                material.isDoubleSided = true
                material.writesToDepthBuffer = true
                material.readsFromDepthBuffer = true
                materials.append(material)
            }

            boxGeometry.materials = materials

            // Create and position overlay
            let overlay = SCNNode(geometry: boxGeometry)
            overlayNode = overlay

            // Position overlay to encompass the skull
            overlay.position = SCNVector3(
                skullNode.position.x,
                skullNode.position.y,
                skullNode.position.z
            )

            // Set the rendering order for the overlay
            overlay.renderingOrder = 1

            // Start with normal scale
            overlay.scale = SCNVector3(1.5, 1.5, 1.5)  // Slightly larger to ensure coverage

            // Add to scene
            sceneView?.scene.rootNode.addChildNode(overlay)

            // Create a sequence of animations

            // 1. Quick shrink animation
            let shrinkAction = SCNAction.scale(to: 0.01, duration: 0.0)  // Instant shrink

            // 2. Scale back to normal
            let scaleAction = SCNAction.scale(to: 1.0, duration: 1.5)
            scaleAction.timingMode = .easeInEaseOut

            // 3. Rotation animation
            let rotateAction = SCNAction.rotateBy(
                x: CGFloat(2 * Double.pi),
                y: CGFloat(2 * Double.pi),
                z: 0,
                duration: 1.5
            )
            rotateAction.timingMode = .easeInEaseOut

            // Combine scale and rotate animations
            let growAndRotate = SCNAction.group([scaleAction, rotateAction])

            // Create sequence: shrink then grow with rotation
            let sequence = SCNAction.sequence([
                SCNAction.wait(duration: 0.1),  // Short delay to ensure coverage
                shrinkAction,
                growAndRotate
            ])

            overlay.runAction(sequence) { [weak self] in
                        guard let self = self else { return }
                        // Fade in the skull after overlay animation is complete
                        let fadeInAction = SCNAction.fadeIn(duration: 0.3)
                        self.skullNode?.runAction(fadeInAction)
                        
                    }
                }

        func createDustParticles(at position: SCNVector3) -> SCNNode {
            let particleSystem = SCNParticleSystem()

            // Configure particle appearance
            particleSystem.particleSize = 0.005
            particleSystem.particleColor = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 0.8)
            particleSystem.particleColorVariation = SCNVector4(0, 0, 0, 0)

            // Disable lighting effects
            particleSystem.isLightingEnabled = false
            particleSystem.blendMode = .additive

            // Make particles render as flat images and always on top
            particleSystem.sortingMode = .distance
            particleSystem.orientationMode = .free
            particleSystem.fresnelExponent = 0

            // Configure particle behavior
            particleSystem.particleLifeSpan = 0.5
            particleSystem.particleVelocity = 0.2
            particleSystem.particleVelocityVariation = 0.1
            particleSystem.spreadingAngle = 180
            particleSystem.acceleration = SCNVector3(0, -0.1, 0)

            // Configure emission
            particleSystem.birthRate = 200
            particleSystem.warmupDuration = 0
            particleSystem.emissionDuration = 0.1
            particleSystem.loops = false

            // Configure particle physics
            particleSystem.particleMass = 0.01

            // Create a node for the particle system
            let particleNode = SCNNode()
            particleNode.addParticleSystem(particleSystem)
            particleNode.position = position

            // Make sure particles render on top
            particleNode.renderingOrder = 2

            return particleNode
        }

        func getWorldPosition(from hitResult: SCNHitTestResult) -> SCNVector3? {
            let worldPosition = SCNVector3(
                hitResult.worldCoordinates.x,
                hitResult.worldCoordinates.y,
                hitResult.worldCoordinates.z
            )
            return worldPosition
        }

        // Modify handlePan to only work before the quiz
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            // Only handle this gesture if the quiz hasn't started
            if self.showQuiz {
                return
            }

            guard let overlayNode = overlayNode,
                  let view = gesture.view else { return }

            let location = gesture.location(in: view)

            // Perform hit test
            let hitResults = sceneView?.hitTest(location, options: [:])
            guard let hitResult = hitResults?.first(where: { $0.node == overlayNode }),
                  let materialIndex = hitResult.geometryIndex as Int?,
                  materialIndex < maskScenes.count,
                  let maskScene = maskScenes.element(at: materialIndex) else { return }

            // Convert hit location to texture coordinates
            let texCoords = hitResult.textureCoordinates(withMappingChannel: 0)
            let x = texCoords.x * maskScene.size.width
            let y = texCoords.y * maskScene.size.height
            let currentPoint = CGPoint(x: x, y: y)

            // Draw reveal effect
            if gesture.state == .began {
                lastDrawPoint = currentPoint
            }

            if let lastPoint = lastDrawPoint {
                // Create path between last and current point
                let path = CGMutablePath()
                path.move(to: lastPoint)
                path.addLine(to: currentPoint)

                // Create reveal brush
                let brush = SKShapeNode(path: path)
                brush.lineWidth = 100
                brush.strokeColor = .white
                brush.lineCap = .round
                brush.lineJoin = .round
                brush.blendMode = .replace

                maskScene.addChild(brush)

                // Create and add particles at the world position of the touch
                if let worldPosition = getWorldPosition(from: hitResult) {
                    let particleNode = createDustParticles(at: worldPosition)
                    sceneView?.scene.rootNode.addChildNode(particleNode)
                }

                // Compute the area of the brush stroke
                let dx = currentPoint.x - lastPoint.x
                let dy = currentPoint.y - lastPoint.y
                let distance = sqrt(dx * dx + dy * dy)
                let area = distance * brush.lineWidth

                totalErasedArea += area

                // Check if totalErasedArea >= 30% of totalOverlayArea
                if !overlayRemoved && totalErasedArea >= 0.3 * totalOverlayArea {
                    overlayRemoved = true
                    // Remove overlay and move skull closer
                    let fadeOutAction = SCNAction.fadeOut(duration: 0.5)
                    overlayNode.runAction(fadeOutAction) {
                        self.overlayNode?.removeFromParentNode()
                        self.moveSkullCloser()
                    }
                }
            }

            lastDrawPoint = currentPoint

            if gesture.state == .ended {
                lastDrawPoint = nil
            }
        }

        func moveSkullCloser() {
            guard let skullNode = skullNode, let sceneView = sceneView else { return }

            // Remove the erasing gesture recognizer
            if let erasingGesture = self.erasingPanGesture {
                sceneView.removeGestureRecognizer(erasingGesture)
                self.erasingPanGesture = nil
            }

            // Create the new position
            let newPosition = SCNVector3(skullNode.position.x, skullNode.position.y, -0.5)

            // Create move action with easing
            let moveAction = SCNAction.move(to: newPosition, duration: 1.0)
            moveAction.timingMode = .easeInEaseOut

            // Create rotation action with easing
            let rotateAction = SCNAction.rotateBy(
                x: 0,
                y: CGFloat(2 * Double.pi), // 360 degrees in radians
                z: 0,
                duration: 2.0
            )
            rotateAction.timingMode = .easeInEaseOut

            // Create group to run move and rotate actions together
            let moveAndRotate = SCNAction.group([moveAction, rotateAction])

            // Run the combined action
            skullNode.runAction(moveAndRotate) { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.showQuiz = true
                        self.addRotationGesture()
                    }
                }
            }

        func addErasingPanGesture() {
            guard let sceneView = self.sceneView else { return }

            // Remove existing erasing gesture if any
            if let erasingGesture = self.erasingPanGesture {
                sceneView.removeGestureRecognizer(erasingGesture)
            }

            // Add erasing pan gesture recognizer
            let erasingGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            sceneView.addGestureRecognizer(erasingGesture)
            self.erasingPanGesture = erasingGesture
        }

        func addRotationGesture() {
            guard let sceneView = self.sceneView else { return }

            // Remove existing rotation gesture if any
            if let rotationGesture = self.rotationGesture {
                sceneView.removeGestureRecognizer(rotationGesture)
            }

            // Add rotation gesture recognizer
            let rotationGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            sceneView.addGestureRecognizer(rotationGesture)
            self.rotationGesture = rotationGesture
        }

        @objc func handleRotation(_ gesture: UIPanGestureRecognizer) {
            guard let skullNode = self.skullNode else { return }

            // Get the rotation in screen space
            let translation = gesture.translation(in: gesture.view)

            // Convert translation to rotation angles
            let rotationSpeed: Float = 0.005 // Adjust as needed
            let deltaX = Float(translation.x) * rotationSpeed
            let deltaY = Float(translation.y) * rotationSpeed

            // Apply rotations
            skullNode.eulerAngles.y -= deltaX
            skullNode.eulerAngles.x -= deltaY

            // Reset the translation to zero to avoid compounding the values
            gesture.setTranslation(.zero, in: gesture.view)
        }
    }
}

// Extension to safely access array elements using a method
extension Array {
    func element(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
