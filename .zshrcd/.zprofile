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



# Ensure path arrays do not contain duplicates
typeset -gU cdpath fpath mailpath path

# Base path - common to all systems
path=(
  ~/bin
  /usr/local/{bin,sbin}
  $path
)

# Load OS-specific profile settings if available
[[ -f ~/.zshrcd/.zprofile.local ]] && source ~/.zshrcd/.zprofile.local
