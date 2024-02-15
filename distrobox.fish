alias hx="helix"
alias ls="eza --icons"

set -gx EDITOR "helix"
set -gx XDG_CONFIG_HOME "$HOME/.cache-distrobox"

starship init fish | source
