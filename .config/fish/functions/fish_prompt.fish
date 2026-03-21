function fish_prompt
    set -l last_status $status
    set -l cyan (set_color -o cyan)
    set -l yellow (set_color -o yellow)
    set -l red (set_color -o red)
    set -l blue (set_color -o blue)
    set -l green (set_color -o green)
    set -l normal (set_color normal)

    # 1. ユーザー名とホスト名 (SSH接続時のみ表示)
    if set -q SSH_TTY
        echo -n -s $red (whoami) $normal "@" $yellow (prompt_hostname) " " $normal
    end

    # 2. カレントディレクトリ (短縮表示)
    echo -n -s $blue (prompt_pwd) $normal

    # 3. Git ブランチ情報の表示
    set -l git_info (fish_git_prompt)
    if test -n "$git_info"
        echo -n -s $green $git_info $normal
    end

    # 4. 前回のコマンドの実行時間 (5秒以上かかった場合のみ表示)
    # 修正箇所: ${duration} を "$duration" に変更
    if test -n "$CMD_DURATION"
        if test $CMD_DURATION -gt 5000
            set -l duration (math -s1 $CMD_DURATION / 1000)
            echo -n -s $yellow " (" $duration "s)" $normal
        end
    end

    # 5. 改行とプロンプト記号
    echo
    if test $last_status -ne 0
        echo -n -s $red ":(" $normal " "
    else
        echo -n -s $cyan ":)" $normal " "
    end
end
