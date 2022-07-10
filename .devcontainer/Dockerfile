FROM mcr.microsoft.com/dotnet/runtime:6.0-bullseye-slim
ARG TARGETARCH
ARG PWSH_VERSION=7.2.5

#https://github.com/PowerShell/PowerShell/releases/download/v7.2.5/powershell-7.2.5-linux-arm64.tar.gz

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && chsh "${USERNAME}" -s "$(which pwsh)" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Download the powershell '.tar.gz' archive
#x64
ARG PWSH_ARCH=arm64
RUN if ["${TARGETARCH}" = "amd64"]; then { \
      curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-x64.tar.gz; \
    } else { \
      curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell-${PWSH_VERSION}-linux-arm64.tar.gz; \
    } \
    fi \
 && sudo mkdir -p /opt/microsoft/powershell/7 \
 && sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
 && sudo chmod +x /opt/microsoft/powershell/7/pwsh \
 && sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

RUN pwsh -Command Install-Module -Name Pester -Force -Scope AllUsers \
  && pwsh -Command Install-Module -Name PSScriptAnalyzer -Force -Scope AllUsers
