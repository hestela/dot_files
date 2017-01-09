#!/usr/bin/env bash
set -x

mkdir -p ~/.vim/swapfiles

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  echo "Vundle insalled."
else
  pushd ~/.vim/bundle/Vundle.vim
  git fetch origin
  git reset --hard origin/master
  echo "Vundle updated."
  popd
fi

if [ -f ~/.vimrc ]; then
  echo "saving old .vimrc as .vimrc.old"
  mv ~/.vimrc ~/.vimrc.old
fi
cp $PWD/.vimrc ~/.vimrc

echo "Finished, open vim and run :PluginInstall"
