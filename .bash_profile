# .bashrc読み込み
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# 補完設定
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# プロンプト設定
if [ "$color_prompt" = yes ]; then
    PS1='\[\e[1;32m\]\W \t \[\e[1;31m\]\u \[\e[1;32m\]\$ \[\e[0m\]'
else
    PS1='\W \t \u $ '
fi

# 補完候補を自動で表示
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'