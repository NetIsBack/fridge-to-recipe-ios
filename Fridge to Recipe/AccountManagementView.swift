//
//  AccountManagementView.swift
//  Fridge to Recipe
//
//  Account management view for collaborative users
//

import SwiftUI
import PhotosUI

struct AccountManagementView: View {
    @ObservedObject var collaborativeService: CollaborativeService
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var currentPassword: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPhotoOptions = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingPasswordChangeSection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture Section
                    profilePictureSection
                    
                    // Display Name Section
                    displayNameSection
                    
                    // Email Section
                    emailSection
                    
                    // Password Section
                    passwordSection
                    
                    // Save Button
                    saveButton
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color("AppBackgroundStart"), Color("AppBackgroundEnd")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Account Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentUserData()
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedPhoto,
                matching: .images
            )
            .sheet(isPresented: $showingCamera) {
                CameraImagePicker(selectedImage: $profileImage, sourceType: .camera)
            }
            .confirmationDialog("Profile Photo", isPresented: $showingPhotoOptions) {
                Button("Take Photo") {
                    showingCamera = true
                }
                Button("Choose from Library") {
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            self.profileImage = image
                        }
                    }
                }
            }
            .alert("Account Update", isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            Text("Profile Picture")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button(action: {
                showingPhotoOptions = true
            }) {
                ZStack {
                    Circle()
                        .fill(collaborativeService.currentUser?.colorValue ?? Color.blue)
                        .frame(width: 120, height: 120)
                    
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Text(collaborativeService.currentUser?.initials ?? "?")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Camera overlay
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.title)
                                .foregroundColor(.white)
                        )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var displayNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Display Name")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Enter your display name", text: $displayName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email Address")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .font(.body)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                showingPasswordChangeSection.toggle()
            }) {
                HStack {
                    Text("Change Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: showingPasswordChangeSection ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if showingPasswordChangeSection {
                VStack(spacing: 12) {
                    SecureField("Current Password", text: $currentPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                    
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                    
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                    
                    if !newPassword.isEmpty && !confirmPassword.isEmpty {
                        HStack {
                            Image(systemName: newPassword == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(newPassword == confirmPassword ? .green : .red)
                            Text(newPassword == confirmPassword ? "Passwords match" : "Passwords don't match")
                                .font(.caption)
                                .foregroundColor(newPassword == confirmPassword ? .green : .red)
                            Spacer()
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .animation(.easeInOut(duration: 0.3), value: showingPasswordChangeSection)
    }
    
    private var saveButton: some View {
        Button(action: saveChanges) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
            }
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
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
    
    private func loadCurrentUserData() {
        guard let user = collaborativeService.currentUser else { return }
        displayName = user.displayName
        email = user.email
        
        // Load profile image if available
        if let imageData = user.profileImageData,
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    
    private func saveChanges() {
        isLoading = true
        
        Task {
            do {
                // Validate inputs
                if displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await MainActor.run {
                        alertMessage = "Display name cannot be empty"
                        showingAlert = true
                        isLoading = false
                    }
                    return
                }
                
                if !isValidEmail(email) {
                    await MainActor.run {
                        alertMessage = "Please enter a valid email address"
                        showingAlert = true
                        isLoading = false
                    }
                    return
                }
                
                // Validate password change if attempted
                if showingPasswordChangeSection && !newPassword.isEmpty {
                    if currentPassword.isEmpty {
                        await MainActor.run {
                            alertMessage = "Current password is required to change password"
                            showingAlert = true
                            isLoading = false
                        }
                        return
                    }
                    
                    if newPassword != confirmPassword {
                        await MainActor.run {
                            alertMessage = "New passwords don't match"
                            showingAlert = true
                            isLoading = false
                        }
                        return
                    }
                    
                    if newPassword.count < 6 {
                        await MainActor.run {
                            alertMessage = "Password must be at least 6 characters long"
                            showingAlert = true
                            isLoading = false
                        }
                        return
                    }
                }
                
                // Update user profile
                try await collaborativeService.updateUserProfile(
                    displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    profileImage: profileImage,
                    currentPassword: currentPassword.isEmpty ? nil : currentPassword,
                    newPassword: newPassword.isEmpty ? nil : newPassword
                )
                
                await MainActor.run {
                    alertMessage = "Account updated successfully"
                    showingAlert = true
                    isLoading = false
                    
                    // Clear password fields
                    currentPassword = ""
                    newPassword = ""
                    confirmPassword = ""
                    showingPasswordChangeSection = false
                }
                
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to update account: \(error.localizedDescription)"
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}

// Camera Image Picker
struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker
        
        init(_ parent: CameraImagePicker) {
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

#Preview {
    AccountManagementView(collaborativeService: CollaborativeService())
}
