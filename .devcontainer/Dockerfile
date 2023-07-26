ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ENV pip_packages "ansible softlayer"

# Update system and install dependencies
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        jq \
        python3-pip \
        python3-wheel \
        unzip \
        make \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# Install pip packages
RUN pip install --upgrade pip \
    && pip install $pip_packages

# Install kubectl, ibmcloud cli, helm
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && mv kubectl /usr/bin/kubectl \
    && chmod +x /usr/bin/kubectl

RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Switch to vscode user for tfswitch and starship install 
USER vscode

# Install terraform-switcher in vscode users path
RUN export BINDIR=/home/vscode/.local/bin && \
    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash

# Install starship prompt in vscode users path
RUN curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir /home/vscode/.local/bin -f

# Copy bashrc and starship config
COPY bashrc /home/vscode/.bashrc 

COPY starship.toml /home/vscode/.config/starship.toml

# Run post-start script as root
USER root

RUN chown -R vscode:vscode /home/vscode/.config/

COPY post-start.sh /usr/local/bin/post-start

RUN chmod +x /usr/local/bin/post-start
