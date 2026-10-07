# commented out because I am not using .zshrc
#
# alias ll='ls -l'
# alias la='ls -lA'
#
# export GPG_TTY=$(tty)
#
# # qlty
# export QLTY_INSTALL="$HOME/.qlty"
# export PATH="$QLTY_INSTALL/bin:$PATH"
# export AWS=~/src/dev-env/.aws-env
#
#
# # rbenv
# export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"
#
# #AWS
# export ECR_ENDPOINT=815915209444.dkr.ecr.eu-west-1.amazonaws.com
#
#
# # docker
# alias dcup='docker compose up -d'
# alias dcdown='docker compose down'
# alias dcr='docker compose run --rm'
# alias dcb='docker compose build'
# alias dcl='docker compose logs -f'
# alias dce='docker compose exec'
# alias dcp='docker compose ps'
# alias dcdu='docker compose down && docker compose up -d'
# alias dcdue='docker compose down && docker compose up -d && docker compose exec'
# alias dcue='docker compose up -d && docker compose exec'
#
#
# # misc
# export AWS=~/src/dev-env/source_aws/.aws-env
# alias srcenv='echo "use source \$AWS / cat \$AWS / ..."'
# alias pushnew='git branch --show-current | xargs git push -u origin'
# alias tf=terraform
# alias dockerlogin='aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 815915209444.dkr.ecr.eu-west-1.amazonaws.com'
#
# export PATH="$HOME/.local/bin:$PATH"
# export PATH="/Users/martin.henriksen/src/dev-env/scripts:$PATH" # Could put this in local/bin
# export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
# # /opt/homebrew/bin must come before /bin in PATH so that `bash` will use /opt/homebrew/bin/bash instead of /bin/bash
# export PATH="/opt/homebrew/bin:$PATH"
#
# #python
# alias python=python3
# alias pip=pip3
#
# #hydra
# export HYDRA=~/src/hydra
# alias lntsv='ls -1 | xargs -I {} ln {} {}.tsv'
# alias int='TEST_SUITE=integration make test -f ~/src/hydra/Makefile'
# alias all='make test -f ~/src/hydra/Makefile'
# alias skip='export HYDRA_SKIP_DBMIGRATE=1'
# alias unskip='export HYDRA_SKIP_DBMIGRATE=0'
#
# alias chkjson='check-jsonschema' # basically just added this alias to remind myself that check-jsonschema exists
# #
# # mkcd() { # must be a function, not a script — a script's cd can't move the parent shell
# #     mkdir -p "$1" && cd "$1"
# # }
# #
# # minify() {
# #     echo -n "${1//-/}" | xxd -r -p | base64
# # }
# #
# # de_minify() {                               
# #     hex=$(echo -n "$1" | base64 -d | xxd -p)
# #     echo "${hex:0:8}-${hex:8:4}-${hex:12:4}-${hex:16:4}-${hex:20:12}"
# # }
# #
# # # >>> grok installer >>>
# # export PATH="$HOME/.grok/bin:$PATH"
# # fpath=(~/.grok/completions/zsh $fpath)
# # autoload -Uz compinit && compinit -C
# # # <<< grok installer <<<
# # export PATH="$HOME/.local/bin:$PATH"
