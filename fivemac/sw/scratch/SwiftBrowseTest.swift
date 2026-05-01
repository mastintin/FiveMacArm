import SwiftUI

struct Item: Identifiable {
    let id: Int
    var name: String = "Item Name"
}

@Observable
class TestModel {
    var items = (1...10).map { Item(id: $0) }
    var selection: Item.ID?
}

struct SwiftBrowseTestView: View {
    @State private var model = TestModel()
    
    var body: some View {
        Table(model.items, selection: $model.selection) {
            TableColumn("ID") { item in
                Text("\(item.id)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture(count: 2).onEnded {
                        print(">>> CELL DOUBLE CLICK: Row \(item.id) <<<")
                    })
            }
            TableColumn("Name") { item in
                Text(item.name)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture(count: 2).onEnded {
                        print(">>> CELL DOUBLE CLICK: Row \(item.id) <<<")
                    })
            }
        }
        .tableStyle(.inset)
        .frame(width: 400, height: 300)
    }
}

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            SwiftBrowseTestView()
        }
    }
}
