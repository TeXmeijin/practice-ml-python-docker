# FROM gitpod/workspace-full

# Install custom tools, runtimes, etc.
# For example "bastet", a command-line tetris clone:
# RUN brew install bastet
#
# More information: https://www.gitpod.io/docs/config-docker/

# https://github.com/nielsborie/ml-docker/blob/master/Dockerfile.

FROM jupyter/tensorflow-notebook:87c5183850b8
SHELL ["/bin/bash", "-c"]

LABEL maintainer="TeXmeijin"

USER root
WORKDIR /app

# --- Install python-tk htop python-boost
RUN apt-get autoremove --purge && \
    apt-get update && \
    apt-get install -y --no-install-recommends python-tk software-properties-common htop libboost-all-dev curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Install dependency gcc/g++
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test

# --- Install gcc/g++
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc-7 g++-7 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Update alternatives
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7

# Fix certificate issues
RUN apt-get update && \
    apt-get clean && \
    update-ca-certificates -f;

ENV POETRY_HOME="/opt/poetry" \
    VENV_PATH="/opt/pysetup/.venv" \
    PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Install Poetry
RUN pip install poetry
RUN poetry init -n

# --- Install h2o
RUN $CONDA_DIR/bin/python -m pip install -f http://h2o-release.s3.amazonaws.com/h2o/latest_stable_Py.html h2o

# --- Conda xgboost, lightgbm, catboost, h2o, gensim, mlxtend
RUN conda install --quiet --yes \
    'boost' \
    'lightgbm' \
    'xgboost' \
    'catboost' \
    'gensim' \
    'mlxtend' \
    'tabulate' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# --- Install vowpalwabbit, hyperopt, tpot, sklearn-deap, yellowbrick, spacy
RUN $CONDA_DIR/bin/python -m poetry add vowpalwabbit \
    hyperopt \
    deap \
    update_checker \
    tqdm \
    stopit \
    scikit-mdr \
    skrebate \
    tpot \
    sklearn-deap \
    yellowbrick \
    spacy \
    gplearn \
    kmapper \
    skope-rules \
    shap \
    lime 

###########
#
# Add some usefull libs, inspired by kaggle's Dockerfile
# CREDITS : https://hub.docker.com/r/kaggle/python/dockerfile
#
###########
#RUN $CONDA_DIR/bin/python -m poetry add --upgrade mpld3
RUN $CONDA_DIR/bin/python -m poetry add mplleaflet \
    gpxpy \
    arrow \
    sexmachine \
    Geohash \
    haversine \
    toolz cytoolz \
    sacred \
    plotly \
    git+https://github.com/nicta/dora.git \
    git+https://github.com/hyperopt/hyperopt.git \
    # tflean. Deep learning library featuring a higher-level API for TensorFlow. http://tflearn.org
    git+https://github.com/tflearn/tflearn.git \
    fitter \
    langid \
    # Delorean. Useful for dealing with datetime
    delorean \
    trueskill \
    heamy \
    vida \
    # Useful data exploration libraries (for missing data and generating reports)
    missingno \
    pandas-profiling \
    s2sphere
###########
#
# Issue #1
# pandas.read_hdf
#
###########
RUN $CONDA_DIR/bin/python -m poetry add tables

# clean up pip cache
RUN rm -rf /root/.cache/pip/*

RUN mkdir -p /home/jovyan/.local/share/jupyter && chown -R jovyan /home/jovyan/.local