# `GFF`

> __GFF Fuzzy Finds__ is a Git wrapper with fuzzy finders and previewers.

## Install

Clone this repository and add the bin to your PATH in your shell rc file (e.g. `.zshrc`) like so:
```bash
export PATH="$PATH:path/to/gff/bin"
```
Additionally add a shorter alias like so:
```bash
alias g="gff"
```

## Use

This tool has been created to make it easier to perform common Git commands __interactively, with previews__. The goal is to minimize repetition of `git add`, `git status`, `git checkout` etc. commands.

GFF provides the following commands:
* `gff ch` - add chunks and commit
* `gff co` - checkout files
* `gff rg` - use ripgrep and fzf to find and filter text in repository
* `gff rm` - remove files from repository
* `gff st` - stage/unstage files and commit
* `gff sw` - switch/create branches

## Dependencies

GFF works only if you have the following already installed:

* [FZF](https://github.com/junegunn/fzf)
* [Bat](https://github.com/sharkdp/bat)
* [Delta](https://github.com/dandavison/delta)
* [Ripgrep](https://github.com/BurntSushi/ripgrep)

Recommended:
* A modern version of tmux. The GFF interface will use a tmux popup if tmux if available but will work just fine without it.

It has been tested and works on _modern_ versions of ZSH and BASH. There is currently no plan to support something else but contributions of any kind are welcome.