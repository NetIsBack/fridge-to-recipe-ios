import SwiftUI

// MARK: - Music Player Integration View
struct MusicPlayerView: View {
    @StateObject private var musicManager = MusicServiceManager()
    @State private var showMusicSetup = false
    @State private var showPlaylistSelection = false
    @State private var searchText = ""
    
    // Computed property to determine if user can control playback
    private var canControlPlayback: Bool {
        // Apple Music users can always control playback
        if musicManager.currentService == .appleMusic {
            return musicManager.isAuthenticated
        }
        // For Spotify, only Premium users get full playback control via Web API
        // Free users use deep links (which work but have limited control)
        else if musicManager.currentService == .spotify {
            return musicManager.isAuthenticated && musicManager.isPremiumUser
        }
        return false
    }
    
    // Computed property to determine when to show now playing view
    private var shouldShowNowPlayingView: Bool {
        // Show now playing view when there's an active track AND user has playback control
        // This ensures free Spotify users stay on playlist selection (deep link experience)
        return musicManager.currentTrack != nil && canControlPlayback
    }
    
    // Handle playlist selection based on user type and service
    private func handlePlaylistSelection(_ playlist: MusicPlaylist) async {
        if musicManager.currentService == .spotify && !musicManager.isPremiumUser {
            // Free Spotify users: Use deep link to open playlist in Spotify app
            await openSpotifyPlaylistDeepLink(playlist)
        } else {
            // Apple Music users and Spotify Premium users: Use Web API for playback control
            await musicManager.playPlaylist(playlist)
        }
    }
    
    // Open Spotify playlist using deep link for free users
    private func openSpotifyPlaylistDeepLink(_ playlist: MusicPlaylist) async {
        guard let url = URL(string: "spotify:playlist:\(playlist.id)") else { return }
        
        if await UIApplication.shared.canOpenURL(url) {
            await UIApplication.shared.open(url)
        } else {
            // Fallback to web URL if Spotify app is not installed
            if let webURL = URL(string: "https://open.spotify.com/playlist/\(playlist.id)") {
                await UIApplication.shared.open(webURL)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if musicManager.currentService == .none {
                // Music setup button
                musicSetupButton
            } else if !musicManager.isAuthenticated {
                // Authentication in progress
                authenticationView
            } else if shouldShowNowPlayingView {
                // Now playing view - shown when music is actively playing
                nowPlayingView
            } else {
                // Playlist selection - shown when authenticated but no active playback
                playlistSelectionView
            }
            
            // Error message
            if let errorMessage = musicManager.errorMessage {
                errorView(errorMessage)
            }
        }
        .sheet(isPresented: $showMusicSetup) {
            MusicServiceSelectionView(musicManager: musicManager)
        }
        .sheet(isPresented: $showPlaylistSelection) {
            PlaylistSelectionView(musicManager: musicManager)
        }
    }
    
    // MARK: - Music Setup Button
    private var musicSetupButton: some View {
        Button(action: {
            showMusicSetup = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add Music")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Play your playlists while cooking")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
        }
    }
    
    // MARK: - Authentication View
    private var authenticationView: some View {
        VStack(spacing: 12) {
            if musicManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Connecting to \(musicManager.currentService.rawValue)...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            } else {
                Button("Retry Connection") {
                    Task {
                        await musicManager.authenticateService(musicManager.currentService)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Now Playing View (Modern Capsule)
    private var nowPlayingView: some View {
        VStack(spacing: 16) {
            // Modern Now Playing Capsule
            HStack(spacing: 12) {
                // Album artwork with rounded corners
                AsyncImage(url: musicManager.currentTrack?.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                
                // Track info
                VStack(alignment: .leading, spacing: 3) {
                    Text(musicManager.currentTrack?.title ?? "No Track")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(musicManager.currentTrack?.artist ?? "Unknown Artist")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    // Service indicator with custom icon
                    HStack(spacing: 4) {
                        if musicManager.currentService == .spotify {
                            Image("spotify-icon")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.green)
                        } else {
                            Image("apple-music-icon")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.pink)
                        }
                        Text(musicManager.currentService.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Play/Pause Button (Large and prominent)
                Button(action: {
                    Task {
                        if musicManager.isPlaying {
                            await musicManager.pauseMusic()
                        } else {
                            await musicManager.resumeMusic()
                        }
                    }
                }) {
                    Image(systemName: musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(canControlPlayback ? .primary : .secondary)
                        .scaleEffect(musicManager.isPlaying ? 1.0 : 1.1)
                        .animation(.easeInOut(duration: 0.2), value: musicManager.isPlaying)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!canControlPlayback)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [musicManager.currentService.color.opacity(0.3), musicManager.currentService.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: musicManager.currentService.color.opacity(0.2), radius: 8, y: 4)
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            )
            
            // Control buttons row
            HStack(spacing: 20) {
                Button(action: {
                    Task {
                        await musicManager.skipTrack()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Change Playlist") {
                    showPlaylistSelection = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Button("Disconnect") {
                    musicManager.disconnect()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Playlist Selection View
    private var playlistSelectionView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Select a Playlist")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Browse All") {
                    showPlaylistSelection = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            
            // Different descriptions based on user type
            if musicManager.currentService == .spotify && !musicManager.isPremiumUser {
                Text("Tap to open playlist in Spotify app")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            } else {
                Text("Choose music to play while cooking")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Show first few playlists inline
            if musicManager.isLoading {
                ProgressView("Loading playlists...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            } else if !musicManager.playlists.isEmpty {
                VStack(spacing: 8) {
                    ForEach(musicManager.playlists.prefix(3)) { playlist in
                        PlaylistRowCompact(playlist: playlist) {
                            Task {
                                await handlePlaylistSelection(playlist)
                            }
                        }
                        .environmentObject(musicManager)
                    }
                    
                    if musicManager.playlists.count > 3 {
                        Button("View \(musicManager.playlists.count - 3) more playlists") {
                            showPlaylistSelection = true
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    }
                }
            } else {
                Text("No playlists found")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            if musicManager.playlists.isEmpty && musicManager.isAuthenticated {
                Task {
                    await musicManager.loadUserPlaylists()
                }
            }
        }
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.orange.opacity(0.1))
        )
    }
}

// MARK: - Music Service Selection View
struct MusicServiceSelectionView: View {
    @ObservedObject var musicManager: MusicServiceManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Choose Music Service")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Connect your music service to play playlists while cooking")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Service options
                VStack(spacing: 16) {
                    serviceButton(.appleMusic)
                    serviceButton(.spotify)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func serviceButton(_ service: MusicServiceType) -> some View {
        Button(action: {
            Task {
                await musicManager.authenticateService(service)
                if musicManager.isAuthenticated {
                    dismiss()
                }
            }
        }) {
            HStack(spacing: 16) {
                if service == .spotify {
                    Image("spotify-icon")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                } else {
                    Image("apple-music-icon")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(service == .appleMusic ? "Use Apple Music to play a playlist from your library. Apple Music subscription is required." : "Use Spotify to play a playlist from your library")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if musicManager.isLoading && musicManager.currentService == service {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: service == .appleMusic ? [Color.pink, Color.purple] : [Color.green, Color.mint],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: service.color.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(musicManager.isLoading)
    }
}

// MARK: - Playlist Selection View
struct PlaylistSelectionView: View {
    @ObservedObject var musicManager: MusicServiceManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    // Handle playlist selection based on user type and service
    private func handlePlaylistSelection(_ playlist: MusicPlaylist) async {
        if musicManager.currentService == .spotify && !musicManager.isPremiumUser {
            // Free Spotify users: Use deep link to open playlist in Spotify app
            await openSpotifyPlaylistDeepLink(playlist)
        } else {
            // Apple Music users and Spotify Premium users: Use Web API for playback control
            await musicManager.playPlaylist(playlist)
        }
    }
    
    // Open Spotify playlist using deep link for free users
    private func openSpotifyPlaylistDeepLink(_ playlist: MusicPlaylist) async {
        guard let url = URL(string: "spotify:playlist:\(playlist.id)") else { return }
        
        if await UIApplication.shared.canOpenURL(url) {
            await UIApplication.shared.open(url)
        } else {
            // Fallback to web URL if Spotify app is not installed
            if let webURL = URL(string: "https://open.spotify.com/playlist/\(playlist.id)") {
                await UIApplication.shared.open(webURL)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Playlists list
                if musicManager.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading playlists...")
                        Spacer()
                    }
                } else if musicManager.playlists.isEmpty {
                    VStack {
                        Spacer()
                        Text("No playlists found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Try searching or check your library")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(musicManager.playlists) { playlist in
                                PlaylistRow(playlist: playlist) {
                                    Task {
                                        await handlePlaylistSelection(playlist)
                                        dismiss()
                                    }
                                }
                                .environmentObject(musicManager)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await musicManager.loadUserPlaylists()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search playlists...", text: $searchText)
                .textFieldStyle(.plain)
                .onSubmit {
                    Task {
                        await musicManager.searchPlaylists(query: searchText)
                    }
                }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
}

// MARK: - Playlist Row
struct PlaylistRow: View {
    let playlist: MusicPlaylist
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Playlist artwork
                AsyncImage(url: playlist.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: playlist.source.icon)
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                // Playlist info
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !playlist.description.isEmpty {
                        Text(playlist.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text("\(playlist.trackCount) songs")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Spacer()
                
                // Service icon
                Image(systemName: playlist.source.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(playlist.source.color)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Playlist Row
struct PlaylistRowCompact: View {
    let playlist: MusicPlaylist
    let action: () -> Void
    @EnvironmentObject private var musicManager: MusicServiceManager
    
    private var isSpotifyFreeUser: Bool {
        musicManager.currentService == .spotify && !musicManager.isPremiumUser
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                // Playlist artwork (smaller)
                AsyncImage(url: playlist.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: playlist.source.icon)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                
                // Playlist info
                VStack(alignment: .leading, spacing: 2) {
                    Text(playlist.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(playlist.trackCount) songs")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                Spacer()
                
                // Play icon or external link icon for free Spotify users
                if isSpotifyFreeUser {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Open")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(playlist.source.color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(playlist.source.color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Music Player (for CookNow)
struct CompactMusicPlayer: View {
    @StateObject private var musicManager = MusicServiceManager()
    
    var body: some View {
        if musicManager.currentTrack != nil {
            HStack(spacing: 8) {
                // Album art (small)
                AsyncImage(url: musicManager.currentTrack?.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                
                // Track info
                VStack(alignment: .leading, spacing: 1) {
                    Text(musicManager.currentTrack?.title ?? "")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(musicManager.currentTrack?.artist ?? "")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Play/pause button
                Button(action: {
                    Task {
                        if musicManager.isPlaying {
                            await musicManager.pauseMusic()
                        } else {
                            await musicManager.resumeMusic()
                        }
                    }
                }) {
                    Image(systemName: musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
        }
    }
}
