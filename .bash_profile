if [ -z "$HOST" ]; then
    export HOST=$(hostname)
fi

if [ -z "$USER" ]; then
    export USER=$(whoami)
fi

OS=$(uname -s)

#####################
#  ssh-agent stuff  #
#####################
# get the ssh agent started
SSH_ENV="$HOME/.ssh/environment-$HOST"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -n "$SSH_AUTH_SOCK" ]; then
    [ -L $SSH_AUTH_SOCK ] || ln -sf "$SSH_AUTH_SOCK" /tmp/ssh-agent-$USER-screen
elif [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_agent;
    }
else
    start_agent;
fi

# Do os specific path settings
if [ "${OS}" == "Darwin" ]; then
    export PATH=/usr/local/bin:${PATH}
fi

# Auto create tmux session, or attach to detached sessions.
# Attached sessions are left alone on purpose - detach/attach to them manually as needed.
if [[ $TMUX == "" ]]; then
    if [[ $(tmux ls | grep -v "(attached)" | wc -l) -ne 0 ]]; then
        #echo "There is an unattached session I'd be trying to attach to"
        tmux attach-session -t $(tmux ls | grep -v "(attached)" | head -n 1 | awk '{print $1}')
    else
        #echo "No sessions available.  Would be creating new session."
        tmux
    fi
fi

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi
