# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
# color code completion!!!!  Wohoo!
zstyle ':completion:*' list-colors "=(#b) #([0-9]#)*=36=31"
# Have the newer files last so I see them first
#zstyle ':completion:*' file-sort modification reverse
# approximate completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
# menu completion
zstyle ':completion:*' menu select=1

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line

bindkey '^v' edit-command-line
bindkey '^x^e' edit-command-line

fpath+=~/.zfunc
autoload -Uz compinit promptinit colors
compinit
promptinit
#zsh-mime-setup
colors

autoload -U select-word-style
select-word-style bash

# display vcs info in prompt
setopt promptsubst
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}%F{2}%b%F{3}|%F{1}%a%F{5}%f'
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}%F{2}%b%F{5}%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle :compinstall filename '~/.zshrc'

setopt emacs
setopt autocd correct rm_star_wait rc_expand_param
setopt extendedglob no_case_glob numeric_glob_sort
unsetopt beep

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# OS X specific settings
if [[ `uname` == 'Darwin' ]]; then
    unalias run-help
    autoload run-help
    HELPDIR=/usr/local/share/zsh/helpfiles
fi

#############################
# Completion settings
#############################

# compdef can be used after compinit is loaded.
compdef '_files -g "*.tar.gz"' tar
compdef '_files -g "*.tar.bz2"' tar
compdef '_files -g "*.tar.zst"' tar
compdef '_files -g "*.tar"' tar
compdef '_files -g "*.plt"' gnuplot

#############################
# Aliases
#############################

alias ls='ls --color=auto'
alias ll='ls --color=auto -lF'
alias la='ls --color -a'
alias ltr='ls --color -a -ltr'
alias grep='grep --color=auto'
alias rm='rm -i'
alias mv='mv -i'
#alias sr='screen -R'
#alias sls='screen -ls'
alias tls='tmux list-sessions'
alias tat='tmux -2 attach -t'
alias less='less -r'
alias man='LANG=C man'
alias vi='vim'
alias pyhttpd='python -m http.server'
alias tlmgr="tlmgr --usermode"
#alias scsh='rlwrap scsh'
#export BREAK_CHARS="\"#'(),;\|!?[]{}"
#alias sbcl="rlwrap -b \$BREAK_CHARS sbcl"
if [[ `uname` == 'Darwin' ]]; then
    alias mfind='mdfind -name'
    alias dslookup='dscacheutil -q host -a name'
fi

alias -g ..='..'
alias -g ...='../../'
alias -g G='| grep -E --color=auto'
alias -g C='| wc -l'
alias -g L='| less -r'
alias -g H='| head -n'
alias -g T='| tail -n'

#############################
# Utility function
#############################

nicemount() {
    (echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2=$4="";1') | column -t;
}

range() {
    sed -n "$1,$2 p" $3
}

tarscp() {
    tar cvz $1 | ssh $2 'tar xz'
}

sumcol() {
    awk "{ sum += \$$1 } END { print sum }" $2
}

avgcol() {
    awk "{ sum += \$$1 } END { print sum/NR }" $2
}

##############################
# Key binding
##############################

# Disable ctrl+s
stty stop ''

# Special keys
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
#key[Up]=${terminfo[kcuu1]}
#key[Down]=${terminfo[kcud1]}
#key[Left]=${terminfo[kcub1]}
#key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
#[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
#[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
#[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
#[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

function insert_sudo (){ zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "u" insert-sudo

##############################
# History related
##############################

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
# Write after each command
# setopt INC_APPEND_HISTORY
# Killer: share history between multiple shells
setopt SHARE_HISTORY
# If I type cd and then cd again, only save the last one
setopt HIST_IGNORE_DUPS
# Even if there are commands inbetween commands that are the same, still only
# save the last one
setopt HIST_IGNORE_ALL_DUPS
# Pretty    Obvious.  Right?
setopt HIST_REDUCE_BLANKS

##############################
# Update window title for screen and tmux
##############################
if [[ (-n $STY || -n $TMUX) && (-z $VIMRUNTIME) ]]; then
    function title() { print -Pn "\ek$1\e\\"}
    function precmd() { vcs_info; title "%20<..<%~%<<" }
    function preexec() { title "%20>..>$1%<<" }
    # must be enclosed in single quote, otherwise, prompt subsitute won't work
    export PS1='%{${fg[cyan]}%}%D{%H:%M} %20<..<%~%<<${vcs_info_msg_0_}%{$reset_color%}> '
else
    function precmd() { vcs_info }
    export PS1='%{${fg[cyan]}%}%D{%H:%M} %n@%m:%20<..<%~%<<${vcs_info_msg_0_}%{$reset_color%}> '
fi

if [[ -d ~/.zsh/completion ]]; then
    for f in ~/.zsh/completion; do
        source $f
    done
fi

if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
    for f in /opt/homebrew/share/zsh/site-functions; do
        source $f
    done
fi

[ -s ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ -x $HOME/.atuin/bin/atuin ]]; then
    . "$HOME/.atuin/bin/env"
    eval "$(atuin init zsh)"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "/$HOME/.bun/_bun"

if which pixi >/dev/null; then
    eval "$(pixi completion --shell zsh)"
fi

if which fnm >/dev/null; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

if which pnpm >/dev/null; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

