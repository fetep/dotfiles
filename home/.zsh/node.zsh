if [[ -d ~/.nvm ]]; then
    export NVM_DIR="$HOME/.nvm"
    local f
    for f in "$NVM_DIR/nvm.sh" "$NVM_DIR/bash_completion"; do
        [[ -s "$f" ]] && . "$f"
    done
fi
