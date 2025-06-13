//
//  ContentView.swift
//  Transcription
//
//  Created by Farasat's_MacBook_Pro on 13/06/2025.
//
import SwiftUI
import AVKit
import UniformTypeIdentifiers
import MediaTranscriberKit

struct MediaTranscriberView: View {
    @State private var selectedMedia: URL?
    @State private var player: AVPlayer?
    @State private var showTextCard = false
    @State private var transcribedText = "🎤 This is a sample transcription. Tap transcribe to get real results."
    @State private var showPicker = false
    @State private var mediaHistory: [URL] = []
    @State private var isTranscribing = false

    let transcriber = MediaTranscriberKit()

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Glass-like main container
                ScrollView {
                    VStack(spacing: 20) {
                        // Media Preview
                        if let player = player {
                            VideoPlayer(player: player)
                                .frame(height: 300)
                                .cornerRadius(16)
                                .shadow(radius: 8)
                                .padding(.horizontal)
                        } else {
                            // No Media Selected – Stylish Card
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.85)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 300)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

                                VStack(spacing: 12) {
                                    Image(systemName: "video.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)

                                    Text("No Media Selected")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Text("Tap the button below to choose an audio or video file.")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 16)
                                }
                                .padding()
                            }
                            .padding(.horizontal)



                        }

                        // Pick Media Button
                        Button(action: {
                            showPicker = true
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text("Pick Audio or Video")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color.green.opacity(0.8), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                        Button(action: {
                            guard let url = selectedMedia else { return }
                            isTranscribing = true
                            withAnimation {
                                showTextCard = true
                                transcribedText = "⏳ Transcribing..."
                            }

                            // MARK: - Call Local Package
                            transcriber.transcribeMedia(from: url) { text in
                                DispatchQueue.main.async {
                                    withAnimation {
                                        transcribedText = text ?? "⚠️ Failed to transcribe media."
                                        isTranscribing = false
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "waveform.circle.fill")
                                Text("Transcribe Media")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [Color.pink.opacity(0.85), Color.orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                        .disabled(selectedMedia == nil)

                        // Transcription Toggle Button
//                        Button(action: {
//                            withAnimation {
//                                showTextCard.toggle()
//                            }
//                        }) {
//                            HStack {
//                                Image(systemName: "text.bubble.fill")
//                                Text("Show Transcription")
//                                    .fontWeight(.semibold)
//                            }
//                            .font(.headline)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(
//                                LinearGradient(colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                            )
//                            .foregroundColor(.white)
//                            .cornerRadius(14)
//                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
//                            .padding(.horizontal)
//                        }

                        // Transcription Card
                        if showTextCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image(systemName: "text.alignleft")
                                        .font(.title2)
                                        .foregroundColor(.blue)

                                    Text("Transcription")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }

                                Text(transcribedText)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(4)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground)) // Dynamic for light/dark mode
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }


                        // Media History
                        if !mediaHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("📁 Recently Picked Media")
                                    .font(.title3)
                                    .bold()
                                    .padding(.horizontal)
                                    .foregroundColor(.white)

                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(spacing: 12) {
                                        ForEach(mediaHistory.reversed(), id: \.self) { url in
                                            Button(action: {
                                                selectedMedia = url
                                                player = AVPlayer(url: url)
                                            }) {
                                                HStack(spacing: 16) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.white.opacity(0.15))
                                                            .frame(width: 50, height: 50)

                                                        Image(systemName: url.pathExtension == "mp4" || url.pathExtension == "mov" ? "film.fill" : "waveform.circle.fill")
                                                            .font(.title2)
                                                            .foregroundColor(.white)
                                                    }

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(url.lastPathComponent)
                                                            .font(.headline)
                                                            .foregroundColor(.white)

                                                        Text(url.pathExtension.uppercased())
                                                            .font(.caption)
                                                            .foregroundColor(.white.opacity(0.7))
                                                    }

                                                    Spacer()

                                                    Image(systemName: "play.circle.fill")
                                                        .font(.title2)
                                                        .foregroundColor(.green)
                                                }
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.5)]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                                )
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .frame(maxHeight: 200)
                            }
                        }


                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
                .sheet(isPresented: $showPicker) {
                    MediaPicker { url in
                        selectedMedia = url
                        player = AVPlayer(url: url)
                        if !mediaHistory.contains(url) {
                            mediaHistory.append(url)
                        }
                    }
                }
                .navigationTitle("🎙️ Media Transcriber")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

//struct MediaTranscriberView: View {
//    @State private var selectedMedia: URL?
//    @State private var player: AVPlayer?
//    @State private var showTextCard = false
//    @State private var transcribedText = "🎤 This is a sample transcription. Tap transcribe to get real results."
//    @State private var showPicker = false
//    @State private var mediaHistory: [URL] = []
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//
//                // Media Preview
//                if let player = player {
//                    VideoPlayer(player: player)
//                        .frame(height: 300)
//                        .cornerRadius(16)
//                        .shadow(radius: 8)
//                        .padding(.horizontal)
//                } else {
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 300)
//                        .overlay(
//                            VStack {
//                                Image(systemName: "video.circle")
//                                    .font(.system(size: 50))
//                                    .foregroundColor(.gray)
//                                Text("No Media Selected")
//                                    .foregroundColor(.gray)
//                                    .font(.headline)
//                            }
//                        )
//                        .padding(.horizontal)
//                }
//
//                // Pick Media Button
//                Button(action: {
//                    showPicker = true
//                }) {
//                    HStack {
//                        Image(systemName: "folder.fill")
//                        Text("Pick Audio or Video")
//                            .fontWeight(.semibold)
//                    }
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(
//                        LinearGradient(colors: [Color.green.opacity(0.8), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
//                    )
//                    .foregroundColor(.white)
//                    .cornerRadius(14)
//                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
//                    .padding(.horizontal)
//                }
//
//
//                // Transcription Toggle Button
//                Button(action: {
//                    withAnimation {
//                        showTextCard.toggle()
//                    }
//                }) {
//                    HStack {
//                        Image(systemName: "text.bubble.fill")
//                        Text("Show Transcription")
//                            .fontWeight(.semibold)
//                    }
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(
//                        LinearGradient(colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
//                    )
//                    .foregroundColor(.white)
//                    .cornerRadius(14)
//                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 4)
//                    .padding(.horizontal)
//                }
//
//                // Transcription Card
//                if showTextCard {
//                    Text(transcribedText)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(12)
//                        .shadow(radius: 3)
//                        .padding(.horizontal)
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                }
//
//                // Media History
//                if !mediaHistory.isEmpty {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("📁 Recently Picked Media")
//                            .font(.title3)
//                            .bold()
//                            .padding(.horizontal)
//
//                        ScrollView(.vertical, showsIndicators: false) {
//                            VStack(spacing: 8) {
//                                ForEach(mediaHistory.reversed(), id: \.self) { url in
//                                    Button(action: {
//                                        selectedMedia = url
//                                        player = AVPlayer(url: url)
//                                    }) {
//                                        HStack(spacing: 12) {
//                                            ZStack {
//                                                RoundedRectangle(cornerRadius: 10)
//                                                    .fill(Color.blue.opacity(0.15))
//                                                    .frame(width: 50, height: 50)
//
//                                                Image(systemName: url.pathExtension == "mp4" || url.pathExtension == "mov" ? "film.fill" : "waveform.circle.fill")
//                                                    .font(.title2)
//                                                    .foregroundColor(.blue)
//                                            }
//
//                                            VStack(alignment: .leading, spacing: 4) {
//                                                Text(url.lastPathComponent)
//                                                    .font(.headline)
//                                                    .foregroundColor(.primary)
//                                                    .lineLimit(1)
//                                                    .truncationMode(.middle)
//
//                                                Text(url.pathExtension.uppercased())
//                                                    .font(.caption)
//                                                    .foregroundColor(.secondary)
//                                            }
//
//                                            Spacer()
//
//                                            Image(systemName: "play.circle.fill")
//                                                .font(.title2)
//                                                .foregroundColor(.green)
//                                        }
//                                        .padding()
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .fill(Color.white)
//                                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//                                        )
//                                    }
//                                    .padding(.horizontal)
//                                }
//                            }
//                        }
//                        .frame(maxHeight: 180)
//                    }
//                }
//
//                Spacer()
//            }
//            .sheet(isPresented: $showPicker) {
//                MediaPicker { url in
//                    selectedMedia = url
//                    player = AVPlayer(url: url)
//                    if !mediaHistory.contains(url) {
//                        mediaHistory.append(url)
//                    }
//                }
//            }
//            .navigationTitle("🎙️ Media Transcriber")
//        }
//    }
//}


// MARK: - Media Picker for Audio + Video
struct MediaPicker: UIViewControllerRepresentable {
    var onMediaPicked: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onMediaPicked: onMediaPicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.movie, .audio]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onMediaPicked: (URL) -> Void

        init(onMediaPicked: @escaping (URL) -> Void) {
            self.onMediaPicked = onMediaPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)

            do {
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(at: tempURL)
                }
                try FileManager.default.copyItem(at: url, to: tempURL)
                DispatchQueue.main.async {
                    self.onMediaPicked(tempURL)
                }
            } catch {
                print("Failed to copy file: \(error)")
            }
        }
    }
}

// MARK: - Preview
struct MediaTranscriberView_Previews: PreviewProvider {
    static var previews: some View {
        MediaTranscriberView()
    }
}

