# Use the Alpine Linux base image
FROM alpine:3.19

# Create a new user named "runner" with UID 1000
RUN adduser -D -u 1000 -s /bin/bash -g "CI runner" runner

# Update packages and upgrade system and delete cache
# Install dependencies
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
    bash \
    curl \
    python3 \
    py3-pip \
    openssl \
    ca-certificates \
    openssh-client \
    git \
    ansible \
    tar \
    zstd \
    && rm -rf /var/cache/apk/*

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip \
    && unzip terraform_1.5.7_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && chmod +x /usr/local/bin/terraform \
    && rm terraform_1.5.7_linux_amd64.zip

# Install Terragrunt
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.4/terragrunt_linux_amd64 \
    && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# Install SOPS
RUN curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 \
    && mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops

# Add option to ignore host verification to ssh_config
RUN echo -e "Host *\n\tStrictHostKeyChecking no\n\n" >> /etc/ssh/ssh_config

# Change default shell to bash
RUN sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

# Switch to the "runner" user
USER runner

# Set the working directory to the home directory of the "runner" user
WORKDIR /home/runner

# Set the default command (you can change this as needed)
CMD ["/bin/bash"]