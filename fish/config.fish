## Disable default fish greeting
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

## Starship prompt
set -x STARSHIP_CONFIG ~/.config/starship/starship.toml
if status --is-interactive
   starship init fish | source
end

if test -f ~/.config/fish/fish_aliases.fish
        source ~/.config/fish/fish_aliases.fish
end

if test -f ~/.config/fish/fish_functions.fish
        source ~/.config/fish/fish_functions.fish
end