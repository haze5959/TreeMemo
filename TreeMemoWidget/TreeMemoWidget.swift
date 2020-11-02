//
//  TreeMemoWidget.swift
//  TreeMemoWidget
//
//  Created by OGyu kwon on 2020/09/23.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: IntentTimelineProvider {
    typealias Entry = SimpleEntry
    
    typealias Intent = FolderNameIntent
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    data: [TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 0),
                           TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 1),
                           TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 2),
                           TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 3),
                           TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 4),
                           TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 5),
                           TreeModel(title: "Loading...",
                                     key: UUID(),
                                     index: 6)])
    }
    
    func getSnapshot(for configuration: FolderNameIntent,
                     in context: Context,
                     completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                data: [TreeModel(title: "✈️ Travel",
                                                 value: .date(val: TreeDateType(date: Date(), type: 4)),
                                                 key: UUID(),
                                                 index: 0),
                                       TreeModel(title: "🛍 Buying",
                                                 value: .text(val: "iWatch"),
                                                 key: UUID(),
                                                 index: 1),
                                       TreeModel(title: "Gym",
                                                 value: .child(key: UUID()),
                                                 key: UUID(),
                                                 index: 2),
                                       TreeModel(title: "Number",
                                                 value: .int(val: 7),
                                                 key: UUID(),
                                                 index: 3),
                                       TreeModel(title: "Todo",
                                                 value: .longText(recordName: "test"),
                                                 key: UUID(),
                                                 index: 4),
                                       TreeModel(title: "link",
                                                 value: .link(val: "test"),
                                                 key: UUID(),
                                                 index: 5),
                                       TreeModel(title: "test07",
                                                 key: UUID(),
                                                 index: 6)])
        completion(entry)
    }
    
    func getTimeline(for configuration: FolderNameIntent,
                     in context: Context,
                     completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
            TreeMemoState.shared.initTreeData()
            let data = TreeMemoState.shared.getTreeData(with: configuration.folderName)
            let entries: [SimpleEntry] = [SimpleEntry(date: Date(),
                                                      data: data)]
            
            let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let data: [TreeModel]
}

struct TreeMemoWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            ForEach(getData()) { treeData in
                TreeNode(treeData: treeData)
                    .buttonStyle(PlainButtonStyle())
            }.listRowBackground(Color.clear)
        }
    }
    
    func getData() -> [TreeModel] {
        var data = entry.data
        switch family {
        case .systemSmall, .systemMedium:
            if data.count > 2 {
                data = Array(data[0..<2])
            }
        case .systemLarge:
            if data.count > 6 {
                data = Array(data[0..<6])
            }
        @unknown default:
            break
        }
        
        return data
    }
}

@main
struct TreeMemoWidget: Widget {
    let kind: String = "TreeMemoWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: FolderNameIntent.self,
                            provider: Provider()) { (entry) in
            TreeMemoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My TreeMemo widget.")
        .description("You can change the folder location to show through 'Folder Name' editing.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TreeMemoWidget_Previews: PreviewProvider {
    static var previews: some View {
        TreeMemoWidgetEntryView(entry: SimpleEntry(date: Date(),
                                                   data: [TreeModel(title: "test01",
                                                                    key: UUID(),
                                                                    index: 0),
                                                          TreeModel(title: "test02",
                                                                    key: UUID(),
                                                                    index: 1),
                                                          TreeModel(title: "test03",
                                                                    key: UUID(),
                                                                    index: 2),
                                                          TreeModel(title: "test04",
                                                                    key: UUID(),
                                                                    index: 3),
                                                          TreeModel(title: "test05",
                                                                    key: UUID(),
                                                                    index: 4),
                                                          TreeModel(title: "test06",
                                                                    key: UUID(),
                                                                    index: 5),
                                                          TreeModel(title: "test07",
                                                                    key: UUID(),
                                                                    index: 6)]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
