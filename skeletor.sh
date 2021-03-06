#!/bin/bash
# ------------------------------------------------------------------
# [Noam Almog] skeletor.sh
#              Automation of generating a new wix project
# ------------------------------------------------------------------
NODE_VERSION=8.9.1
WIX_NPM_REPO="https://repo.dev.wixpress.com/artifactory/api/npm/npm-repos"

function print_welcome_message() {
echo "          .                                                      ."
echo "        .n                   .                 .                  n."
echo "  .   .dP                  dP                   9b                 9b.    ."
echo " 4    qXb         .       dX                     Xb       .        dXp     t"
echo "dX.    9Xb      .dXb    __                         __    dXb.     dXP     .Xb"
echo "9XXb._       _.dXXXXb dXXXXbo.                 .odXXXXb dXXXXb._       _.dXXP"
echo " 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP"
echo "  \`9XXXXXXXXXXXXXXXXXXXXX'~   ~\`OOO8b   d8OOO'~   ~\`XXXXXXXXXXXXXXXXXXXXXP'"
echo "    \`9XXXXXXXXXXXP' \`9XX'   DIE    \`98v8P'  HUMAN   \`XXP' \`9XXXXXXXXXXXP'"
echo "        ~~~~~~~       9X.          .db|db.          .XP       ~~~~~~~"
echo "                        )b.  .dbo.dP'\`v'\`9b.odb.  .dX(        ██████  ██ ▄█▀▓█████  ██▓    ▓█████▄▄▄█████▓ ▒█████   ██▀███"
echo "                      ,dXXXXXXXXXXXb     dXXXXXXXXXXXb.     ▒██    ▒  ██▄█▒ ▓█   ▀ ▓██▒    ▓█   ▀▓  ██▒ ▓▒▒██▒  ██▒▓██ ▒ ██▒"
echo "                     dXXXXXXXXXXXP'   .   \`9XXXXXXXXXXXb    ░ ▓██▄   ▓███▄░ ▒███   ▒██░    ▒███  ▒ ▓██░ ▒░▒██░  ██▒▓██ ░▄█ ▒"
echo "                    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb     ▒   ██▒▓██ █▄ ▒▓█  ▄ ▒██░    ▒▓█  ▄░ ▓██▓ ░ ▒██   ██░▒██▀▀█▄"
echo "                    9XXb'   \`XXXXXb.dX|Xb.dXXXXX'   \`dXXP   ▒██████▒▒▒██▒ █▄░▒████▒░██████▒░▒████▒ ▒██▒ ░ ░ ████▓▒░░██▓ ▒██▒"
echo "                     \`'      9XXXXXX(   )XXXXXXP      \`'    ▒ ▒▓▒ ▒ ░▒ ▒▒ ▓▒░░ ▒░ ░░ ▒░▓  ░░░ ▒░ ░ ▒ ░░   ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░"
echo "                              XXXX X.\`v'.X XXXX             ░ ░▒  ░ ░░ ░▒ ▒░ ░ ░  ░░ ░ ▒  ░ ░ ░  ░   ░      ░ ▒ ▒░   ░▒ ░ ▒░"
echo "                              XP^X'\`b   d'\`X^XX             ░  ░  ░  ░ ░░ ░    ░     ░ ░      ░    ░      ░ ░ ░ ▒    ░░   ░"
echo "                              X. 9  \`   '  P )X                   ░  ░  ░      ░  ░    ░  ░   ░  ░            ░ ░     ░"
echo "                              \`b  \`       '  d'"
printf "                               \`             '                                                                by \e[1;33mNoam Almog\n\e[0m"
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
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  return $1
}

function print_divider() {
  printf "\n\n"
}

function error_reinstall {
    local step=$1
    print_error "Environment is not installed as expected, please rerun install."
    print_divider
    printf "\e[0;31m  $(tput bold; tput smul)Please reinstall by executing:$(tput sgr0)\n\n"
    printf "\e[0;31m  curl -s https://raw.githubusercontent.com/noam-almog/skeletor.sh/master/install.sh | bash\n"
    printf "\n\e[0;31m  OR:\n\n"
    printf "\e[0;31m  wget -q https://raw.githubusercontent.com/noam-almog/skeletor.sh/master/install.sh | bash\n"
    printf "\n\nFailed in $step"
    exit # enable this once script is stable enough
}

# --------------------------------------------- #
# | Helper utils
# --------------------------------------------- #

function cmd_exists() {
    if ! cmd_loc="$(type -p "$1")" || [ -z "$cmd_loc" ]; then
        return 0 # command NOT found
    fi
    return 1 # command found
}

function execute() {
    local cmd=$1
    local description=$2
    print_running "${description}"
    eval $cmd &> /dev/null
    local exitCode=$?
    echo -en '\r'
    print_result $exitCode "${2:-$1}"
}

function npm_install() {
    local package=$1
    execute "npm install --registry=$WIX_NPM_REPO -g $package" \
            "Installing $package via npm"
}

function npm_update() {
    local package=$1
#    execute "npm update --registry=$WIX_NPM_REPO -g $package" \
    execute "npm install --registry=$WIX_NPM_REPO -g $1" \
            "Installing $package via npm"
}

function generator_exists {
    local generator=$1
    local res=$(yo --generators | grep $generator | wc -l)
    echo "$res"
}

function update_generator {
    if [ $(generator_exists "scala-server") -eq 0 ]; then
        npm_install "generator-scala-server"
        return
    fi
    local latestVersion=$(npm view --registry=$WIX_NPM_REPO generator-scala-server version 2>/dev/null)
    local installedVersion=$(npm ls -g --registry=$WIX_NPM_REPO --depth=0 generator-scala-server 2>/dev/null | grep scala | cut -d \@ -f 2 | awk '{$1=$1};1')

    local devVersion=($installedVersion)
    if [ "$devVersion" = "0.0.0" ]; then
        print_info "Developer environment detected."
        return
    fi

    if [ "$installedVersion" != "$latestVersion" ];
    then
        print_info "Detected a newer version of generator [$installedVersion --> $latestVersion], upgrading."
        npm_update "generator-scala-server"
        print_info "Generator is installed properly and updated to latest [$latestVersion]."
    fi
    if [ "$installedVersion" = "$latestVersion" ];
    then
        print_info "Generator is installed properly and updated to latest [$latestVersion]."
    fi
}

function update_shell_scripts {
    [ -d "$HOME/bin" ] || mkdir "$HOME/bin"
    execute "curl --silent -H 'Cache-Control: no-cache' https://raw.githubusercontent.com/noam-almog/skeletor.sh/master/skeletor.sh -o $HOME/bin/skeletor.sh" "Updating Skeletor script"
}

function installNvmIfNeeded {
    print_divider
    print_title "Node Environment"
    if [ ! -f "$HOME/.nvm/nvm.sh" ]; then
        print_error "Unable to locate nvm command"
    fi
    execute "source $HOME/.nvm/nvm.sh" "Loading NVM scripts"
    execute "nvm install \"$NODE_VERSION\"" "Using NodeJS $NODE_VERSION"
}

function installYoIfNeeded {
    cmd_exists "yo"
    if [ $? -eq 0 ]; then
        error_reinstall "yo check"
    fi
}

function checkRoot {
    if [ "$EUID" -eq 0 ]; then
        print_error "Script cannot run with root privileges, please rerun without sudo."
        exit 1
    fi
}

print_welcome_message
print_divider

print_title "Skeletor Environment"
checkRoot
update_shell_scripts

installNvmIfNeeded
installYoIfNeeded
update_generator

print_divider

print_title "Generate Wix Scala Server"
yo scala-server
