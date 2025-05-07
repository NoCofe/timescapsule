import SwiftUI
import AVFoundation

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var entryText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var isRecording: Bool = false
    @State private var recordingTime: TimeInterval = 0
    @State private var audioURL: URL? = nil
    @State private var audioDuration: TimeInterval = 0
    @State private var selectedSpace: String = "家庭 / 孩子"
    @State private var selectedMood: Mood? = nil
    @State private var futureDate: String? = nil
    @State private var showImagePicker = false
    
    // 心情数据
    private let moods: [Mood] = [
        Mood(id: "happy", icon: "🌞", name: "开心", color: .happyColor),
        Mood(id: "calm", icon: "⛅", name: "平静", color: .calmColor),
        Mood(id: "busy", icon: "🌪", name: "忙碌", color: .busyColor),
        Mood(id: "anxious", icon: "🌩", name: "焦虑", color: .anxiousColor),
        Mood(id: "sad", icon: "🌧", name: "低落", color: .sadColor),
        Mood(id: "neutral", icon: "❄️", name: "冷漠", color: .neutralColor)
    ]
    
    // 音频会话和录制器
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 未来时间提示（如果有）
                    if let date = futureDate {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text("写给\(date)的自己")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // 文本输入区域
                    VStack {
                        TextEditor(text: $entryText)
                            .frame(minHeight: 120)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if entryText.isEmpty {
                                        Text("记录下此刻的想法...")
                                            .foregroundColor(.gray.opacity(0.7))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                        
                        // 下方工具栏
                        HStack {
                            Button {
                                showImagePicker = true
                            } label: {
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                        
                        // 录音状态
                        if isRecording {
                            HStack {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.red)
                                Text("正在录音... \(formatDuration(recordingTime))")
                                    .foregroundColor(.red)
                                Spacer()
                                Button("取消") {
                                    cancelRecording()
                                }
                                .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.top, 8)
                        }
                        
                        // 音频播放器（仅在有录音时显示）
                        if let _ = audioURL, !isRecording {
                            HStack {
                                Button {
                                    togglePlayback()
                                } label: {
                                    Image(systemName: audioPlayer?.isPlaying ?? false ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.blue)
                                }
                                
                                // 进度条
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 4)
                                        
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: getPlaybackProgress() * geometry.size.width, height: 4)
                                    }
                                    .cornerRadius(2)
                                }
                                .frame(height: 4)
                                
                                Text(formatDuration(audioDuration))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Button {
                                    deleteRecording()
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    
                    // 已选择的图片展示
                    if !selectedImages.isEmpty {
                        VStack(alignment: .leading) {
                            Text("已选择 \(selectedImages.count) 张图片")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.bottom, 4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(selectedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedImages[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .cornerRadius(8)
                                                .clipped()
                                            
                                            Button {
                                                selectedImages.remove(at: index)
                                            } label: {
                                                ZStack {
                                                    Circle()
                                                        .fill(Color.black.opacity(0.6))
                                                        .frame(width: 24, height: 24)
                                                    
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(4)
                                        }
                                    }
                                    
                                    // 添加更多图片的按钮
                                    Button {
                                        showImagePicker = true
                                    } label: {
                                        VStack {
                                            Image(systemName: "plus")
                                                .font(.system(size: 24))
                                            Text("添加图片")
                                                .font(.caption)
                                        }
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    }
                    
                    // 空间选择
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                        Text("当前空间")
                            .foregroundColor(.gray)
                        Spacer()
                        
                        HStack {
                            Text(selectedSpace)
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    
                    // 心情选择
                    VStack(spacing: 12) {
                        HStack {
                            Text("图片/视频/音频")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("管理")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        // 水平滚动的心情标签
                        HStack(spacing: 10) {
                            Button {
                                selectedMood = moods.first(where: { $0.id == "happy" })
                            } label: {
                                Text("开心")
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(selectedMood?.id == "happy" ? .happyColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedMood?.id == "happy" ? .white : .black)
                                    .cornerRadius(16)
                            }
                            
                            Button {
                                selectedMood = moods.first(where: { $0.id == "calm" })
                            } label: {
                                Text("平静")
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(.calmColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                            
                            Button {
                                selectedMood = moods.first(where: { $0.id == "busy" })
                            } label: {
                                Text("难过")
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(selectedMood?.id == "busy" ? .busyColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedMood?.id == "busy" ? .white : .black)
                                    .cornerRadius(16)
                            }
                            
                            Button {
                                selectedMood = moods.first(where: { $0.id == "anxious" })
                            } label: {
                                Text("兴奋")
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(selectedMood?.id == "anxious" ? .anxiousColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedMood?.id == "anxious" ? .white : .black)
                                    .cornerRadius(16)
                            }
                            
                            Button {
                                selectedMood = moods.first(where: { $0.id == "sad" })
                            } label: {
                                Text("疲惫")
                                    .font(.system(size: 15))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(selectedMood?.id == "sad" ? .sadColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedMood?.id == "sad" ? .white : .black)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("添加记录")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveEntry()
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $selectedImages, isPresented: $showImagePicker)
            }
            .overlay(
                VStack {
                    Spacer()
                    
                    // 语音输入悬浮按钮
                    Button {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : Color.white)
                                .frame(width: 70, height: 70)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 28))
                                .foregroundColor(isRecording ? .white : .black)
                        }
                    }
                    .padding(.bottom, 20)
                }
            )
        }
    }
    
    // 开始录音
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            audioURL = audioFilename
            isRecording = true
            recordingTime = 0
            
            // 启动计时器
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.recordingTime += 1
            }
        } catch {
            print("录音失败: \(error.localizedDescription)")
        }
    }
    
    // 停止录音
    private func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false
        
        // 获取录音时长
        if let url = audioURL {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioDuration = audioPlayer.duration
            } catch {
                print("获取录音时长失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 取消录音
    private func cancelRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        isRecording = false
        
        // 删除文件
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        audioURL = nil
    }
    
    // 删除录音
    private func deleteRecording() {
        audioPlayer?.stop()
        
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        audioURL = nil
    }
    
    // 播放/暂停录音
    private func togglePlayback() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
            } else {
                player.play()
            }
        } else if let url = audioURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = ContextWrapper(context: self).avAudioPlayerDelegate
                audioPlayer?.play()
            } catch {
                print("播放失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 获取播放进度
    private func getPlaybackProgress() -> CGFloat {
        guard let player = audioPlayer, player.duration > 0 else { return 0 }
        return CGFloat(player.currentTime / player.duration)
    }
    
    // 格式化时长
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 保存记录
    private func saveEntry() {
        // 这里应该实现保存到数据库的逻辑
        // 包括文本、图片、音频URL和选择的心情
        
        // 完成后返回
        presentationMode.wrappedValue.dismiss()
    }
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// 心情模型
struct Mood {
    let id: String
    let icon: String
    let name: String
    let color: Color
}

// AVAudioPlayerDelegate 包装器
class ContextWrapper {
    private var context: AddEntryView
    
    init(context: AddEntryView) {
        self.context = context
    }
    
    lazy var avAudioPlayerDelegate: AVAudioPlayerDelegate = AVAudioPlayerDelegateImpl(context: context)
    
    private class AVAudioPlayerDelegateImpl: NSObject, AVAudioPlayerDelegate {
        private var context: AddEntryView
        
        init(context: AddEntryView) {
            self.context = context
        }
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            // 播放结束后的处理
        }
    }
} 