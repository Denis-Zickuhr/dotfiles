git config --global alias.rebirth '!f(){ 
    head_branch=$(git rev-parse --abbrev-ref HEAD); 
    stashSaved=false; 
    
   if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: git rebirth [--safe | -s]"
        echo "  --safe, -s  : Stash changes before resetting the branch (safe mode)"
        echo "Example: git rebirth --safe"
        echo "  This command will stash your changes and reset the branch to the state of the remote origin."
        exit 0
    fi
    
    if [ "$1" = "--safe" ] || [ "$1" = "-s" ]; then
        if ! git diff --quiet || ! git diff --staged --quiet; then
            git stash push -m "Auto stash before reset";
            stashSaved=true;
        fi
    fi

    git fetch origin && git reset --hard origin/$head_branch;
    
    # If stash was saved, pop or apply the stash
    if $stashSaved; then
        git stash pop || git stash apply;
    fi

    echo "Branch reset to origin/$head_branch";
}; f'
