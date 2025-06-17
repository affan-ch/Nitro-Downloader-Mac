
// Sidebar View.swift


import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: SidebarViewModel
    
    var body: some View {
        NavigationSplitView {
            Spacer()

            List(selection: $viewModel.selectedItem) {
                
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
                        Label("Musics", systemImage: "music.quarternote.3")
                    }
                    NavigationLink(value: SidebarItem.thumbnails) {
                        Label("Thumbnails", systemImage: "photo")
                    }
                    NavigationLink(value: SidebarItem.socialMedia) {
                        Label("Social Media", systemImage: "person.2.fill")
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
                    NavigationLink(value: SidebarItem.siteGrabber) {
                        Label("Site Grabber", systemImage: "safari")
                    }
                }
                
                Spacer()
                
                Text("UTILITY TOOLS")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                
                Group {
                    NavigationLink(value: SidebarItem.formatConverter) {
                        Label("Format Converter", systemImage: "arrow.left.arrow.right")
                    }
                    NavigationLink(value: SidebarItem.trimAndClip) {
                        Label("Trim & Clip", systemImage: "scissors")
                    }
                    NavigationLink(value: SidebarItem.resizeAndCompress) {
                        Label("Resize & Compress", systemImage: "rectangle.compress.vertical")
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
                switch viewModel.selectedItem {
                case .videos: VideosView()
                case .playlists: PlaylistsView()
                case .musics: MusicsView()
                case .thumbnails: ThumbnailsView()
                case .socialMedia: SocialMediaView()
                case .files: FilesView()
                case .torrents: TorrentsView()
                case .ftps: FTPsView()
                case .siteGrabber: SiteGrabberView()
                case .trimAndClip: TrimAndClipView()
                case .resizeAndCompress: ResizeAndCompressView()
                case .formatConverter: FormatConverterView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
    }
}
