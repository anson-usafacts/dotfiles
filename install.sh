#!/usr/bin/env bash

# Install script for git, fish, and CLI tools in devpod containers
# This script installs essential development tools and configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
info() {
    printf "${BLUE}========> %s${NC}\n" "$1"
}

success() {
    printf "${GREEN}========> %s${NC}\n" "$1"
}

error() {
    printf "${RED}========> %s${NC}\n" "$1"
}

substep_info() {
    printf "${YELLOW}==== %s${NC}\n" "$1"
}

substep_success() {
    printf "${GREEN}==== %s${NC}\n" "$1"
}

substep_error() {
    printf "${RED}==== %s${NC}\n" "$1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

info "Starting git, fish, and CLI tools installation for devpod..."

# Check and install Homebrew if not present
info "Checking for Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
    substep_info "Homebrew not found, installing..."
    
    # Install prerequisites for Homebrew on Linux
    if command -v apt-get >/dev/null 2>&1; then
        substep_info "Installing Homebrew prerequisites (Debian/Ubuntu)..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq build-essential procps curl file git 2>/dev/null || substep_error "Failed to install prerequisites"
    fi
    
    # Install Homebrew
    substep_info "Installing Homebrew (this may take a few minutes)..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        error "Failed to install Homebrew"
        exit 1
    }
    
    # Add Homebrew to PATH for current session
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        substep_success "Homebrew installed at /home/linuxbrew/.linuxbrew"
    elif [ -d "$HOME/.linuxbrew" ]; then
        eval "$($HOME/.linuxbrew/bin/brew shellenv)"
        substep_success "Homebrew installed at $HOME/.linuxbrew"
    elif [ -d "/opt/homebrew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        substep_success "Homebrew installed at /opt/homebrew"
    elif [ -d "/usr/local/Homebrew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
        substep_success "Homebrew installed at /usr/local"
    fi
    
    # Add Homebrew to shell configuration
    if [ -d "/home/linuxbrew/.linuxbrew" ] || [ -d "$HOME/.linuxbrew" ]; then
        BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
        if [ -f ~/.bashrc ] && ! grep -q "linuxbrew" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Homebrew" >> ~/.bashrc
            echo "$BREW_SHELLENV" >> ~/.bashrc
            substep_success "Added Homebrew to ~/.bashrc"
        fi
        if [ -f ~/.profile ] && ! grep -q "linuxbrew" ~/.profile; then
            echo "" >> ~/.profile
            echo "# Homebrew" >> ~/.profile
            echo "$BREW_SHELLENV" >> ~/.profile
            substep_success "Added Homebrew to ~/.profile"
        fi
    fi
    
    success "Homebrew installed successfully"
else
    substep_success "Homebrew is already installed"
fi

# Verify brew is accessible
if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew installation failed or is not in PATH"
    exit 1
fi

# Update Homebrew
info "Updating Homebrew..."
brew update || substep_info "Homebrew update had some issues (continuing anyway)"

# Install CLI tools from Brewfile using Homebrew
info "Installing CLI tools via Homebrew..."
substep_info "This may take several minutes on first install..."

# Install tools one by one for better error handling
TOOLS=(
    "git"
    "fish" 
    "wget"
    "make"
    "tree"
    "bat"
    "gh"
    "kubectl"
    "helm"
    "azure-cli"
    "poetry"
    "pyenv"
    "pyenv-virtualenv"
    "nvm"
    "uv"
    "postgresql@14"
    "act"
    "astro"
    "glow"
    "kind"
    "databricks"
)

INSTALLED_COUNT=0
FAILED_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if brew list "$tool" &>/dev/null; then
        substep_success "$tool already installed"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        substep_info "Installing $tool..."
        if brew install "$tool" 2>/dev/null; then
            substep_success "$tool installed"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        else
            substep_error "$tool installation failed"
            FAILED_TOOLS+=("$tool")
        fi
    fi
done

if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    substep_info "Failed to install: ${FAILED_TOOLS[*]}"
fi

success "Homebrew installation completed ($INSTALLED_COUNT/${#TOOLS[@]} tools installed)"

# Setup git configuration
info "Setting up git configuration..."

if [ -f "git/.gitconfig" ]; then
    cp git/.gitconfig ~/.gitconfig
    substep_success "Copied .gitconfig"
else
    substep_info "No .gitconfig found, skipping..."
fi

if [ -f "git/.gitignore_global" ]; then
    cp git/.gitignore_global ~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global
    substep_success "Copied .gitignore_global and updated git config"
else
    substep_info "No .gitignore_global found, skipping..."
fi

success "Git configuration completed."

# Setup fish configuration
info "Setting up fish shell..."

# Create fish config directory
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/fish/completions

# Copy fish configuration files
if [ -f "fish/config.fish" ]; then
    cp fish/config.fish ~/.config/fish/config.fish
    substep_success "Copied fish config.fish"
else
    substep_info "No fish config.fish found, skipping..."
fi

# Copy fish functions
if [ -d "fish/functions" ] && [ -n "$(ls -A fish/functions/*.fish 2>/dev/null)" ]; then
    cp fish/functions/*.fish ~/.config/fish/functions/ 2>/dev/null
    substep_success "Copied fish functions"
else
    substep_info "No fish functions found, skipping..."
fi

# Copy fish completions
if [ -d "fish/completions" ] && [ -n "$(ls -A fish/completions/*.fish 2>/dev/null)" ]; then
    cp fish/completions/*.fish ~/.config/fish/completions/ 2>/dev/null
    substep_success "Copied fish completions"
else
    substep_info "No fish completions found, skipping..."
fi

# Copy fishfile if it exists
if [ -f "fish/fishfile" ]; then
    cp fish/fishfile ~/.config/fish/fishfile
    substep_success "Copied fishfile"
fi

# Add Homebrew to fish config if on Linux
if [ -d "/home/linuxbrew/.linuxbrew" ] || [ -d "$HOME/.linuxbrew" ]; then
    if [ -f ~/.config/fish/config.fish ] && ! grep -q "linuxbrew" ~/.config/fish/config.fish; then
        {
            echo ''
            echo '# Homebrew'
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
        } >> ~/.config/fish/config.fish
        substep_success "Added Homebrew to fish config"
    fi
fi

success "Fish configuration completed."

# Setup additional CLI tools
info "Setting up additional CLI tools..."

# Setup pyenv - add to shell configuration if not already present
if command -v pyenv >/dev/null 2>&1; then
    if [ -f ~/.bashrc ] && ! grep -q 'PYENV_ROOT' ~/.bashrc; then
        {
            echo ''
            echo '# Pyenv configuration'
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init -)"'
        } >> ~/.bashrc
        substep_success "Configured pyenv in ~/.bashrc"
    fi
    
    if [ -f ~/.config/fish/config.fish ] && ! grep -q 'PYENV_ROOT' ~/.config/fish/config.fish; then
        {
            echo ''
            echo '# Pyenv configuration'
            echo 'set -x PYENV_ROOT "$HOME/.pyenv"'
            echo 'set -x PATH "$PYENV_ROOT/bin" $PATH'
            echo 'status is-interactive; and pyenv init - | source'
        } >> ~/.config/fish/config.fish
        substep_success "Configured pyenv in fish config"
    fi
fi

# Verify installed tools
info "Verifying installed tools..."

TOOLS_FOUND=0
TOOLS_TOTAL=0

check_tool() {
    TOOLS_TOTAL=$((TOOLS_TOTAL + 1))
    if command -v "$1" >/dev/null 2>&1; then
        TOOLS_FOUND=$((TOOLS_FOUND + 1))
        substep_success "$1 is available"
        return 0
    else
        substep_info "$1 not found in PATH"
        return 1
    fi
}

check_tool "git"
check_tool "fish"
check_tool "bat"
check_tool "gh"
check_tool "kubectl"
check_tool "helm"
check_tool "az"
check_tool "poetry"
check_tool "pyenv"
check_tool "uv"
check_tool "tree"
check_tool "wget"

success "Tool verification completed ($TOOLS_FOUND/$TOOLS_TOTAL tools available in PATH)."

# Final message
echo ""
success "Installation completed successfully!"
echo ""
info "✓ Homebrew is installed and configured"
info "✓ Git is configured with your settings"
info "✓ Fish shell is configured with your functions and completions"
info "✓ CLI tools installed: git, fish, bat, gh, kubectl, helm, az, poetry, pyenv, uv, and more"
echo ""
info "Next steps:"
info "  • Run 'exec fish' to start using fish shell"
info "  • Run 'source ~/.bashrc' to reload bash configuration (or restart terminal)"
info "  • Homebrew is available via 'brew' command"
info "  • Use 'pyenv install <version>' to install Python versions"
echo ""
