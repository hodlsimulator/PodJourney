//
//  ViewController.swift
//  PhotoEditorApp
//
//  Created by . . on 23/09/2024.
//

import Cocoa
import UniformTypeIdentifiers

// Structs to store serializable data for layers and project

struct SerializableLayer: Codable {
    var imageData: Data
    var opacity: CGFloat
    var isVisible: Bool
}

struct ProjectData: Codable {
    var layers: [SerializableLayer]
}

class ViewController: NSViewController {
    
    // Array to hold all the layers
    var layers: [Layer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Test if the canvasView is properly connected by setting a color or drawing
        if let canvasView = canvasView {
            print("CanvasView is connected!")

            // Test by setting a background color (you'll need to modify CanvasView.swift for this)
            canvasView.wantsLayer = true
            canvasView.layer?.backgroundColor = NSColor.red.cgColor  // This will turn the canvasView red to test connection
            
            // OR, Test by loading an image (if you want to draw an image)
            let testImage = NSImage(named: NSImage.Name("NSApplicationIcon"))  // Using a built-in macOS image as a test
            canvasView.image = testImage  // This will display the macOS app icon if connected
            canvasView.needsDisplay = true
        } else {
            print("CanvasView is not connected!")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // Function to open and load an image into a new layer
    func openImage() {
        let dialog = NSOpenPanel()
        
        // Set allowed content types using UTType
        dialog.allowedContentTypes = [UTType.png, UTType.jpeg, UTType.tiff]
        
        if dialog.runModal() == .OK, let url = dialog.url {
            if let image = NSImage(contentsOf: url) {
                print("Image loaded successfully!")
                
                // Resize the image to a desired size (e.g., 200x200)
                let resizedImage = image.resize(to: NSSize(width: 200, height: 200))
                
                // Create a new layer with the resized image and default settings
                let newLayer = Layer(image: resizedImage)
                
                // Add the new layer to the layers array
                layers.append(newLayer)
                
                print("Layer added successfully! Total layers: \(layers.count)")
                
                // Example: You can update the UI to reflect the new layer added
                // For instance, display the resized image in an imageView if needed
                
            } else {
                print("Failed to load image.")
            }
        } else {
            print("No file selected.")
        }
    }
    
    // Example function to remove the most recent layer
    func removeLastLayer() {
        if !layers.isEmpty {
            layers.removeLast()
            print("Last layer removed. Remaining layers: \(layers.count)")
        } else {
            print("No layers to remove.")
        }
    }
    
    // Function to composite all visible layers and display the final image
    func compositeImage() -> NSImage? {
        guard let baseSize = layers.first?.image.size else { return nil }
        let finalImage = NSImage(size: baseSize)
        finalImage.lockFocus()
        
        for layer in layers where layer.isVisible {
            layer.image.draw(in: NSRect(origin: .zero, size: baseSize),
                             from: NSRect(origin: .zero, size: layer.image.size),
                             operation: .sourceOver,
                             fraction: layer.opacity)
        }
        
        finalImage.unlockFocus()
        return finalImage
    }
    
    // Save the composited image as a PNG with transparency
    func saveImage(_ image: NSImage, to url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                  print("Error generating PNG data.")
                  return
              }

        do {
            try pngData.write(to: url)
            print("Image saved successfully to \(url.path)")
        } catch {
            print("Error saving image: \(error)")
        }
    }

    // Save the project (layers) to a file
    func saveProject(to url: URL) {
        let serializableLayers = layers.map { layer -> SerializableLayer in
            let imageData = layer.image.tiffRepresentation ?? Data()
            return SerializableLayer(imageData: imageData, opacity: layer.opacity, isVisible: layer.isVisible)
        }

        let projectData = ProjectData(layers: serializableLayers)

        do {
            let data = try PropertyListEncoder().encode(projectData)
            try data.write(to: url)
            print("Project saved successfully to \(url.path)")
        } catch {
            print("Error saving project: \(error)")
        }
    }
    
    // Load the project (layers) from a file
    func loadProject(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let projectData = try PropertyListDecoder().decode(ProjectData.self, from: data)
            layers = projectData.layers.compactMap { serializableLayer in
                if let image = NSImage(data: serializableLayer.imageData) {
                    return Layer(image: image, opacity: serializableLayer.opacity, isVisible: serializableLayer.isVisible)
                }
                return nil
            }
            print("Project loaded successfully from \(url.path). Total layers: \(layers.count)")
            // Update UI accordingly (e.g., refresh the image view with the layers)
        } catch {
            print("Error loading project: \(error)")
        }
    }

    // Call the function when a button is pressed to load an image
    @IBAction func loadImageButtonPressed(_ sender: Any) {
        openImage()
    }
    
    // Example function triggered by a button to remove the last added layer
    @IBAction func removeLayerButtonPressed(_ sender: Any) {
        removeLastLayer()
    }
    
    // Example function to display the final composited image
    @IBAction func showCompositeImageButtonPressed(_ sender: Any) {
        if let finalImage = compositeImage() {
            // Display the final composited image in an imageView or custom view
            print("Composite image created successfully!")
            // imageView.image = finalImage  // Example if you want to display it
        } else {
            print("No layers to composite.")
        }
    }
    
    @IBOutlet weak var canvasView: CanvasView!
    // Save the composited image to a PNG file
    @IBAction func saveCompositeImageButtonPressed(_ sender: Any) {
        if let finalImage = compositeImage() {
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType.png]
            savePanel.nameFieldStringValue = "CompositeImage.png"
            
            if savePanel.runModal() == .OK, let url = savePanel.url {
                saveImage(finalImage, to: url)
            } else {
                print("Save operation cancelled or failed.")
            }
        } else {
            print("No image to save.")
        }
    }

    // Save the project to a file
    @IBAction func saveProjectButtonPressed(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "plist")!]
        savePanel.nameFieldStringValue = "Project.plist"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            saveProject(to: url)
        } else {
            print("Save operation cancelled or failed.")
        }
    }
    
    // Load the project from a file
    @IBAction func loadProjectButtonPressed(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType(filenameExtension: "plist")!]
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            loadProject(from: url)
        } else {
            print("Load operation cancelled or failed.")
        }
    }
}
