import SwiftUI
import MediaPlayer
import MusicKit
import AVFoundation

// MARK: - Music Service Protocol
protocol MusicServiceProtocol {
    func authenticate() async throws
    func searchPlaylists(query: String) async throws -> [MusicPlaylist]
    func playPlaylist(_ playlist: MusicPlaylist) async throws
    func pause() async throws
    func resume() async throws
    func skipTrack() async throws
    func getCurrentTrack() async -> MusicTrack?
    var isPlaying: Bool { get }
    var isAuthenticated: Bool { get }
}

// MARK: - Music Service Manager
@MainActor
class MusicServiceManager: ObservableObject {
    @Published var currentService: MusicServiceType = .none
    @Published var isPlaying = false
    @Published var currentTrack: MusicTrack?
    @Published var playlists: [MusicPlaylist] = []
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPremiumUser = true // Default to premium for Apple Music, will be updated for Spotify
    
    private var appleMusic = AppleMusicService()
    private var spotify = SpotifyService()
    
    private var activeService: MusicServiceProtocol? {
        switch currentService {
        case .appleMusic:
            return appleMusic
        case .spotify:
            return spotify
        case .none:
            return nil
        }
    }
    
    // MARK: - Authentication
    func authenticateService(_ service: MusicServiceType) async {
        isLoading = true
        errorMessage = nil
        currentService = service
        
        do {
            try await activeService?.authenticate()
            
            // Wait a moment and check again for Spotify OAuth flow
            if service == .spotify {
                // Give time for OAuth callback to complete
                for _ in 0..<30 { // Wait up to 15 seconds
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    if activeService?.isAuthenticated == true {
                        break
                    }
                }
            }
            
            isAuthenticated = activeService?.isAuthenticated ?? false
            
            if isAuthenticated {
                print("✅ Authentication successful for \(service.rawValue)")
                
                // Update premium status for Spotify
                if service == .spotify, let spotifyService = spotify as? SpotifyService {
                    // Wait for premium status to be checked
                    for _ in 0..<10 { // Wait up to 5 seconds
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        if spotifyService.hasPremiumAccess || !spotifyService.hasPremiumAccess {
                            break // Status has been determined
                        }
                    }
                    isPremiumUser = spotifyService.hasPremiumAccess
                } else {
                    // Apple Music users are always considered "premium"
                    isPremiumUser = true
                }
                
                await loadUserPlaylists()
                
                // Start track update timer for Apple Music to detect existing playback
                if service == .appleMusic {
                    startTrackUpdateTimer()
                    // Check for current track immediately
                    if let currentTrack = await activeService?.getCurrentTrack() {
                        self.currentTrack = currentTrack
                        self.isPlaying = activeService?.isPlaying ?? false
                        print("🎵 Found existing Apple Music playback: \(currentTrack.title)")
                    }
                }
            } else {
                print("❌ Authentication failed for \(service.rawValue)")
                throw MusicError.authenticationFailed
            }
        } catch {
            print("🚨 Authentication error: \(error.localizedDescription)")
            errorMessage = "Authentication failed: \(error.localizedDescription)"
            currentService = .none
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    // MARK: - Playlist Management
    func loadUserPlaylists() async {
        guard let service = activeService, isAuthenticated else { return }
        
        isLoading = true
        do {
            playlists = try await service.searchPlaylists(query: "")
        } catch {
            errorMessage = "Failed to load playlists: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func searchPlaylists(query: String) async {
        guard let service = activeService, isAuthenticated else { return }
        
        isLoading = true
        do {
            playlists = try await service.searchPlaylists(query: query)
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // MARK: - Playback Control
    func playPlaylist(_ playlist: MusicPlaylist) async {
        guard let service = activeService else { return }
        
        do {
            try await service.playPlaylist(playlist)
            isPlaying = service.isPlaying
            
            // Wait a moment for playback to start, then get current track
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            currentTrack = await service.getCurrentTrack()
            
            // Start periodic updates for current track
            startTrackUpdateTimer()
        } catch {
            errorMessage = "Failed to play playlist: \(error.localizedDescription)"
        }
    }
    
    private func startTrackUpdateTimer() {
        Task {
            while currentService != .none && isAuthenticated {
                try await Task.sleep(nanoseconds: 3_000_000_000) // Check every 3 seconds
                
                if let service = activeService {
                    let updatedTrack = await service.getCurrentTrack()
                    let serviceIsPlaying = service.isPlaying
                    
                    await MainActor.run {
                        // Always update the track, even if it's nil
                        self.currentTrack = updatedTrack
                        self.isPlaying = serviceIsPlaying
                        
                        if let track = updatedTrack {
                            print("🔄 Track updated: \(track.title) - \(track.artist)")
                        } else {
                            print("🔄 No current track found")
                        }
                    }
                }
            }
        }
    }
    
    func pauseMusic() async {
        guard let service = activeService else { return }
        
        do {
            try await service.pause()
            isPlaying = service.isPlaying
        } catch {
            errorMessage = "Failed to pause: \(error.localizedDescription)"
        }
    }
    
    func resumeMusic() async {
        guard let service = activeService else { return }
        
        do {
            try await service.resume()
            isPlaying = service.isPlaying
        } catch {
            errorMessage = "Failed to resume: \(error.localizedDescription)"
        }
    }
    
    func skipTrack() async {
        guard let service = activeService else { return }
        
        do {
            try await service.skipTrack()
            currentTrack = await service.getCurrentTrack()
        } catch {
            errorMessage = "Failed to skip track: \(error.localizedDescription)"
        }
    }
    
    func disconnect() {
        currentService = .none
        isAuthenticated = false
        isPlaying = false
        currentTrack = nil
        playlists = []
    }
}

// MARK: - Apple Music Service
class AppleMusicService: MusicServiceProtocol {
    private let player = ApplicationMusicPlayer.shared
    
    var isPlaying: Bool {
        player.state.playbackStatus == .playing
    }
    
    var isAuthenticated: Bool {
        MusicAuthorization.currentStatus == .authorized
    }
    
    func authenticate() async throws {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            throw MusicError.authenticationFailed
        }
    }
    
    func searchPlaylists(query: String) async throws -> [MusicPlaylist] {
        let request: MusicLibraryRequest<Playlist>
        
        if query.isEmpty {
            // Get user's library playlists
            request = MusicLibraryRequest<Playlist>()
        } else {
            // Search for playlists
            var searchRequest = MusicCatalogSearchRequest(term: query, types: [Playlist.self])
            searchRequest.limit = 25
            let response = try await searchRequest.response()
            
            return response.playlists.compactMap { playlist in
                MusicPlaylist(
                    id: playlist.id.rawValue,
                    name: playlist.name,
                    description: playlist.shortDescription ?? "",
                    imageURL: playlist.artwork?.url(width: 300, height: 300),
                    trackCount: playlist.tracks?.count ?? 0,
                    source: .appleMusic,
                    musicKitPlaylist: playlist
                )
            }
        }
        
        let response = try await request.response()
        return response.items.map { playlist in
            MusicPlaylist(
                id: playlist.id.rawValue,
                name: playlist.name,
                description: playlist.shortDescription ?? "",
                imageURL: playlist.artwork?.url(width: 300, height: 300),
                trackCount: playlist.tracks?.count ?? 0,
                source: .appleMusic,
                musicKitPlaylist: playlist
            )
        }
    }
    
    func playPlaylist(_ playlist: MusicPlaylist) async throws {
        guard let musicKitPlaylist = playlist.musicKitPlaylist else {
            throw MusicError.playbackFailed
        }
        
        player.queue = [musicKitPlaylist]
        try await player.play()
    }
    
    func pause() async throws {
        player.pause()
    }
    
    func resume() async throws {
        try await player.play()
    }
    
    func skipTrack() async throws {
        try await player.skipToNextEntry()
    }
    
    func getCurrentTrack() async -> MusicTrack? {
        // First, try to get the current entry from our app's player queue
        if let currentEntry = player.queue.currentEntry {
            // Check if it's a Song from our player
            if let song = currentEntry.item as? Song {
                print("📱 Apple Music - Found current song from our player: \(song.title)")
                return MusicTrack(
                    id: song.id.rawValue,
                    title: song.title,
                    artist: song.artistName,
                    album: song.albumTitle ?? "",
                    imageURL: song.artwork?.url(width: 300, height: 300),
                    duration: song.duration ?? 0
                )
            }
            
            // If it's a Playlist entry, create a placeholder
            if let playlist = currentEntry.item as? Playlist {
                print("📱 Apple Music - Found playlist in queue: \(playlist.name)")
                return MusicTrack(
                    id: playlist.id.rawValue,
                    title: "Playing: \(playlist.name)",
                    artist: "Apple Music Playlist",
                    album: "\(playlist.tracks?.count ?? 0) songs",
                    imageURL: playlist.artwork?.url(width: 300, height: 300),
                    duration: 0
                )
            }
        }
        
        // If no queue entry from our app, try to get system-wide playback info
        // This will detect music playing from Apple Music app or other sources
        if let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            print("📱 Apple Music - Found system-wide now playing info")
            
            let title = nowPlayingInfo[MPMediaItemPropertyTitle] as? String ?? "Unknown Track"
            let artist = nowPlayingInfo[MPMediaItemPropertyArtist] as? String ?? "Unknown Artist"
            let album = nowPlayingInfo[MPMediaItemPropertyAlbumTitle] as? String ?? ""
            let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] as? TimeInterval ?? 0
            
            // Try to get artwork
            var imageURL: URL?
            if let artwork = nowPlayingInfo[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork {
                // For system artwork, we can't get a direct URL, but we can use a placeholder
                // The artwork will be handled by the UI layer
            }
            
            // Create a unique ID based on title and artist
            let trackId = "\(title)-\(artist)".replacingOccurrences(of: " ", with: "-")
            
            return MusicTrack(
                id: trackId,
                title: title,
                artist: artist,
                album: album,
                imageURL: imageURL,
                duration: duration
            )
        }
        
        print("📱 Apple Music - No current track found in queue or system")
        return nil
    }
}

// MARK: - Spotify Service (OAuth + Web API Implementation)
class SpotifyService: NSObject, MusicServiceProtocol {
    // MARK: - Configuration
    // 🔧 REPLACE THIS WITH YOUR SPOTIFY CLIENT ID FROM DEVELOPER DASHBOARD:
    private let clientID = "11b1f67711b2494aa1545f675971bcab" // Replace with your actual Client ID
    private let redirectURI = "fridgetorecipe://spotify-callback"
    private let scopes = "user-read-private user-read-email playlist-read-private playlist-read-collaborative user-modify-playback-state user-read-playback-state app-remote-control"
    
    // MARK: - OAuth State
    private var codeVerifier: String?
    private var codeChallenge: String?
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpirationDate: Date?
    
    // MARK: - User Subscription State
    private var isPremiumUser: Bool = false
    private var hasCheckedPremiumStatus: Bool = false
    
    // MARK: - Protocol Properties
    var isPlaying: Bool = false
    var isAuthenticated: Bool {
        return accessToken != nil && (tokenExpirationDate?.timeIntervalSinceNow ?? 0) > 0
    }
    
    // MARK: - Premium Status
    var hasPremiumAccess: Bool {
        return isPremiumUser
    }
    
    override init() {
        super.init()
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOAuthCallback(_:)),
            name: NSNotification.Name("SpotifyOAuthCallback"),
            object: nil
        )
    }
    
    // MARK: - Authentication
    func authenticate() async throws {
        await MainActor.run {
            startOAuthFlow()
        }
    }
    
    private func startOAuthFlow() {
        // Generate PKCE parameters
        codeVerifier = generateCodeVerifier()
        codeChallenge = generateCodeChallenge(from: codeVerifier!)
        
        // Build authorization URL
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]
        
        guard let authURL = components.url else {
            print("Failed to create authorization URL")
            return
        }
        
        // Open Safari for authentication
        UIApplication.shared.open(authURL)
    }
    
    @objc private func handleOAuthCallback(_ notification: Notification) {
        guard let url = notification.object as? URL else { 
            print("🔍 Spotify OAuth: No URL in callback notification")
            return 
        }
        
        print("🔍 Spotify OAuth: Handling callback URL: \(url)")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
            print("✅ Spotify OAuth: Authorization code received")
            Task {
                await exchangeCodeForTokens(code)
            }
        } else if let error = components?.queryItems?.first(where: { $0.name == "error" })?.value {
            print("❌ Spotify OAuth error: \(error)")
        } else {
            print("⚠️ Spotify OAuth: No code or error in callback URL")
        }
    }
    
    private func exchangeCodeForTokens(_ code: String) async {
        guard let codeVerifier = codeVerifier else { return }
        
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "code_verifier": codeVerifier
        ]
        
        let body = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let accessToken = response?["access_token"] as? String {
                self.accessToken = accessToken
                self.refreshToken = response?["refresh_token"] as? String
                
                if let expiresIn = response?["expires_in"] as? Int {
                    self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                }
                
                print("Spotify authentication successful")
                
                // Check premium status after successful authentication
                await checkPremiumStatus()
            }
        } catch {
            print("Token exchange failed: \(error)")
        }
    }
    
    // MARK: - Premium Status Detection
    private func checkPremiumStatus() async {
        guard let accessToken = accessToken, !hasCheckedPremiumStatus else { return }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let product = json?["product"] as? String {
                    isPremiumUser = (product == "premium")
                    hasCheckedPremiumStatus = true
                    
                    print("🎵 Spotify: User has \(product) subscription (Premium: \(isPremiumUser))")
                    
                    if !isPremiumUser {
                        print("⚠️ Spotify: Free user detected - playback control will be limited")
                    }
                }
            }
        } catch {
            print("Failed to check premium status: \(error)")
            // Default to free user if we can't determine
            isPremiumUser = false
            hasCheckedPremiumStatus = true
        }
    }
    
    // MARK: - Playlist Management
    func searchPlaylists(query: String) async throws -> [MusicPlaylist] {
        guard let accessToken = accessToken else {
            throw MusicError.authenticationFailed
        }
        
        let endpoint = query.isEmpty ?
            "https://api.spotify.com/v1/me/playlists" :
            "https://api.spotify.com/v1/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=playlist&limit=20"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if query.isEmpty {
                // User's playlists
                if let items = response?["items"] as? [[String: Any]] {
                    return items.compactMap { playlistData in
                        createMusicPlaylist(from: playlistData)
                    }
                }
            } else {
                // Search results
                if let playlists = response?["playlists"] as? [String: Any],
                   let items = playlists["items"] as? [[String: Any]] {
                    return items.compactMap { playlistData in
                        createMusicPlaylist(from: playlistData)
                    }
                }
            }
        } catch {
            throw MusicError.networkError(error.localizedDescription)
        }
        
        return []
    }
    
    private func createMusicPlaylist(from data: [String: Any]) -> MusicPlaylist? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String else {
            return nil
        }
        
        let description = data["description"] as? String ?? ""
        let trackCount = (data["tracks"] as? [String: Any])?["total"] as? Int ?? 0
        
        var imageURL: URL?
        if let images = data["images"] as? [[String: Any]],
           let firstImage = images.first,
           let urlString = firstImage["url"] as? String {
            imageURL = URL(string: urlString)
        }
        
        return MusicPlaylist(
            id: id,
            name: name,
            description: description,
            imageURL: imageURL,
            trackCount: trackCount,
            source: .spotify
        )
    }
    
    // MARK: - Playbook Control (Web API for Premium, Deep Link for Free)
    func playPlaylist(_ playlist: MusicPlaylist) async throws {
        guard let accessToken = accessToken else {
            print("🚨 Spotify: No access token available for playback")
            throw MusicError.authenticationFailed
        }
        
        print("🎵 Spotify: Attempting to play playlist: \(playlist.name) (ID: \(playlist.id))")
        
        if isPremiumUser {
            print("💎 Spotify Premium: Using Web API playback control")
            try await playPlaylistWithWebAPI(playlist)
        } else {
            print("🆓 Spotify Free: Using deep link to open in Spotify app")
            await playPlaylistWithDeepLink(playlist)
        }
    }
    
    private func playPlaylistWithWebAPI(_ playlist: MusicPlaylist) async throws {
        guard let accessToken = accessToken else {
            throw MusicError.authenticationFailed
        }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/player/play")!)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["context_uri": "spotify:playlist:\(playlist.id)"]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Spotify: Playback request response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 204 {
                    print("✅ Spotify: Playback started successfully")
                    isPlaying = true
                } else if httpResponse.statusCode == 404 {
                    print("⚠️ Spotify: No active device found")
                    throw MusicError.networkError("Please open Spotify app and start playing something first")
                } else {
                    // Try to parse error response
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = errorData["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("❌ Spotify API error: \(message)")
                        throw MusicError.networkError(message)
                    } else {
                        print("❌ Spotify: Unexpected response status \(httpResponse.statusCode)")
                        throw MusicError.networkError("Playback failed with status \(httpResponse.statusCode)")
                    }
                }
            }
        } catch let error as MusicError {
            throw error // Re-throw our custom errors
        } catch {
            print("🚨 Spotify: Network error during playback: \(error.localizedDescription)")
            throw MusicError.networkError("Playback failed: \(error.localizedDescription)")
        }
    }
    
    private func playPlaylistWithDeepLink(_ playlist: MusicPlaylist) async {
        // Create Spotify deep link URL
        let spotifyURL = URL(string: "spotify:playlist:\(playlist.id)")
        let spotifyWebURL = URL(string: "https://open.spotify.com/playlist/\(playlist.id)")
        
        await MainActor.run {
            // Try to open with Spotify app first
            if let spotifyURL = spotifyURL, UIApplication.shared.canOpenURL(spotifyURL) {
                print("✅ Opening playlist in Spotify app")
                UIApplication.shared.open(spotifyURL)
                // Set playing state since we opened the playlist
                isPlaying = true
            } else if let spotifyWebURL = spotifyWebURL {
                print("✅ Opening playlist in Spotify web")
                UIApplication.shared.open(spotifyWebURL)
                // Set playing state since we opened the playlist
                isPlaying = true
            } else {
                print("❌ Failed to create Spotify URLs")
            }
        }
    }
    
    func pause() async throws {
        try await controlPlayback("pause")
        isPlaying = false
    }
    
    func resume() async throws {
        try await controlPlayback("play")
        isPlaying = true
    }
    
    func skipTrack() async throws {
        try await controlPlayback("next")
    }
    
    private func controlPlayback(_ action: String) async throws {
        guard let accessToken = accessToken else {
            throw MusicError.authenticationFailed
        }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/player/\(action)")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw MusicError.networkError(error.localizedDescription)
        }
    }
    
    func getCurrentTrack() async -> MusicTrack? {
        guard let accessToken = accessToken else { return nil }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let item = json?["item"] as? [String: Any],
                   let id = item["id"] as? String,
                   let name = item["name"] as? String {
                    
                    let artists = (item["artists"] as? [[String: Any]])?.compactMap { $0["name"] as? String }.joined(separator: ", ") ?? "Unknown Artist"
                    let album = (item["album"] as? [String: Any])?["name"] as? String ?? ""
                    let duration = (item["duration_ms"] as? Int).map { TimeInterval($0) / 1000 } ?? 0
                    
                    var imageURL: URL?
                    if let albumData = item["album"] as? [String: Any],
                       let images = albumData["images"] as? [[String: Any]],
                       let firstImage = images.first,
                       let urlString = firstImage["url"] as? String {
                        imageURL = URL(string: urlString)
                    }
                    
                    self.isPlaying = json?["is_playing"] as? Bool ?? false
                    
                    return MusicTrack(
                        id: id,
                        title: name,
                        artist: artists,
                        album: album,
                        imageURL: imageURL,
                        duration: duration
                    )
                }
            }
        } catch {
            print("Failed to get current track: \(error)")
        }
        
        return nil
    }
    
    // MARK: - PKCE Helpers
    private func generateCodeVerifier() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<128).compactMap { _ in letters.randomElement() })
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else { return "" }
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64URLEncodedString()
    }
}

// MARK: - Data Extension for Base64 URL Encoding
extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - CryptoKit Import
import CryptoKit

// MARK: - Data Models
struct MusicPlaylist: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let imageURL: URL?
    let trackCount: Int
    let source: MusicServiceType
    
    // Store the actual MusicKit playlist for Apple Music
    let musicKitPlaylist: Playlist?
    
    init(id: String, name: String, description: String, imageURL: URL?, trackCount: Int, source: MusicServiceType, musicKitPlaylist: Playlist? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.trackCount = trackCount
        self.source = source
        self.musicKitPlaylist = musicKitPlaylist
    }
    
    static func == (lhs: MusicPlaylist, rhs: MusicPlaylist) -> Bool {
        lhs.id == rhs.id && lhs.source == rhs.source
    }
}

struct MusicTrack: Identifiable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let imageURL: URL?
    let duration: TimeInterval
}

enum MusicServiceType: String, CaseIterable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    case none = "None"
    
    var icon: String {
        switch self {
        case .appleMusic:
            return "music.note"
        case .spotify:
            return "music.note.list"
        case .none:
            return "music.note.slash"
        }
    }
    
    var color: Color {
        switch self {
        case .appleMusic:
            return .pink
        case .spotify:
            return .green
        case .none:
            return .gray
        }
    }
}

// MARK: - Errors
enum MusicError: LocalizedError {
    case authenticationFailed
    case playbackFailed
    case notImplemented
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Failed to authenticate with music service"
        case .playbackFailed:
            return "Failed to start playback"
        case .notImplemented:
            return "Feature not implemented yet"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
