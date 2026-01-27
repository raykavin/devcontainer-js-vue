# Microsoft Dev Container base image with Node.js
FROM mcr.microsoft.com/devcontainers/javascript-node:20-bookworm

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV VITE_API_BASE_URL=http://localhost:3000/api/v1
ENV VITE_HEALTH_API_URL=http://localhost:3000/health
# ENV VITE_OIDC_REDIRECT_URI=http://localhost:8080/oauth2/callback
# ENV VITE_OIDC_POST_LOGOUT_REDIRECT_URI=http://localhost:8080/oauth2/login
# ENV VITE_OIDC_SILENT_REDIRECT_URI=http://localhost:8080/oauth2/silent-renew
# ENV VITE_OIDC_AUTHORITY=https://sso.authority
# ENV VITE_OIDC_CLIENT_ID=client_id

# Use the existing 'node' user from the base image
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

# Install fish shell, essential tools and development dependencies
RUN apt-get update && apt-get install -y \
    fish \
    sudo \
    git \
    curl \
    nano \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create group if it doesn't exist
RUN if ! getent group $USERNAME >/dev/null; then \
    groupadd --gid $USER_GID $USERNAME 2>/dev/null || groupadd $USERNAME; \
    fi

# Create user if it doesn't exist
# Add user to sudo group and set fish as default shell
RUN if ! getent group $USERNAME >/dev/null; then \
    groupadd --gid $USER_GID $USERNAME 2>/dev/null || groupadd $USERNAME; \
    fi \
    && if ! id -u $USERNAME >/dev/null 2>&1; then \
    useradd --uid $USER_UID --gid $(getent group $USERNAME | cut -d: -f3) -m $USERNAME 2>/dev/null || \
    useradd --gid $(getent group $USERNAME | cut -d: -f3) -m $USERNAME; \
    fi \
    && usermod -aG sudo $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set default shell to fish
RUN chsh -s /usr/bin/fish $USERNAME

# Set working directory
WORKDIR /home/$USERNAME/workspaces/app

# Change ownership of working directory to vscode user
RUN chown -R $USERNAME:$USERNAME .

# Switch to vscode user before npm operations
USER $USERNAME

# Expose port
EXPOSE 8080

# Start command with fish shell
CMD ["fish"]
