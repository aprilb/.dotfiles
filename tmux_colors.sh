#!/bin/bash

# setup tmux colors
case $SOLARIZED in

    dark)
        tmux set -g window-status-current-attr dim
        tmux set -g window-status-current-bg black      # base02
        tmux set -g window-status-current-fg yellow     # yellow

        tmux set -g status-attr bold
        tmux set -g status-bg black                     # base02
        tmux set -g status-fg green                     # base01
        ;;

    light)
        tmux set -g window-status-current-attr dim
        tmux set -g window-status-current-bg white      # base2
        tmux set -g window-status-current-fg yellow     # yellow

        tmux set -g status-attr bold
        tmux set -g status-bg white                     # base2
        tmux set -g status-fg cyan                      # base1
        ;;

    *)
        tmux set -g status-bg blue
        tmux set -g status-fg white
        tmux set -g status-right-fg yellow
        tmux set -g window-status-current-bg cyan
        tmux set -g window-status-current-fg black
        ;;

esac
