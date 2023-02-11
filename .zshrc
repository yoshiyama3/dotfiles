# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export TMUX_TMPDIR=$HOME/.tmux/tmp
# no server running on /private/tmp/tmux-503/default
# [exited]
# no sessions
# tmux new → exited となる場合
# brew install reattach-to-user-namespace

if [[ ! -n $TMUX ]]; then
  # get the IDs
  ID="`tmux list-sessions`"
  if [[ -z "$ID" ]]; then
    tmux new-session
  fi
  ID="`echo $ID | $PERCOL | cut -d: -f1`"
  tmux attach-session -t "$ID"
fi

#----------------------------------- zinit config -----------------------------------
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light chrissicool/zsh-256color
zinit light romkatv/powerlevel10k

#----------------------------------- General config -----------------------------------

export LANG=ja_JP.UTF-8
# 自動保管
autoload -U compinit; compinit
# コマンドミスを修正
setopt correct
# 大文字小文字区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "$HOME/.zsh/.cache/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true

# cd した先のディレクトリをディレクトリスタックに追加する
# ディレクトリスタックとは今までに行ったディレクトリの履歴のこと
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd
DIRSTACKSIZE=100
# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# History
# 入力したコマンドがすでにコマンド履歴に含まれる場合、履歴から古いほうのコマンドを削除する
# コマンド履歴とは今まで入力したコマンドの一覧のことで、上下キーでたどれる
HISTFILE=${HOME}/.zsh/.zhistory
setopt hist_ignore_all_dups
setopt share_history
setopt hist_no_store
setopt extended_history
HISTSIZE=1000
SAVEHIST=100000

export PATH="$HOME/.rd/bin:$PATH"

# Prompt を画面下へ固定
tput cup $LINES
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 50%  --border --inline-info'

# ----------------------------------- Functions -----------------------------------
function fzf-cdr() {
  target_dir=`cdr -l | sed 's/^[^ ][^ ]*  *//' | fzf`
  target_dir=`echo ${target_dir/\~/$HOME}`
  if [ -n "$target_dir" ]; then
    cd $target_dir
    tput cup $LINES
    zle reset-prompt
  fi
}
zle -N fzf-cdr

function  fzf-file-list() {
  fzf
  tput cup $LINES
  zle reset-prompt
}
zle -N fzf-file-list

# ctrl-l で画面を再描画した時の設定
function myclear() {
  clear
  tput cup $LINES
  zle reset-prompt
}
zle -N myclear

# ----------------------------------- Key Binding -----------------------------------
# viライクなキーバインディング
bindkey -v
# https://mollifier.hatenablog.com/entry/20081213/1229148947
# ctrl-a と ctrl-e, ctrl-k の挙動だけ戻す
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
# C-hでcd履歴検索後移動
# bindkey '^H' anyframe-widget-cdr
bindkey '^H' fzf-cdr
# C-rでコマンド履歴検索後実行
# bindkey '^R'
# C-fでファイル名検索，挿入
bindkey '^F' fzf-file-list
# C-l 時の挙動
bindkey '^L' myclear

#----------------------------------- Alias -----------------------------------
alias dirs='dirs -v'
alias history='history -i'
alias mv='mv -i'
alias rm='rm -i'
alias exa='exa --long --icons --git --git-ignore -F --group-directories-first --time-style=long-iso -I ".git"'
alias ls='exa'

# clear で画面を再描画した時の設定
alias clear="clear;tput cup $LINES"

# 個別の Alias 設定

if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
fi

case ${OSTYPE} in
    darwin*)
      alias xargs='gxargs'
      alias sed='gsed'
      alias awk='gawk'
      alias cpjson='pbpaste | jq | pbcopy'
      ;;
esac

#----------------------------------- Compile zshrc at end -----------------------------------
if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
