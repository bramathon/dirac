# We start with the tensorflow image with tensorflow-gpu preinstalled and ubunut 18.04 base
FROM tensorflow/tensorflow:2.4.1-gpu

# Everything below here as ROOT
USER root

# Install the ubuntu packages
# Special install for nodejs14 and emacs 27
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && add-apt-repository -y ppa:kelleyk/emacs \
    && add-apt-repository ppa:git-core/ppa \
    && apt update \
    && apt install -y --no-install-recommends \
        bash-completion \ 
        git \
        gnuplot \
        jq \
        less \
        openssh-client \
        software-properties-common \
        nano \
        python3.8-dev \
        python-six \
        emacs27 \
        groff \
        graphviz \
        nodejs \
        xauth \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf $(which python3.8) $(which python || echo '/usr/local/bin/python') \
    && ln -sf $(which python3.8) $(which python3 || echo '/usr/local/bin/python3') \
    && python -m pip install --no-cache-dir --upgrade pip

# Create the docker user, 'zepp'
ARG USER=zepp
ARG UID=1000
ARG GID=1000
RUN addgroup --gid ${GID} ${USER} \
 && adduser \
    --disabled-password \
    --gecos ${USER} \
    --gid ${GID} \
    --uid ${UID} \
    ${USER} \
&& usermod -aG sudo ${USER}

# Create our project directory and switch to it
ARG APP_DIR=/home/${USER}/app
RUN mkdir -p ${APP_DIR} \
    && chown ${USER}:${USER} ${APP_DIR} \
    && chmod -R 777 /home/${USER}

WORKDIR ${APP_DIR}

# Install the python packages
COPY requirements.txt ./
RUN PIP_NO_CACHE_DIR=1 \
    PIP_UPGRADE=1 \
    pip install -r requirements.txt

# Allow jupyter to render plotly plots
RUN jupyter labextension install --no-build \
        jupyterlab-plotly@4.14.3 \
        plotlywidget@4.14.3 \
    && jupyter lab build

# RUN mkdir -p /home/${USER}/.jupyter/lab/user-settings/@krassowski/
COPY --chown=${USER}:${USER} plugin.jupyterlab-settings /home/${USER}/.jupyter/lab/user-settings/@krassowski/plugin.jupyterlab-settings
COPY --chown=${USER}:${USER} emacs.lisp /home/${USER}/.emacs

# Add the AWS Cli
COPY --from=amazon/aws-cli:2.1.15 /usr/local/aws-cli/v2/current /usr/local

# Append the project directory to the PYTHONPATH
ENV PYTHONPATH="home/${USER}/app/"

# Everything below here as USER
USER ${USER}

# Compile the .emacs in userland
RUN emacs --batch -l /home/${USER}/.emacs

ENV SHELL /bin/bash
