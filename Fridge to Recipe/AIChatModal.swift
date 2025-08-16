// AIChatModal.swift
import SwiftUI

struct AIChatModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("AI Chat will be available here.")
            }
            .navigationTitle("AI Assistant")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 