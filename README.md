# 🚀 Unix Terminal BG Downloader/Uploader

An interactive background downloader and uploader for Linux/Unix terminals with a clean, user-friendly Command Line Interface (CLI). 

Tired of SSH disconnections ruining your massive file transfers? This tool utilizes `tmux` under the hood to ensure your downloads and uploads continue running in the background safely, even if you close your terminal. It features an interactive UI to build a queue of files, supports custom proxies, and prevents network drops with bandwidth limits.

## ✨ Features

- **Interactive CLI UI:** No need to write complex command arguments or create text files. The script asks you step-by-step for links, file paths, and names.
- **Queue System (Sequential Processing):** Add as many links or files as you want. They will be processed one by one automatically without packet loss.
- **True Background Execution:** Processes run in a detached `tmux` session. You can safely close your terminal.
- **Proxy Support:** Built-in prompt to route your downloads/uploads through a custom HTTP/HTTPS proxy (great for restricted networks).
- **Auto-Resume & Smart Stop:** Uses `yt-dlp` and `rclone` features to keep partial files. If you stop a process, it can resume exactly where it left off next time.

## 🛠️ Prerequisites

Ensure your system has the following installed before using these scripts:
- `tmux` (Handles background sessions)
- `wget` & `yt-dlp` (For media and direct file downloads)
- `rclone` (Configured with your cloud storage for uploads)

**On Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install tmux wget rclone
# For yt-dlp, it is recommended to install the latest version:
sudo wget -qO /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```

## 📥 Installation

Clone the repository and move the scripts to your local binaries directory for system-wide access:

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/unix-terminal-bg-downloader-uploader.git
cd unix-terminal-bg-downloader-uploader

# 2. Make the scripts executable
chmod +x download upload

# 3. Move them to your local bin directory (requires sudo)
sudo mv download upload /usr/local/bin/
```
*(Note: Remember to replace `YOUR_USERNAME` with your actual GitHub username).*

## 📖 How to Use

### Downloading Files
Run the download command anywhere in your terminal. It will prompt you for links and custom names. Press `Enter` with an empty input to finish queuing and start the process.
```bash
download
```
- **Check Progress:** Run `download status`
- **Cancel Queue:** Run `download stop`

### Uploading Files
Run the upload command. It will automatically detect your configured `rclone` cloud accounts.
```bash
upload
```
*(Alternatively, skip the prompt by typing the remote name directly: `upload gdrive`)*
- **Check Progress:** Run `upload status`
- **Cancel Queue:** Run `upload stop`

---

## ⚠️ CRITICAL: How to Safely Exit the Status Screen

When you run `download status` or `upload status`, you are directly attaching to the live background process. 

⛔ **DO NOT PRESS `Ctrl + C`!** 
Pressing `Ctrl + C` will immediately kill the active download or upload. 

✅ **HOW TO DETACH SAFELY:**
To close the view and let the process continue running in the background, you must detach from the tmux window:
1. Press **`Ctrl + B`** together and release them.
2. Then, press **`D`** (for Detach).

You will return to your normal terminal prompt, and your transfer will safely continue in the background!

---

## 🤝 Contributing

This project is open-source, and I highly encourage contributions! If you are a developer and know how to make these scripts better (e.g., adding a progress bar, supporting more tools, fixing bugs, or improving the bash logic), your help is very welcome.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📬 Contact & Support

If you have any questions, suggestions, or face any issues, feel free to reach out to me:
**Email:** mohammadamin.andy@gmail.com

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
