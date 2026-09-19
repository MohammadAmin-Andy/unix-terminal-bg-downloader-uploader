#!/bin/bash
if [ "$1" == "status" ]; then
    tmux attach-session -t UP 2>/dev/null || echo "❌ No upload is currently running."
    exit 0
elif [ "$1" == "stop" ]; then
    tmux kill-session -t UP 2>/dev/null
    echo "🛑 Upload stopped! (Incomplete files in cloud are discarded automatically)"
    exit 0
fi

echo -e "\n☁️ --- Advanced Cloud Upload Manager ---"

echo "🌐 Connected Clouds:"
rclone listremotes | sed 's/://g' | awk '{print "   - "$1}'
echo "-----------------------------------"

REMOTE=$1
if [ -z "$REMOTE" ]; then
    read -p "☁️ Select Cloud (e.g., gdrive, dropbox): " REMOTE
    if [ -z "$REMOTE" ]; then echo "❌ Error: Cloud selection is required."; exit 1; fi
fi

PATHS=()
NAMES=()

read -p "📁 Source Path 1 (Required): " PATH1
if [ -z "$PATH1" ]; then echo "❌ Error: Source path 1 is required."; exit 1; fi
read -p "📝 Cloud Folder/Name 1 [Default: Root]: " NAME1
PATHS+=("$PATH1")
NAMES+=("$NAME1")

COUNTER=2
while true; do
    read -p "📁 Source Path $COUNTER (Optional - Press Enter to start): " NEXT_PATH
    if [ -z "$NEXT_PATH" ]; then break; fi
    read -p "📝 Cloud Folder/Name $COUNTER [Default: Root]: " NEXT_NAME
    PATHS+=("$NEXT_PATH")
    NAMES+=("$NEXT_NAME")
    ((COUNTER++))
done

read -p "📂 Cloud Root Destination [Default: $REMOTE:/]: " ROOT_DEST
ROOT_DEST=${ROOT_DEST:-$REMOTE:/}

read -p "🚀 Speed Limit (e.g., 2M, 500K) [Default: Unlimited]: " BWLIMIT
BW_FLAG=""
if [ -n "$BWLIMIT" ]; then BW_FLAG="--bwlimit $BWLIMIT"; fi

read -p "🌐 Use Proxy? (y/n) [Default: n]: " USE_PROXY
USE_PROXY=${USE_PROXY:-n}
PROXY_ENV=""
if [[ "$USE_PROXY" =~ ^[Yy]$ ]]; then
    read -p "🔌 Enter Proxy URL (e.g., http://127.0.0.1:10809): " PROXY_URL
    if [ -n "$PROXY_URL" ]; then
        PROXY_ENV="HTTPS_PROXY='$PROXY_URL' HTTP_PROXY='$PROXY_URL'"
    fi
fi

CMD=""
for i in "${!PATHS[@]}"; do
    SRC="${PATHS[$i]}"
    NAME="${NAMES[$i]}"
    
    CMD+="echo -e '\n▶️ Uploading: $SRC\n'; "
    
    if [ -n "$NAME" ]; then
        FINAL_DEST="${ROOT_DEST%/}/$NAME"
    else
        FINAL_DEST="$ROOT_DEST"
    fi
    
    if [ -n "$PROXY_ENV" ]; then
        CMD+="env $PROXY_ENV rclone copy '$SRC' '$FINAL_DEST' $BW_FLAG -P --transfers 2 --retries 10; "
    else
        CMD+="rclone copy '$SRC' '$FINAL_DEST' $BW_FLAG -P --transfers 2 --retries 10; "
    fi
done

tmux new-session -d -s UP "$CMD echo -e '\n✅ All uploads completed!'; read -n 1 -s -r -p 'Press any key to exit...'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "🚀 Upload queue started to [$REMOTE] in the background!"
    echo -e "👀 Type 'upload status' to monitor, or 'upload stop' to cancel."
else
    echo -e "⚠️ An upload is already running! Check it with: upload status"
fi