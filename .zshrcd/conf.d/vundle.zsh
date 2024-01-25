## check if vundle is checked out in ~/.vim/bundle/Vundle.vim, and if not, check it out with git
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
  mkdir -p ~/.vim/bundle && \
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
