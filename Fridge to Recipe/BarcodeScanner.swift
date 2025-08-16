//
//  BarcodeScanner.swift
//  Fridge to Recipe
//
//  Created by AI Assistant
//

import SwiftUI
import AVFoundation
import Vision
import UIKit
import AudioToolbox

// MARK: - Barcode Scanner Service
class BarcodeScannerService: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var scannedCode: String?
    @Published var detectedProduct: Product?
    @Published var errorMessage: String?
    @Published var torchIsOn = false
    
    private var captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        sessionQueue.async { [weak self] in
            self?.configureCaptureSession()
        }
    }
    
    private func configureCaptureSession() {
        guard captureSession.inputs.isEmpty && captureSession.outputs.isEmpty else {
            print("Capture session already configured")
            return
        }
        
        captureSession.beginConfiguration()
        
        // Set session preset for better performance
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
        
        // Check for camera availability first
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            DispatchQueue.main.async {
                self.errorMessage = "Camera access required. Please enable camera access in Settings."
            }
            captureSession.commitConfiguration()
            return
        }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            // Try to get any available camera
            guard let anyVideoDevice = AVCaptureDevice.default(for: .video) else {
                DispatchQueue.main.async {
                    self.errorMessage = "No camera available on this device"
                }
                captureSession.commitConfiguration()
                return
            }
            
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: anyVideoDevice)
                if captureSession.canAddInput(videoDeviceInput) {
                    captureSession.addInput(videoDeviceInput)
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Cannot add camera input to session"
                    }
                    captureSession.commitConfiguration()
                    return
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Camera input error: \(error.localizedDescription)"
                }
                captureSession.commitConfiguration()
                return
            }
            
            // Skip the main camera setup since we used any available camera
            self.setupMetadataOutput()
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Cannot add camera input to session"
                }
                captureSession.commitConfiguration()
                return
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Camera input error: \(error.localizedDescription)"
            }
            captureSession.commitConfiguration()
            return
        }
        
        setupMetadataOutput()
    }
    
    private func setupMetadataOutput() {
        // Add metadata output for barcode detection
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            // Set delegate on a background queue to avoid blocking main thread
            let delegateQueue = DispatchQueue(label: "barcode.metadata.queue")
            metadataOutput.setMetadataObjectsDelegate(self, queue: delegateQueue)
            
            // Set supported barcode types
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .pdf417, .qr, .code128, .code39, .code93,
                .upce, .aztec, .dataMatrix, .interleaved2of5, .itf14,
                .code39Mod43
            ]
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Cannot add metadata output to session"
            }
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.main.async {
            print("Capture session configured successfully")
        }
    }
    
    func startScanning() {
        // Check camera authorization status first
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authStatus {
        case .notDetermined:
            // Request camera permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if granted {
                        self.startCameraSession()
                    } else {
                        self.errorMessage = "Camera access is required for barcode scanning. Please enable camera access in Settings."
                    }
                }
            }
        case .authorized:
            startCameraSession()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Camera access denied. Please enable camera access in Settings."
            }
        @unknown default:
            DispatchQueue.main.async {
                self.errorMessage = "Unable to access camera."
            }
        }
    }
    
    private func startCameraSession() {
        // Configure session if needed
        if captureSession.inputs.isEmpty {
            configureCaptureSession()
        }
        
        // Check if there was an error during configuration
        if errorMessage != nil {
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isScanning = true
                    self.errorMessage = nil
                    print("Camera started successfully")
                }
            } else {
                DispatchQueue.main.async {
                    self.isScanning = true
                    self.errorMessage = nil
                }
            }
        }
    }
    
    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                print("Camera stopped")
            }
        }
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    func toggleTorch() {
        sessionQueue.async { [weak self] in
            guard let device = AVCaptureDevice.default(for: .video),
                  device.hasTorch else { return }
            
            try? device.lockForConfiguration()
            
            if device.torchMode == .off {
                device.torchMode = .on
                DispatchQueue.main.async {
                    self?.torchIsOn = true
                }
            } else {
                device.torchMode = .off
                DispatchQueue.main.async {
                    self?.torchIsOn = false
                }
            }
            
            device.unlockForConfiguration()
        }
    }
    
    func scanBarcodeFromImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid image"
            }
            return
        }
        
        print("Scanning image for barcodes...")
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let error = error {
                print("Vision barcode detection error: \(error)")
                DispatchQueue.main.async {
                    self?.errorMessage = "Barcode detection failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let observations = request.results as? [VNBarcodeObservation], !observations.isEmpty else {
                print("No barcodes found in image")
                DispatchQueue.main.async {
                    self?.errorMessage = "No barcode found in image. Try a clearer image with better lighting."
                }
                return
            }
            
            print("Found \(observations.count) barcode(s) in image")
            
            // Try to find a barcode with a valid payload
            for observation in observations {
                if let payloadString = observation.payloadStringValue, !payloadString.isEmpty {
                    print("Image barcode detected: \(payloadString) (\(observation.symbology.rawValue))")
                    DispatchQueue.main.async {
                        self?.handleScannedCode(payloadString)
                    }
                    return
                }
            }
            
            // If we get here, no valid payload was found
            DispatchQueue.main.async {
                self?.errorMessage = "Barcode found but could not read data. Try a different image."
            }
        }
        
        // Configure request for better detection
        request.revision = VNDetectBarcodesRequestRevision1
        
        // Perform request on background queue
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Vision request failed: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Image processing failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        scannedCode = code
        // Look up product information
        ProductLookupService.shared.lookupProduct(barcode: code) { [weak self] product in
            DispatchQueue.main.async {
                self?.detectedProduct = product
            }
        }
    }
    
    func reset() {
        scannedCode = nil
        detectedProduct = nil
        errorMessage = nil
    }
    
    func getCaptureSession() -> AVCaptureSession {
        return captureSession
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension BarcodeScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue,
              !stringValue.isEmpty else { 
            return 
        }
        
        print("Barcode detected: \(stringValue) (\(readableObject.type.rawValue))")
        
        // Vibrate to indicate successful scan
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        // Handle the scanned code on main thread
        DispatchQueue.main.async { [weak self] in
            self?.handleScannedCode(stringValue)
        }
    }
}

// MARK: - Product Model
struct Product: Identifiable, Codable, Equatable {
    let id = UUID()
    let barcode: String
    let name: String
    let brand: String?
    let imageURL: String?
    let category: String?
    let ingredients: [String]?
    let nutritionGrade: String?
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id && lhs.barcode == rhs.barcode
    }
}

// MARK: - Product Lookup Service
class ProductLookupService {
    static let shared = ProductLookupService()
    
    private init() {}
    
    func lookupProduct(barcode: String, completion: @escaping (Product?) -> Void) {
        // First try Open Food Facts API
        lookupFromOpenFoodFacts(barcode: barcode) { product in
            if let product = product {
                completion(product)
            } else {
                // Fallback to mock data
                completion(self.getMockProduct(barcode: barcode))
            }
        }
    }
    
    private func lookupFromOpenFoodFacts(barcode: String, completion: @escaping (Product?) -> Void) {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? Int,
                  status == 1,
                  let productData = json["product"] as? [String: Any] else {
                completion(nil)
                return
            }
            
            let name = productData["product_name"] as? String ?? "Unknown Product"
            let brand = productData["brands"] as? String
            let imageURL = productData["image_url"] as? String
            let category = productData["categories"] as? String
            let ingredientsText = productData["ingredients_text"] as? String
            let ingredients = ingredientsText?.components(separatedBy: ", ")
            let nutritionGrade = productData["nutrition_grade_fr"] as? String
            
            let product = Product(
                barcode: barcode,
                name: name,
                brand: brand,
                imageURL: imageURL,
                category: category,
                ingredients: ingredients,
                nutritionGrade: nutritionGrade
            )
            
            completion(product)
        }.resume()
    }
    
    private func getMockProduct(barcode: String) -> Product {
        // Mock data for common products when API lookup fails
        let mockProducts: [String: (name: String, brand: String?)] = [
            "123456789012": ("Whole Milk", "Generic Dairy"),
            "123456789013": ("White Bread", "Baker's Best"),
            "123456789014": ("Large Eggs", "Farm Fresh"),
            "123456789015": ("Cheddar Cheese", "Dairy Delight"),
            "123456789016": ("Unsalted Butter", "Creamy Co"),
            "7622210951676": ("Coca Cola", "Coca-Cola"),
            "8710398509406": ("Heinz Ketchup", "Heinz"),
            "4000417025005": ("Nutella", "Ferrero")
        ]
        
        let (name, brand) = mockProducts[barcode] ?? ("Unknown Product", nil)
        
        return Product(
            barcode: barcode,
            name: name,
            brand: brand,
            imageURL: nil,
            category: "Food",
            ingredients: nil,
            nutritionGrade: nil
        )
    }
}

// MARK: - Camera Preview UIViewRepresentable
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.setupPreviewLayer(with: session)
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // Update the frame when bounds change
        DispatchQueue.main.async {
            uiView.updatePreviewLayerFrame()
        }
    }
}

// MARK: - Camera Preview UIView
class CameraPreviewUIView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
    
    func setupPreviewLayer(with session: AVCaptureSession) {
        layer.session = session
        layer.videoGravity = .resizeAspectFill
        previewLayer = layer
    }
    
    func updatePreviewLayerFrame() {
        previewLayer?.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePreviewLayerFrame()
    }
}

// MARK: - Barcode Scanner View
struct BarcodeScannerView: View {
    @StateObject private var scanner = BarcodeScannerService()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let onBarcodeScanned: (Product) -> Void
    
    var body: some View {
        ZStack {
            // Background
            if scanner.isScanning {
                // Camera preview
                CameraPreview(session: scanner.getCaptureSession())
                    .ignoresSafeArea()
                
                // Dark overlay for better visibility
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                // Modern scanning interface
                modernScanningOverlay
            } else {
                // Modern start screen
                modernStartScreen
            }
            
            // Modern top navigation
            VStack {
                HStack {
                    // Close button
                    Button(action: {
                        scanner.stopScanning()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(scanner.isScanning ? .white : .primary)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 32, height: 32)
                            )
                    }
                    
                    Spacer()
                    
                    // Torch button (only when scanning)
                    if scanner.isScanning {
                        Button(action: scanner.toggleTorch) {
                            Image(systemName: scanner.torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 32, height: 32)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, image in
            if let image = image {
                scanner.scanBarcodeFromImage(image)
            }
        }
        .onChange(of: scanner.detectedProduct) { _, product in
            if let product = product {
                onBarcodeScanned(product)
                dismiss()
            }
        }
        .onAppear {
            requestCameraPermission()
        }
        .onDisappear {
            scanner.stopScanning()
        }
        .alert("Error", isPresented: .constant(scanner.errorMessage != nil)) {
            Button("OK") {
                scanner.errorMessage = nil
            }
        } message: {
            Text(scanner.errorMessage ?? "")
        }
    }
    
    private var modernStartScreen: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 100)
                    
                    // Header section
                    VStack(spacing: 24) {
                        // Main icon with modern styling
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        // Title and description
                        VStack(spacing: 12) {
                            Text(title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Scan product barcodes to quickly add items to your fridge")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    // Beta warning
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.orange)
                            
                            Text("BETA FEATURE")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        
                        Text("This feature is in beta. Some functions may not work perfectly. Please report any issues you encounter.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        // Primary camera button
                        Button(action: {
                            scanner.startScanning()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Start Camera")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 4)
                        }
                        
                        // Secondary gallery button
                        Button(action: {
                            showImagePicker = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Choose from Gallery")
                                    .font(.system(size: 18, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var modernScanningOverlay: some View {
        VStack {
            Spacer().frame(height: 100)
            
            // Instruction text with modern styling
            VStack(spacing: 8) {
                Text("Point camera at barcode")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Align the barcode within the frame")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            
            Spacer()
            
            // Modern scanning frame
            ZStack {
                // Main scanning frame
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 300, height: 180)
                
                // Corner highlights
                VStack {
                    HStack {
                        cornerIndicator
                        Spacer()
                        cornerIndicator
                    }
                    Spacer()
                    HStack {
                        cornerIndicator
                        Spacer()
                        cornerIndicator
                    }
                }
                .frame(width: 300, height: 180)
                
                // Success frame overlay
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 300, height: 180)
                    .opacity(scanner.scannedCode != nil ? 1 : 0)
                    .scaleEffect(scanner.scannedCode != nil ? 1.05 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: scanner.scannedCode)
            }
            
            Spacer()
            
            // Bottom controls with modern styling
            HStack(spacing: 24) {
                // Gallery button
                Button(action: {
                    showImagePicker = true
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 22, weight: .medium))
                        Text("Gallery")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                Spacer()
                
                // Stop scanning button
                Button(action: {
                    scanner.stopScanning()
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22, weight: .medium))
                        Text("Stop")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    private var cornerIndicator: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 20, height: 3)
            .cornerRadius(2)
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                DispatchQueue.main.async {
                    scanner.errorMessage = "Camera access is required for barcode scanning"
                }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Ingredient Barcode Scanner Sheet
struct IngredientBarcodeScannerSheet: View {
    @Binding var isPresented: Bool
    let onIngredientScanned: (String) -> Void
    
    var body: some View {
        BarcodeScannerView(
            title: "Scan Ingredient Barcode",
            onBarcodeScanned: { product in
                onIngredientScanned(product.name)
                isPresented = false
            }
        )
    }
}

// MARK: - Shopping List Barcode Scanner Sheet  
struct ShoppingListBarcodeScannerSheet: View {
    @Binding var isPresented: Bool
    let onItemScanned: (String) -> Void
    
    var body: some View {
        BarcodeScannerView(
            title: "Scan Shopping Item Barcode",
            onBarcodeScanned: { product in
                onItemScanned(product.name)
                isPresented = false
            }
        )
    }
}
