# stage 1 - preparing the ubuntu image, downloading + installing all packages
FROM ubuntu:24.10 AS base

# to prevent apt-get install from asking questions
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    python3 \
    python3-pip \
    openbabel \
    software-properties-common \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    tk-dev \
    libffi-dev \
    python3-biopython \
    python3-rdkit \
    rdkit-data

RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
    tar xzf Python-2.7.18.tgz && \
    rm Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure --enable-optimizations && \
    make altinstall

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python2.7 get-pip.py

RUN python2.7 -m pip install numpy

RUN wget -q https://github.com/ccsb-scripps/AutoDock-Vina/releases/download/v1.2.5/vina_1.2.5_linux_x86_64 -O /opt/vina_1.2.5_linux_x86_64 && \
    chmod +x /opt/vina_1.2.5_linux_x86_64 && \
    ln -sf /opt/vina_1.2.5_linux_x86_64 /usr/local/bin/vina

RUN curl -L -o mgltools_x86_64Linux2_1.5.7p1.tar.gz https://ccsb.scripps.edu/mgltools/download/491/ && \
    tar -xzf mgltools_x86_64Linux2_1.5.7p1.tar.gz && \
    rm mgltools_x86_64Linux2_1.5.7p1.tar.gz && \
    mv mgltools_x86_64Linux2_1.5.7 /opt/mgltools_x86_64Linux2_1.5.7 && \
    tar -xzf /opt/mgltools_x86_64Linux2_1.5.7/MGLToolsPckgs.tar.gz -C /opt/mgltools_x86_64Linux2_1.5.7/ && \
    rm /opt/mgltools_x86_64Linux2_1.5.7/MGLToolsPckgs.tar.gz

# stage 2 - all packages have been downloaded
FROM base AS final

ENV PATH="/opt/mgltools_x86_64Linux2_1.5.7/MGLToolsPckgs/AutoDockTools/Utilities24/:${PATH}"
ENV PYTHONPATH="/opt/mgltools_x86_64Linux2_1.5.7/MGLToolsPckgs/:${PYTHONPATH}"

# a workaround for a bug in MGLTools
RUN sed -i 's/^        parser = MMCIFParser(filename, modelsAs=modelsAs)$/        parser = MMCIFParser(filename)/' /opt/mgltools_x86_64Linux2_1.5.7/MGLToolsPckgs/MolKit/__init__.py

WORKDIR /app

COPY run_all.sh /app/
COPY run_docking.py /app/ 

#RUN chmod +x /app/run_all.sh

ENTRYPOINT ["sh", "/app/run_all.sh"]
