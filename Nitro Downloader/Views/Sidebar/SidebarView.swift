
//  SidebarView.swift


import SwiftUI

struct SidebarView: View {
    @State private var selection: SidebarItem = .videos
    
    var body: some View {
        NavigationSplitView {
            
            Divider()
            
            List(selection: $selection) {
                
                Text("MEDIA DOWNLOADS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                
                Group{
                    NavigationLink(value: SidebarItem.videos) {
                        Label("Videos", systemImage: "film")
                    }
                    NavigationLink(value: SidebarItem.playlists) {
                        Label("Playlists", systemImage: "film.stack")
                    }
                    NavigationLink(value: SidebarItem.musics) {
                        Label("Musics", systemImage: "music.note")
                    }
                    NavigationLink(value: SidebarItem.thumbnails) {
                        Label("Thumbnails", systemImage: "photo")
                    }
                }
                
                Spacer()
                
                Text("GENERAL DOWNLOADS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                
                Group {
                    NavigationLink(value: SidebarItem.files) {
                        Label("Files", systemImage: "doc.on.doc")
                    }
                    NavigationLink(value: SidebarItem.torrents) {
                        Label("Torrents", systemImage: "network")
                    }
                    NavigationLink(value: SidebarItem.ftps) {
                        Label("FTPs", systemImage: "externaldrive")
                    }
                }
                
                Spacer()
                
                Text("SOCIAL MEDIA DOWNLOADS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                
                Group {
                    NavigationLink(value: SidebarItem.instagram) {
                        Label {
                            Text("Instagram")
                        } icon: {
                            Image("instagram")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(selection == .instagram ? .white : .blue)
                                .frame(width: 15, height: 15)
                        }
                    }
                    NavigationLink(value: SidebarItem.facebook) {
                        Label {
                            Text("Facebook")
                        } icon: {
                            Image("facebook")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(selection == .facebook ? .white : .blue)
                                .frame(width: 15, height: 15)
                        }
                    }
                    NavigationLink(value: SidebarItem.tiktok) {
                        Label {
                            Text("TikTok")
                        } icon: {
                            Image("tiktok")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(selection == .tiktok ? .white : .blue)
                                .frame(width: 15, height: 15)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Explore")
            .frame(minWidth: 200, idealWidth: 220)
            .navigationSplitViewStyle(.prominentDetail)
        }
        detail: {
            Group {
                switch selection {
                case .videos: VideosView()
                case .playlists: PlaylistsView()
                case .musics: MusicsView()
                case .thumbnails: ThumbnailsView()
                case .files: FilesView()
                case .torrents: TorrentsView()
                case .ftps: FTPsView()
                case .instagram: InstagramView()
                case .facebook: FacebookView()
                case .tiktok: TikTokView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
