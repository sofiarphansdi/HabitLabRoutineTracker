//
//  ProfileView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userAvatarData") private var avatarData: Data?
    @AppStorage("appTheme") private var appTheme: String = "system"
    
    @State private var showEditName = false
    @State private var tempName = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var profileImageSize: CGFloat {
        horizontalSizeClass == .regular ? 80 : 60
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Group {
                                if let profileImage = profileImage {
                                    profileImage
                                        .resizable()
                                        .scaledToFill()
                                } else if let avatarData = avatarData, let uiImage = UIImage(data: avatarData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(width: profileImageSize, height: profileImageSize)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: horizontalSizeClass == .regular ? 16 : 12))
                                    .foregroundColor(.white)
                                    .padding(horizontalSizeClass == .regular ? 8 : 6)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .offset(x: profileImageSize / 3, y: profileImageSize / 3)
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 8 : 5) {
                            Text(userName)
                                .font(horizontalSizeClass == .regular ? .title : .title2)
                                .fontWeight(.bold)
                            
                            Text("Habit Tracker User")
                                .font(horizontalSizeClass == .regular ? .body : .subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.vertical, horizontalSizeClass == .regular ? 15 : 10)
                }
                .onChange(of: selectedPhoto) { newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            avatarData = data
                            if let uiImage = UIImage(data: data) {
                                profileImage = Image(uiImage: uiImage)
                            }
                        }
                    }
                }
                
                Section("Account") {
                    Button(action: {
                        tempName = userName
                        showEditName = true
                    }) {
                        Label("Edit Name", systemImage: "pencil")
                    }
                }
                
                Section("Preferences") {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: ThemeSettingsView(selectedTheme: $appTheme)) {
                        HStack {
                            Label("Theme", systemImage: "paintbrush.fill")
                            Spacer()
                            Text(themeDisplayName)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Edit Name", isPresented: $showEditName) {
                TextField("Name", text: $tempName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if !tempName.isEmpty {
                        userName = tempName
                    }
                }
            }
        }
        .onAppear {
            if let avatarData = avatarData, let uiImage = UIImage(data: avatarData) {
                profileImage = Image(uiImage: uiImage)
            }
        }
    }
    
    private var themeDisplayName: String {
        switch appTheme {
        case "dark": return "Dark"
        case "light": return "Light"
        default: return "System"
        }
    }
}

struct ThemeSettingsView: View {
    @Binding var selectedTheme: String
    
    var body: some View {
        List {
            Section {
                ThemeOptionRow(title: "System", value: "system", selectedTheme: $selectedTheme)
                ThemeOptionRow(title: "Light", value: "light", selectedTheme: $selectedTheme)
                ThemeOptionRow(title: "Dark", value: "dark", selectedTheme: $selectedTheme)
            } footer: {
                Text("Choose your preferred app theme. System theme will match your device settings.")
                    .font(.caption)
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemeOptionRow: View {
    let title: String
    let value: String
    @Binding var selectedTheme: String
    
    var body: some View {
        Button(action: {
            selectedTheme = value
        }) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedTheme == value {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

