function fish_prompt
    set -l last_status $status
    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l red (set_color -o red)
    set -l blue (set_color -o blue)
    set -l green (set_color -o green)
    set -l status_face (set_color -o 90b99f)
    set -l normal (set_color normal)

    if set -q SSH_TTY
        echo -n -s $red (whoami) $normal "@" $yellow (prompt_hostname) " " $normal
    end

    echo -n -s $blue (prompt_pwd) $normal

    set -l git_info (fish_git_prompt)
    if test -n "$git_info"
        echo -n -s $green $git_info $normal
    end

    if test -n "$CMD_DURATION"
        if test $CMD_DURATION -gt 5000
            set -l duration (math -s1 $CMD_DURATION / 1000)
            echo -n -s $yellow " (" $duration "s)" $normal
        end
    end

    echo
    if test $last_status -ne 0
        echo -n -s $red ":(" $normal " "
    else
        echo -n -s $status_face ":)" $normal " "
    end
end
