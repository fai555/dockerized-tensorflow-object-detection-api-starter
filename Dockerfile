FROM ubuntu:16.04
USER root
LABEL maintainer="Soila Kavulya <soila.p.kavulya@intel.com>"

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        python-pil \
        python-tk \
        python-lxml \
        rsync \
        git \
        software-properties-common \
        unzip \
        wget \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:jonathonf/python-3.6
RUN apt-get update

RUN apt-get install -y build-essential python3.6 python3.6-dev python3-pip python3.6-venv
RUN python3.6 -m pip install pip --upgrade

RUN pip --no-cache-dir install \
        tensorflow==1.13.2

RUN pip --no-cache-dir install \
        Cython \
        contextlib2 \
        jupyter \
        matplotlib \
        pillow \
        lxml

# Setup Universal Object Detection
ENV MODELS_HOME "/models"


# RUN git clone https://github.com/tensorflow/models.git $MODELS_HOME
COPY ./models /models


RUN cd $MODELS_HOME/research && \
    wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip && \
    unzip protobuf.zip && \
    ./bin/protoc object_detection/protos/*.proto --python_out=.


WORKDIR $MODELS_HOME/research/
RUN export PYTHONPATH="$MODELS_HOME/research:$MODELS_HOME/research/slim:$PYTHONPATH"
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888
CMD ["jupyter", "notebook", "--allow-root", "--notebook-dir=/models/research/object_detection", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
