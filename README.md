# Nitro Downloader ⚡️

**Nitro Downloader** is a modern macOS download manager built using Swift and SwiftUI. It provides an easy-to-use interface for downloading a wide range of content, from videos to torrents, and even bulk downloads from social media profiles. With support for **yt-dlp**, **aria2c**, and **ffmpeg**, Nitro Downloader offers versatile, efficient, and customizable download management.

## Features 🌟

- **Download Manager**: 
  - Easily download files, videos, thumbnails, playlists, and more by pasting HTTP/HTTPS links.
  
- **Torrent Downloads**: 
  - Seamlessly download torrents with the **aria2c** backend.

- **Resume & Pause Downloads**: 
  - Pause and resume your downloads anytime, ensuring uninterrupted progress.

- **Download Speed Control**: 
  - Adjust download speeds to optimize your network usage and avoid bandwidth congestion.

- **Customizable Themes**: 
  - Choose from a variety of themes to personalize the interface according to your preferences.

- **System Tray Icon**: 
  - The app minimizes to the system tray, offering easy access without cluttering your desktop.

- **Background Process**: 
  - Nitro Downloader runs in the background, continuing downloads without interrupting your workflow.

- **Comprehensive Download Capabilities**: 
  - Supports video, playlists, thumbnails, torrents, and more. Whether it's direct links or complex files, Nitro Downloader can handle them all.

- **Bulk Downloading**: 
  - Easily download multiple videos or media files from social media profiles like Instagram, Twitter, Facebook, and TikTok.

## Technologies Used 🛠️

- **Swift**: The heart of Nitro Downloader, providing fast and efficient performance.
- **SwiftUI**: For a smooth and beautiful user interface on macOS.
- **yt-dlp**: A command-line tool for downloading videos from a variety of websites.
- **aria2c**: A fast and multi-protocol download utility that supports torrents, HTTP, FTP, and more.
- **ffmpeg**: A comprehensive solution for video/audio conversion, streaming, and manipulation.

## Installation 🔧

1. Clone the repository:
   ```bash
   git clone https://github.com/affan-ch/nitro-downloader-mac.git
   ```
   
2. Navigate to the project directory:
   ```bash
   cd nitro-downloader-mac
   ```

3. Open the project in Xcode:
   ```bash
   open NitroDownloader.xcodeproj
   ```

4. Build and run the app via Xcode, or download the latest `.dmg` release from the [Releases](https://github.com/affan-ch/nitro-downloader-mac/releases) section.

## Usage 📥

1. **Download Files**:
   - Paste any HTTP/HTTPS link into the app to start downloading.
   
2. **Download Torrents**:
   - Add your `.torrent` files or magnet links, and Nitro Downloader will handle the rest with the **aria2c** backend.
   
3. **Bulk Downloading from Social Media**:
   - Add profile URLs from platforms like Instagram, Twitter, Facebook, and TikTok to download multiple media files at once.
   
4. **Manage Downloads**:
   - Pause, resume, or cancel any active download using the intuitive interface.

5. **Control Speed**:
   - Adjust the speed slider to set your download speed, optimizing it for other network activities.

6. **Custom Themes**:
   - Customize the look of the app through the Settings menu, choosing from multiple themes.


## Roadmap 🚀

- [ ] **Advanced Queueing**: Add the ability to queue multiple downloads and prioritize them.
- [ ] **Download History**: Track and view your past downloads.
- [ ] **macOS Notifications**: Get notified when downloads are completed or fail.
- [ ] **Enhanced Speed Controls**: Fine-tune download speeds for each individual download.

## Contributing 🤝

We welcome contributions! If you'd like to contribute to Nitro Downloader, please fork the repo, create a new branch, and submit a pull request with your changes. Be sure to include tests and documentation where applicable.

### How to Contribute:
1. Fork this repository.
2. Create a feature branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

## License 📜

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Enjoy fast, efficient, and reliable downloads with **Nitro Downloader**! 🚀
