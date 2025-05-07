import SwiftUI
import AVFoundation
import Photos

struct AddRecordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var recordType: RecordType = .text
    @State private var content = ""
    @State private var selectedMood: MoodTag = .neutral
    
    // 图片相关状态
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var showCamera = false
    
    // 音频相关状态
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    
    // 视频相关状态
    @State private var videoURL: URL?
    @State private var showVideoCamera = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 导航栏
            HStack {
                Button("取消") { dismiss() }
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("添加记录")
                    .font(.headline)
                
                Spacer()
                
                Button("保存") {
                    saveRecord()
                    dismiss()
                }
                .foregroundColor(.blue)
                .disabled(!canSaveRecord)
            }
            .padding()
            
            // 主内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // 内容输入区
                    VStack(alignment: .leading, spacing: 5) {
                        Text("内容")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // 媒体缩略图区域
                    mediaGallerySection
                    
                    // 心情选择区
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            ForEach([MoodTag.happy, .neutral, .sad, .excited, .tired], id: \.self) { mood in
                                Button(action: { selectedMood = mood }) {
                                    Text(mood.rawValue)
                                        .font(.system(size: 16))
                                        .foregroundColor(selectedMood == mood ? .white : .gray)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(selectedMood == mood ? moodColor(mood) : Color.gray.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                .padding(.trailing, 5)
                            }
                        }
                    }
                }
                .padding()
            }
            
            // 底部录音按钮
            ZStack {
                Divider()
                HStack {
                    Spacer()
                    
                    Button(action: isRecording ? stopRecording : startRecording) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : Color(UIColor.systemGray5))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 30))
                                .foregroundColor(isRecording ? .white : .black)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .background(Color.white)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $selectedImages)
        }
    }
    
    // 媒体缩略图区域
    var mediaGallerySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("图片/视频/音频")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: { }) {
                    Text("管理")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // 已有图片
                    ForEach(0..<selectedImages.count, id: \.self) { index in
                        mediaThumbnail(for: .image, image: selectedImages[index])
                    }
                    
                    // 已有音频
                    if audioURL != nil {
                        mediaThumbnail(for: .audio)
                    }
                    
                    // 已有视频
                    if videoURL != nil {
                        mediaThumbnail(for: .video)
                    }
                    
                    // 添加媒体按钮
                    addMediaButton
                }
            }
            .frame(height: 100)
        }
    }
    
    // 媒体缩略图
    func mediaThumbnail(for type: RecordType, image: UIImage? = nil) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(thumbnailColor(for: type))
                .frame(width: 90, height: 90)
            
            if type == .image, let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: thumbnailIcon(for: type))
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            
            // 删除按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // 删除对应的媒体
                        if type == .image, let _ = image {
                            if let index = selectedImages.firstIndex(where: { $0 == image }) {
                                selectedImages.remove(at: index)
                            }
                        } else if type == .audio {
                            audioURL = nil
                        } else if type == .video {
                            videoURL = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                    }
                }
                Spacer()
            }
            .padding(5)
        }
        .onTapGesture {
            // 点击预览/播放
        }
    }
    
    // 添加媒体按钮
    var addMediaButton: some View {
        Button(action: {
            showMediaActionSheet()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 90, height: 90)
                
                VStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    
                    Text("添加")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // 媒体选择菜单
    func showMediaActionSheet() {
        // 在实际应用中，这里应该显示一个动作表，让用户选择拍照、选择照片、录制视频等
        // 由于SwiftUI中无法直接在视图中显示UIAlertController，
        // 这里我们简化为直接打开图片选择器
        showImagePicker = true
    }
    
    // 缩略图颜色
    func thumbnailColor(for type: RecordType) -> Color {
        switch type {
        case .text: return .blue
        case .audio: return .orange
        case .image: return .purple
        case .video: return .green
        }
    }
    
    // 缩略图图标
    func thumbnailIcon(for type: RecordType) -> String {
        switch type {
        case .text: return "text.bubble.fill"
        case .audio: return "waveform"
        case .image: return "photo.fill"
        case .video: return "video.fill"
        }
    }
    
    // 心情颜色
    func moodColor(_ mood: MoodTag) -> Color {
        switch mood {
        case .happy: return .green
        case .excited: return .pink
        case .neutral: return .blue
        case .sad: return .gray
        case .tired: return .brown
        }
    }
    
    // 判断是否可以保存记录
    var canSaveRecord: Bool {
        return !content.isEmpty || !selectedImages.isEmpty || audioURL != nil || videoURL != nil
    }
    
    // MARK: - 音频录制方法
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // 设置录音文件URL
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            // 录音设置
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // 创建录音机
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            // 更新状态
            isRecording = true
            recordingTime = 0
            audioURL = audioFilename
            
            // 开始计时
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                recordingTime += 0.1
            }
            
        } catch {
            print("录音设置失败: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        isRecording = false
    }
    
    // MARK: - 保存记录方法
    func saveRecord() {
        // 确定记录类型
        var type: RecordType = .text
        if !selectedImages.isEmpty {
            type = .image
        } else if audioURL != nil {
            type = .audio
        } else if videoURL != nil {
            type = .video
        }
        
        let newRecord = Record(
            id: UUID(),
            type: type,
            content: content.isEmpty ? "新建记录" : content,
            date: Date(),
            moodTag: selectedMood,
            location: nil
        )
        
        // 发送通知以更新记录列表
        NotificationCenter.default.post(name: NSNotification.Name("newRecordAdded"), object: newRecord)
    }
}

// MARK: - 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
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
            
            // 不关闭选择器，允许继续选择更多图片
            // parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 相机视图
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image.append(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 