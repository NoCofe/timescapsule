import SwiftUI

struct ContentView: View {
    @State private var records: [Record] = []
    @State private var showingAddRecord = false
    
    var body: some View {
        NavigationView {
            List(records) { record in
                RecordRow(record: record)
            }
            .navigationTitle("时光胶囊")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecord = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                AddRecordView()
            }
        }
    }
}