#!/bin/bash
# ------------------------------------------------------------------
# [Noam Almog] skeletor.sh
#              Automation of generating a new wix project
# ------------------------------------------------------------------
NODE_VERSION=7.10.0

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
printf "                               \`             '                                                                by \e[0;33m  Noam Almog\n\e[0m"
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
  printf "\e[0;34m  [.] $1\e[0m"
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
  echo -en '\r'
  print_result $? "${2:-$1}"
}

function npm_install() {
  execute "npm install -g $1" \
    "Installing $1 via npm"
}

function generator_exists {
    local generator=$1
    local res=$(yo --generators | grep $generator | wc -l)
    echo "$res"
}

function installNvmIfNeeded {
    print_divider
    print_title "Node Environment"

    if ! [ -f "/Users/noamal/.nvm/nvm.sh" ]; then
        execute "curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash" "Install nvm (using the official installer)"
    fi
    execute 'source "/Users/noamal/.nvm/nvm.sh"' "Loading NVM scripts"
    execute 'nvm install $NODE_VERSION' "Installing Node $NODE_VERSION"
}

function installYoIfNeeded {
    local title=false
    if [ $(cmd_exists "yo") -eq 1 ]; then
        title=true
        print_divider
        print_title "Yeoman Generator"
        npm_install "yo"
    fi
    if [ $(generator_exists "scala-server") -eq 0 ]; then
        if [ "$title" = false ]; then
            print_divider
            print_title "Yeoman Generator"
        fi
        npm_install "generator-scala-server"
    fi
}

print_welcome_message
print_divider

print_info "This script will do the following:
    1. Install & setup nvm (if needed)
    2. Install/update yeoman and node
    3. Install or update server generators (if needed)\n"

installNvmIfNeeded

installYoIfNeeded

print_divider

print_title "Generate Wix Scala Server"
yo scala-server