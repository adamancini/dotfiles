# editor
export LANG=en_US.UTF-8
export LANGUAGE="en"
export LC_ALL="en_US.UTF-8"
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export DISABLE_TELEMETRY=true
# use `< file` to quickly view the contents of any file.
[[ -z "$READNULLCMD" ]] || READNULLCMD=$PAGER



# macOS
if [[ "$OSTYPE" == darwin* ]]; then
  export XDG_DESKTOP_DIR=${XDG_DESKTOP_DIR:-$HOME/Desktop}
  export XDG_DOCUMENTS_DIR=${XDG_DOCUMENTS_DIR:-$HOME/Documents}
  export XDG_DOWNLOAD_DIR=${XDG_DOWNLOAD_DIR:-$HOME/Downloads}
  export XDG_MUSIC_DIR=${XDG_MUSIC_DIR:-$HOME/Music}
  export XDG_PICTURES_DIR=${XDG_PICTURES_DIR:-$HOME/Pictures}
  export XDG_VIDEOS_DIR=${XDG_VIDEOS_DIR:-$HOME/Videos}
  export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-$HOME/Projects}
  if [[ -d /opt/homebrew ]]; then
    export HOMEBREW_PREFIX=/opt/homebrew
  else
    export HOMEBREW_PREFIX=/usr/local
  fi
##  export BROWSER='open'
fi

# Ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

path=(
  ~/bin
  $HOMEBREW_PREFIX/{bin,sbin}
  /usr/local/{bin,sbin}
  $HOMEBREW_PREFIX/opt/curl/bin
  $HOMEBREW_PREFIX/opt/go/libexec/bin
  $HOMEBREW_PREFIX/share/npm/bin
  $path
)
