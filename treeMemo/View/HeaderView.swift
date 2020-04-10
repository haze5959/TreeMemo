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
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                //설정 버튼
                Button(action: {
                    self.environment.openSideMenu.toggle()
                }, label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(Color(.label))
                })
                
                //스페이서
                Spacer()
                
                //타이틀
                Text(self.treeMemoState.treeHierarchy.last ?? "TreeMemo")
                
                //스페이서
                Spacer()
                
                //편집 버튼
                Button(action: {
                    self.environment.isEdit.toggle()
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
                    self.treeMemoState.treeHierarchy.removeAll()
                }, label: {
                    Image(systemName: "house")
                        .imageScale(.small)
                        .padding()
                        .foregroundColor(Color(.label))
                })
                
                if self.treeMemoState.treeHierarchy.count > 0 {
                    ForEach(0..<self.treeMemoState.treeHierarchy.count, id: \.self) { index in
                        HStack {
                            Image(systemName: "chevron.compact.right")
                                .imageScale(.small)
                                .foregroundColor(Color(.label))
                            
                            Button(action: {
                                TreeMemoState.shared.selectTreeHierarchy(index: index)
                            }, label: {
                                Text(self.treeMemoState.treeHierarchy[index])
                                    .font(Font.system(size: 10))
                                    .lineLimit(2)
                                    .padding()
                                    .foregroundColor(Color(.label))
                                    .frame(maxWidth: 80)
                            })
                        }
                    }
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
