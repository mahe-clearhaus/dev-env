alias ll='ls -l'
alias la='ls -lA'

set -gx GPG_TTY (tty)

# qlty
set -gx QLTY_INSTALL "$HOME/.qlty"
fish_add_path "$QLTY_INSTALL/bin"

# rbenv
# shims go on PATH for every shell (incl. `fish -c`); the init hook, which also
# runs a `rbenv rehash`, only for interactive ones
fish_add_path "$HOME/.rbenv/bin"
fish_add_path "$HOME/.rbenv/shims"
status is-interactive; and rbenv init - fish | source

# AWS
set -gx ECR_ENDPOINT 815915209444.dkr.ecr.eu-west-1.amazonaws.com

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
set -gx AWS ~/src/dev-env/source_aws/.aws-env
alias srcenv='echo "use source \$AWS / cat \$AWS / ..."'
alias pushnew='git branch --show-current | xargs git push -u origin'
alias tf=terraform
alias dockerlogin='aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 815915209444.dkr.ecr.eu-west-1.amazonaws.com'
alias chkjson='check-jsonschema' # basically just added this alias to remind myself that check-jsonschema exists

function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

## minify and de_minify are for use with CUSTOM_DATA that is both hex and base64 encoded
function minify
    echo -n (string replace -a -- - '' $argv[1]) | xxd -r -p | base64
end

function de_minify
    set -l hex (echo -n $argv[1] | base64 -d | xxd -p)
    echo (string sub -l 8 $hex)-(string sub -s 9 -l 4 $hex)-(string sub -s 13 -l 4 $hex)-(string sub -s 17 -l 4 $hex)-(string sub -s 21 -l 12 $hex)
end

# /opt/homebrew/bin must come before /bin in PATH so that `bash` will use /opt/homebrew/bin/bash instead of /bin/bash
fish_add_path /opt/homebrew/opt/openssl@3/bin
fish_add_path ~/src/dev-env/scripts # Could put this in local/bin
fish_add_path /opt/homebrew/bin
fish_add_path "$HOME/.grok/bin" # grok installer; completions live in ~/.config/fish/completions/grok.fish
fish_add_path "$HOME/.local/bin"

# python
alias python=python3
alias pip=pip3

# hydra
set -gx HYDRA ~/src/hydra
alias lntsv='ls -1 | xargs -I {} ln {} {}.tsv'
alias int='TEST_SUITE=integration make test -f ~/src/hydra/Makefile'
alias all='make test -f ~/src/hydra/Makefile'
alias skip='set -gx HYDRA_SKIP_DBMIGRATE 1'
alias unskip='set -gx HYDRA_SKIP_DBMIGRATE 0'
