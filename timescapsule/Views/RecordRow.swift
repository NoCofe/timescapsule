import SwiftUI

struct RecordRow: View {
    let record: Record
    
    var body: some View {
        HStack(spacing: 15) {
            // 记录类型标识
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(typeColor(record.type))
                    .frame(width: 40, height: 40)
                
                Image(systemName: typeIcon(record.type))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(formattedDate(record.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // 心情标签
                    Text(record.moodTag.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(moodColor(record.moodTag))
                        .cornerRadius(10)
                }
                
                Text(record.content)
                    .font(.body)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    func typeColor(_ type: RecordType) -> Color {
        switch type {
        case .text:
            return .blue
        case .audio:
            return .orange
        case .image:
            return .purple
        case .video:
            return .green
        }
    }
    
    func typeIcon(_ type: RecordType) -> String {
        switch type {
        case .text:
            return "text.bubble"
        case .audio:
            return "mic"
        case .image:
            return "photo"
        case .video:
            return "video"
        }
    }
    
    func moodColor(_ mood: MoodTag) -> Color {
        switch mood {
        case .happy:
            return .green
        case .excited:
            return .pink
        case .neutral:
            return .blue
        case .sad:
            return .gray
        case .tired:
            return .brown
        }
    }
}