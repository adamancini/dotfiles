## check if pathogen is checked out in ~/.vim/autoload, and if not, install it
if [[ ! -d ~/.vim/autoload ]]; then
  mkdir -p ~/.vim/autoload ~/.vim/bundle && \
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi
