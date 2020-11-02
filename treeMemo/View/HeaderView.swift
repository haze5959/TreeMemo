//
//  HeaderView.swift
//  treeMemo
//
//  Created by OGyu kwon on 2019/11/22.
//  Copyright © 2019 OGyu kwon. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var environment: EnvironmentState
    @ObservedObject var treeMemoState = TreeMemoState.shared
    
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                //설정 버튼
                Button(action: {
                    self.environment.openSideMenu.toggle()
                    self.impactMed.impactOccurred()
                }, label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(Color(.label))
                })
                
                //스페이서
                Spacer()
                
                //타이틀
                Text(self.treeMemoState.treeHierarchy.last ?? "Tree Memo")
                
                //스페이서
                Spacer()
                
                //편집 버튼
                Button(action: {
                    self.environment.isEdit.toggle()
                    self.impactMed.impactOccurred()
                }, label: {
                    Image(systemName: "list.number")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(Color(.label))
                })
            }
            
            //계층 정보
            HStack {
                Button(action: {
                    self.treeMemoState.selectTreeHierarchy(index: 0)
                    self.impactMed.impactOccurred()
                }, label: {
                    Image(systemName: "house")
                        .imageScale(.small)
                        .padding()
                        .foregroundColor(Color(.label))
                })
                
                ForEach(0..<self.treeMemoState.treeHierarchy.count, id: \.self) { index in
                    Image(systemName: "chevron.compact.right")
                        .imageScale(.small)
                        .padding(.vertical)
                        .foregroundColor(Color(.label))
                    
                    Button(action: {
                        self.treeMemoState.selectTreeHierarchy(index: index + 1)
                        self.impactMed.impactOccurred()
                    }, label: {
                        Text(self.treeMemoState.treeHierarchy[index])
                            .font(Font.system(size: 10))
                            .lineLimit(2)
                            .padding(.vertical)
                            .foregroundColor(Color(.label))
                            .frame(maxWidth: 80)
                    })
                }
                
                //스페이서
                Spacer()
            }
        }
    }
}

// MARK: Preview
struct Header_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            HeaderView()
            //            .environment(\.colorScheme, .dark)
        }.previewLayout(.sizeThatFits)
            .padding(10)
    }
}
