# Personal identity for Herdr session "mbh" (NartimHenriksen).
# Herdr has no session-wide env in config.toml; this covers every fish pane
# because [terminal] default_shell is fish. Agents started from those shells inherit it.
#
# Complements path-based git includeIf (~/.gitconfig-mbh for repos under ~/mbh):
# session env covers author + gh for this session even outside that path; includeIf
# covers author + HTTPS credentials under ~/mbh even outside Herdr.
# With global `gh auth git-credential`, GH_CONFIG_DIR makes `git clone` use personal.
set -l mbh_name 'Martin Henriksen'
set -l mbh_email 'NartimHenriksen@users.noreply.github.com'
set -l mbh_gh_dir $HOME/.config/gh-mbh

if set -q HERDR_ENV; and set -q HERDR_SOCKET_PATH
    if string match -q '*/sessions/mbh/*' -- $HERDR_SOCKET_PATH
        set -gx GH_CONFIG_DIR $mbh_gh_dir
        set -gx GIT_AUTHOR_NAME $mbh_name
        set -gx GIT_AUTHOR_EMAIL $mbh_email
        set -gx GIT_COMMITTER_NAME $mbh_name
        set -gx GIT_COMMITTER_EMAIL $mbh_email
    else
        # Don't leak personal identity into other Herdr sessions if env was inherited.
        if set -q GH_CONFIG_DIR; and test "$GH_CONFIG_DIR" = "$mbh_gh_dir"
            set -e GH_CONFIG_DIR
        end
        if set -q GIT_AUTHOR_EMAIL; and test "$GIT_AUTHOR_EMAIL" = "$mbh_email"
            set -e GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
        end
    end
end
