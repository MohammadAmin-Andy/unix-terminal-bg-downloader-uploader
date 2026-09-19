#!/bin/bash
if [ "$1" == "status" ]; then
    tmux attach-session -t DOWN 2>/dev/null || echo "❌ No download is currently running."
    exit 0
elif [ "$1" == "stop" ]; then
    tmux kill-session -t DOWN 2>/dev/null
    echo "🛑 Download stopped! (Partial files kept for future resume)"
    exit 0
fi

echo -e "\n📥 --- Download Manager ---"

LINKS=()
NAMES=()

read -p "🔗 Link 1 (Required): " LINK1
if [ -z "$LINK1" ]; then echo "❌ Error: Link 1 is required."; exit 1; fi
read -p "📝 Name 1 [Default: Original Name]: " NAME1
LINKS+=("$LINK1")
NAMES+=("$NAME1")

COUNTER=2
while true; do
    read -p "🔗 Link $COUNTER (Optional - Press Enter to start): " NEXT_LINK
    if [ -z "$NEXT_LINK" ]; then break; fi
    read -p "📝 Name $COUNTER [Default: Original Name]: " NEXT_NAME
    LINKS+=("$NEXT_LINK")
    NAMES+=("$NEXT_NAME")
    ((COUNTER++))
done

read -p "📂 Save Directory [Default: ./downloads/]: " DIR
DIR=${DIR:-./downloads/}
mkdir -p "$DIR"

read -p "🌐 Use Proxy? (y/n) [Default: n]: " USE_PROXY
USE_PROXY=${USE_PROXY:-n}

YTDLP_PROXY=""
WGET_PROXY=""
if [[ "$USE_PROXY" =~ ^[Yy]$ ]]; then
    read -p "🔌 Enter Proxy URL (e.g., http://127.0.0.1:10809): " PROXY_URL
    if [ -n "$PROXY_URL" ]; then
        YTDLP_PROXY="--proxy '$PROXY_URL'"
        WGET_PROXY="-e use_proxy=yes -e http_proxy=$PROXY_URL -e https_proxy=$PROXY_URL"
    fi
fi

CMD=""
for i in "${!LINKS[@]}"; do
    URL="${LINKS[$i]}"
    NAME="${NAMES[$i]}"
    
    CMD+="echo -e '\n▶️ Downloading: $URL\n'; "
    if [ -z "$NAME" ]; then
        CMD+="yt-dlp $YTDLP_PROXY -P '$DIR' '$URL' || wget $WGET_PROXY -c -P '$DIR' '$URL'; "
    else
        CMD+="yt-dlp $YTDLP_PROXY -P '$DIR' -o '$NAME.%(ext)s' '$URL' || wget $WGET_PROXY -c -O '$DIR/$NAME' '$URL'; "
    fi
done

tmux new-session -d -s DOWN "$CMD echo -e '\n✅ All downloads completed!'; read -n 1 -s -r -p 'Press any key to exit...'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "🚀 Download queue started in background!"
    echo -e "👀 Type 'download status' to monitor, or 'download stop' to cancel."
else
    echo -e "⚠️ A download is already running! Check it with: download status"
fi