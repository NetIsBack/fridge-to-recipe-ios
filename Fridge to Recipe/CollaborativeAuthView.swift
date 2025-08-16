//
//  CollaborativeAuthView.swift
//  Fridge to Recipe
//
//  Authentication view for collaborative shopping lists
//

import SwiftUI

struct CollaborativeAuthView: View {
    @ObservedObject var collaborativeService: CollaborativeService
    @Environment(\.dismiss) private var dismiss
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImagePickerSheet = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        
                        VStack(spacing: 8) {
                            Text("Collaborate on Shopping Lists")
                                .font(.title.bold())
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Sign in to create and share shopping lists with friends and family")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    // Form
                    VStack(spacing: 20) {
                        if isSignUp {
                            // Profile Picture Section
                            VStack(spacing: 12) {
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    ZStack {
                                        if let selectedImage = selectedImage {
                                            Image(uiImage: selectedImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.blue, lineWidth: 3)
                                                )
                                                .overlay(
                                                    // Edit overlay
                                                    Circle()
                                                        .fill(Color.black.opacity(0.3))
                                                        .frame(width: 80, height: 80)
                                                        .overlay(
                                                            Image(systemName: "camera.fill")
                                                                .font(.title3)
                                                                .foregroundColor(.white)
                                                        )
                                                        .opacity(0)
                                                )
                                        } else {
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                                .frame(width: 80, height: 80)
                                                .overlay(
                                                    VStack(spacing: 4) {
                                                        Image(systemName: "camera.fill")
                                                            .font(.title2)
                                                            .foregroundColor(.blue)
                                                        Text("Photo")
                                                            .font(.caption2.bold())
                                                            .foregroundColor(.blue)
                                                    }
                                                )
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .scaleEffect(selectedImage != nil ? 1.0 : 1.0)
                                .animation(.spring(response: 0.3), value: selectedImage != nil)
                                
                                Text(selectedImage != nil ? "Tap to change photo" : "Add Profile Photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .animation(.easeInOut, value: selectedImage != nil)
                            }
                            
                            TextField("Display Name", text: $displayName)
                                .textFieldStyle(ModernTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(ModernTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(ModernTextFieldStyle())
                        
                        // Sign In/Up Button
                        Button(action: {
                            authenticate()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUp ? "Sign Up" : "Sign In")
                                        .font(.headline)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: .blue.opacity(0.3), radius: 5, y: 3)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && displayName.isEmpty))
                        .opacity((isLoading || email.isEmpty || password.isEmpty || (isSignUp && displayName.isEmpty)) ? 0.6 : 1.0)
                        
                        // Toggle Sign In/Up
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isSignUp.toggle()
                                errorMessage = ""
                                showError = false
                            }
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Features List
                    VStack(spacing: 12) {
                        Text("Collaboration Features")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.bottom, 8)
                        
                        FeatureRow(icon: "person.2.fill", title: "Real-time Sync", description: "See changes instantly")
                        FeatureRow(icon: "icloud.fill", title: "Offline Support", description: "Works without internet")
                        FeatureRow(icon: "qrcode", title: "Easy Sharing", description: "Invite with a simple code")
                        FeatureRow(icon: "clock.fill", title: "Activity Log", description: "See who added what and when")
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
            )
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .actionSheet(isPresented: $showImagePicker) {
            ActionSheet(
                title: Text("Select Profile Photo"),
                message: Text("Choose how you'd like to add your profile photo"),
                buttons: [
                    .default(Text("Camera")) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            imageSourceType = .camera
                            showImagePickerSheet = true
                        }
                    },
                    .default(Text("Photo Library")) {
                        imageSourceType = .photoLibrary
                        showImagePickerSheet = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePickerSheet) {
            ImagePickerView(sourceType: imageSourceType, selectedImage: $selectedImage)
        }
    }
    
    private func authenticate() {
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                if isSignUp {
                    try await collaborativeService.signUp(email: email, password: password, displayName: displayName)
                } else {
                    try await collaborativeService.signIn(email: email, password: password)
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

// MARK: - Image Picker View
struct ImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Try to get edited image first, then original
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CollaborativeAuthView(collaborativeService: CollaborativeService())
}
