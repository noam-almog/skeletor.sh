#!/bin/bash
# ------------------------------------------------------------------
# [Noam Almog] skeletor.sh
#              Automation of generating a new wix project
# ------------------------------------------------------------------
{ # this ensures the entire script is downloaded #
NODE_VERSION=6.11.0
WIX_NPM_REPO="https://repo.dev.wixpress.com/artifactory/api/npm/npm-repos"

function print_welcome_message() {
    echo "       ...               ..                       ..                 s"
    echo "   .x888888hx    : < .z@8\"\`                 x .d88\"                 :8"
    echo "  d88888888888hxx   !@88E                    5888R                 .88           u.      .u    ."
    echo " 8\" ... \`\"*8888%\`   '888E   u         .u     '888R        .u      :888ooo  ...ue888b   .d88B :@8c"
    echo "!  \"   \` .xnxx.      888E u@8NL    ud8888.    888R     ud8888.  -*8888888  888R Y888r =\"8888f8888r"
    echo "X X   .H8888888%:    888E\`\"88*\"  :888'8888.   888R   :888'8888.   8888     888R I888>   4888>'88\""
    echo "X 'hn8888888*\"   >   888E .dN.   d888 '88%\"   888R   d888 '88%\"   8888     888R I888>   4888> '"
    echo "X: \`*88888%\`     !   888E~8888   8888.+\"      888R   8888.+\"      8888     888R I888>   4888>"
    echo "'8h.. \`\`     ..x8>   888E '888&  8888L        888R   8888L       .8888Lu= u8888cJ888   .d888L .+"
    echo " \`88888888888888f    888E  9888. '8888c. .+  .888B . '8888c. .+  ^%888*    \"*888*P\"    ^\"8888*\""
    echo "  '%8888888888*\"   '\"888*\" 4888\"  \"88888%    ^*888%   \"88888%      'Y\"       'Y\"          \"Y\""
    echo "     ^\"****\"\"\`        \"\"    \"\"      \"YP'       \"%       \"YP'"
    printf "                                                                                    by \e[1;33mNoam Almog\n\e[0m"
}

# --------------------------------------------- #
# | Messages
# --------------------------------------------- #
function print_title() {
  printf "\e[1;37m $(tput bold; tput smul)$1$(tput sgr0)\n\e[0m"
}

function print_error() {
  printf "\e[0;31m  [✘] $1\n\e[0m"
}

function print_question() {
  printf "\e[0;33m  [?] $1\e[0m"
}

function print_running() {
  printf "\e[1;32m  [.] $1\e[0m"
}

function print_info() {
  printf "\e[0;33m  [!] $1\n\e[0m"
}

function print_success() {
  printf "\e[0;32m  [✓︎] $1\n\e[0m"
}

function print_result() {
    local returnCode=$1
    local cmd=$2
    [ $returnCode -eq 0 ] && print_success "$cmd" || print_error "$cmd"
    echo $returnCode
}

function print_divider() {
  printf "\n\n"
}


# --------------------------------------------- #
# | Helper utils
# --------------------------------------------- #

function cmd_exists() {
  command -v "$1" &> /dev/null
  echo "$?"
}

function execute() {
  print_running "${2}"
  eval "$1" &> /dev/null
  local retCode=$?
  echo -en '\r'
  print_result $retCode "${2:-$1}"
}

function npm_install() {
  execute "npm install --registry=$WIX_NPM_REPO -g $1" \
    "Installing $1 via npm"
}

function npm_update() {
  execute "npm update --registry=$WIX_NPM_REPO -g $1" \
    "Updating $1 via npm"
}

function generator_exists {
    local generator=$1
    local res=$(yo --generators | grep $generator | wc -l)
    echo "$res"
}

function installNvmIfNeeded {
    print_divider
    print_title "Node Environment"
    if ! [ -s "$NVM_DIR/nvm.sh" ]; then
        error_reinstall "nvm check"
    fi
    execute "source $NVM_DIR/nvm.sh" "Loading NVM scripts"
    execute "nvm install \"$NODE_VERSION\"" "Using NodeJS $NODE_VERSION"
}

function installYoIfNeeded {
    local title=false
    print_divider
    print_title "Yeoman Generator"
    npm_install "yo@2"
    if [ $(generator_exists "scala-server") -eq 0 ]; then
        npm_install "generator-scala-server"
    else
        npm_update "generator-scala-server"
    fi
}

function setupScriptEnv {
    [ -d "$HOME/bin" ] || mkdir "$HOME/bin"

    # download skeletor script and install it on local env
    execute "curl --silent -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/noam-almog/skeletor.sh/master/skeletor.sh -o $HOME/bin/skeletor.sh" "Installing Skeletor script"
    ln -sf "$HOME/bin/skeletor.sh" /usr/local/bin/skeletor
    chmod +x /usr/local/bin/skeletor

    # download git rest client script and install it on local env
    execute "curl --silent https://raw.githubusercontent.com/whiteinge/ok.sh/master/ok.sh -o $HOME/bin/ok.sh" "Installing Skeletor script dependencies"
    ln -sf "$HOME/bin/ok.sh" /usr/local/bin/ok
    chmod +x /usr/local/bin/ok
}

function installJQ {
  execute "brew install jq" \
    "Installing \`jq\` via brew"
}

function checkRoot {
    if [ "$EUID" -eq 0 ]; then
        print_error "Script cannot run with root privileges, please rerun without sudo."
        exit 1
    fi
}

print_welcome_message
print_divider

checkRoot

print_info "This script will do the following:
    1. Install & setup nvm (if needed)
    2. Install/update NodeJS and Yeoman
    3. Install or update server generators
    4. Install jq\n"


installNvmIfNeeded

installYoIfNeeded

installJQ

print_divider

setupScriptEnv

print_info "Done, run \`skeletor\` to generate your projects."
} # this ensures the entire script is downloaded #