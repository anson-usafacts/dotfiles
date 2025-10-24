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

# Install git, fish, and CLI tools
info "Installing git, fish, and CLI tools..."

if command -v apt-get >/dev/null 2>&1; then
    # Ubuntu/Debian
    substep_info "Detected Debian/Ubuntu package manager"
    sudo apt-get update -qq
    
    # Install basic tools first
    substep_info "Installing basic tools..."
    sudo apt-get install -y -qq git fish curl wget make tree build-essential || error "Failed to install basic tools"
    
    # Install additional tools that are available via apt
    substep_info "Installing additional CLI tools..."
    sudo apt-get install -y -qq postgresql-client 2>/dev/null || substep_info "PostgreSQL client not available"
    
    # Install GitHub CLI
    if ! command -v gh >/dev/null 2>&1; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install -y -qq gh || substep_info "GitHub CLI installation failed"
    fi
    
    # Install kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 2>/dev/null || true
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install -y -qq kubectl 2>/dev/null || substep_info "kubectl installation failed"
    fi
    
    # Install helm
    if ! command -v helm >/dev/null 2>&1; then
        curl -fsSL https://baltocdn.com/helm/signing.asc | sudo apt-key add - 2>/dev/null || true
        echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install -y -qq helm 2>/dev/null || substep_info "helm installation failed"
    fi
    
    # Install bat (sometimes called batcat)
    sudo apt-get install -y -qq bat 2>/dev/null || substep_info "bat not available"
    
    # Install Node.js
    if ! command -v node >/dev/null 2>&1; then
        substep_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - 2>/dev/null
        sudo apt-get install -y -qq nodejs || substep_info "Node.js installation failed"
    fi
    
    # Install Python tools
    substep_info "Installing Python tools..."
    sudo apt-get install -y -qq python3-pip python3-venv 2>/dev/null || substep_info "Python tools already installed"
    
    # Install Azure CLI
    if ! command -v az >/dev/null 2>&1; then
        substep_info "Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 2>/dev/null || substep_info "Azure CLI installation failed"
    fi
    
    # Install Poetry
    if ! command -v poetry >/dev/null 2>&1; then
        substep_info "Installing Poetry..."
        curl -sSL https://install.python-poetry.org | python3 - 2>/dev/null || substep_info "Poetry installation failed"
    fi
    
    # Install uv
    if ! command -v uv >/dev/null 2>&1; then
        substep_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null || substep_info "uv installation failed"
    fi
    
    # Install pyenv
    if [ ! -d "$HOME/.pyenv" ]; then
        substep_info "Installing pyenv..."
        curl -fsSL https://pyenv.run | bash 2>/dev/null || substep_info "pyenv installation failed"
    fi

elif command -v brew >/dev/null 2>&1; then
    # macOS - install all CLI tools from Brewfile
    substep_info "Detected Homebrew package manager"
    brew install git fish act astro azure-cli bat databricks gh glow helm kind kubectl make nvm poetry postgresql pyenv pyenv-virtualenv tree uv wget 2>/dev/null || substep_info "Some brew packages failed to install"

else
    error "No supported package manager found (apt-get or brew)"
    error "Please install git and fish manually, then re-run this script"
    exit 1
fi

success "Git, fish, and CLI tools installed successfully."

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

success "Fish configuration completed."

# Setup additional CLI tools
info "Setting up additional CLI tools..."

# Setup NVM (Node Version Manager)
if ! command -v nvm >/dev/null 2>&1 && [ ! -d "$HOME/.nvm" ]; then
    substep_info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash 2>/dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    substep_success "Installed NVM"
fi

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
            echo 'pyenv init - | source'
        } >> ~/.config/fish/config.fish
        substep_success "Configured pyenv in fish config"
    fi
fi

# Setup Poetry - add to PATH if needed
if command -v poetry >/dev/null 2>&1 || [ -f "$HOME/.local/bin/poetry" ]; then
    if [ -f ~/.bashrc ] && ! grep -q '.local/bin' ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        substep_success "Added ~/.local/bin to PATH in ~/.bashrc"
    fi
fi

# Setup uv - add to PATH if needed
if [ -f "$HOME/.cargo/bin/uv" ]; then
    if [ -f ~/.bashrc ] && ! grep -q '.cargo/bin' ~/.bashrc; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
        substep_success "Added ~/.cargo/bin to PATH in ~/.bashrc"
    fi
fi

# Verify installed tools
TOOLS_FOUND=0
TOOLS_TOTAL=0

check_tool() {
    TOOLS_TOTAL=$((TOOLS_TOTAL + 1))
    if command -v "$1" >/dev/null 2>&1; then
        TOOLS_FOUND=$((TOOLS_FOUND + 1))
        substep_success "$1 is available"
        return 0
    else
        return 1
    fi
}

check_tool "git"
check_tool "fish"
check_tool "bat" || check_tool "batcat"
check_tool "gh"
check_tool "kubectl"
check_tool "helm"
check_tool "az"
check_tool "poetry" || [ -f "$HOME/.local/bin/poetry" ]
check_tool "pyenv" || [ -d "$HOME/.pyenv" ]
check_tool "uv" || [ -f "$HOME/.cargo/bin/uv" ]

success "Additional CLI tools setup completed ($TOOLS_FOUND/$TOOLS_TOTAL tools available)."

# Final message
echo ""
success "Installation completed successfully!"
info "You can now use 'fish' to start the fish shell"
info "Git is configured with your settings"
info "Available tools: git, fish, bat, gh, kubectl, helm, az, poetry, pyenv, nvm, uv, and more"
info ""
info "To use fish as your shell, run: exec fish"
info "To reload shell configuration, run: source ~/.bashrc (or restart your terminal)"
