for i in ~/.zsh.d/*.zsh; do
    if [[ "$ZSHRC_DEBUG" == "1" ]]; then
        echo "Sourcing $i"
    fi
    source "$i"
done
