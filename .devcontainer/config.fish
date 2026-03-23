# Enable auto-cd
set -g fish_auto_cd 1

# Prompt
if status --is-interactive
    tide configure --auto
end

# Directory shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias c="clear"

# Git
alias gst="git status"
alias gaa="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# Vue / Vite
alias dev="npm run dev"
alias build="npm run build"
alias preview="npm run preview"
alias lint="npm run lint"
alias test="npm run test"

# Z (for fast navigation)
z add (pwd)
