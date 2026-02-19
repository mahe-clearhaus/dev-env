alias ll='ls -la'
export GPG_TTY=$(tty)

# qlty
export QLTY_INSTALL="$HOME/.qlty"
export PATH="$QLTY_INSTALL/bin:$PATH"
export AWS=~/src/dev-env/.aws-env


# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

#AWS
export ECR_ENDPOINT=815915209444.dkr.ecr.eu-west-1.amazonaws.com


# docker
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dcr='docker compose run --rm'
alias dcb='docker compose build'
alias dcl='docker compose logs -f'
alias dce='docker compose exec'
alias dcp='docker compose ps'
alias dcdu='docker compose down && docker compose up -d'
alias dcdue='docker compose down && docker compose up -d && docker compose exec'
alias dcue='docker compose up -d && docker compose exec'


# misc
export AWS=~/src/dev-env/source_aws/.aws-env
alias srcenv='echo "use source \$AWS / cat \$AWS / ..."'
alias pushnew='git branch --show-current | xargs git push -u origin'
alias tf=terraform
alias dockerlogin='aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 815915209444.dkr.ecr.eu-west-1.amazonaws.com'

export PATH="$HOME/.local/bin:$PATH"
export PATH="/Users/martin.henriksen/src/dev-env/scripts:$PATH" # Could put this in local/bin
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
# /opt/homebrew/bin must come before /bin in PATH so that `bash` will use /opt/homebrew/bin/bash instead of /bin/bash
export PATH="/opt/homebrew/bin:$PATH"

#python
alias python=python3
alias pip=pip3

#hydra
export HYDRA=~/src/hydra
alias lntsv='ls -1 | xargs -I {} ln {} {}.tsv'
alias int='TEST_SUITE=integration make test -f ~/src/hydra/Makefile'
alias all='make test -f ~/src/hydra/Makefile'
