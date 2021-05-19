FROM rocker/rstudio:3.6.3

RUN cat /etc/apt/sources.list
RUN   apt-get update -y

RUN Rscript -e 'print( .libPaths() ) '

## install python

ARG BUILDDIR="/tmp/build"
ARG PYTHON_VER="3.6.8"
WORKDIR ${BUILDDIR}

RUN apt-get install wget gcc make zlib1g-dev -y -qq > /dev/null 2>&1 && \
wget --quiet https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz > /dev/null 2>&1 && \
tar zxf Python-${PYTHON_VER}.tgz && \
cd Python-${PYTHON_VER} && \
./configure  > /dev/null 2>&1 && \
make > /dev/null 2>&1 && \
make install > /dev/null 2>&1 && \
rm -rf ${BUILDDIR} 


## install debian packages

RUN apt-get install -y python3.7

RUN apt-get install -y python3-pip


RUN apt-get install -y \
     sudo gdebi-core  pandoc  pandoc-citeproc  \
     libcairo2-dev   libxt-dev  libjpeg-dev  wget \
      libssl-dev libxml2-dev psmisc dselect libmariadbclient-dev \
      libcurl4-openssl-dev git emacs libhdf5-dev python-pip \
      python-virtualenv bowtie2 salmon samtools jellyfish cmake 




RUN pip3 install numpy --upgrade
RUN pip3 install pyparsing --upgrade


## Seurat is a monster, try to build early so if it fails we know sooner.

RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("Seurat") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("GO.db") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("DO.db") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("enrichplot") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("GOSemSim") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("clusterProfiler") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("topGO") '
RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("HTSeqGenie") '

## install a bunch of other packages, see r-package-install.R

ADD r-package-install.R r-package-install.R
RUN Rscript r-package-install.R

## any stuff from github

RUN Rscript -e  'devtools::install_github("homerhanumat/shinyCustom")'

##RUN Rscript -e  'devtools::install_github("hylasD/tSpace", build = TRUE, build_opts = c("--no-resave-data", "--no-manual"), force = T)'


RUN ln -s /usr/local/bin/python3 /usr/local/bin/python
RUN ln -s /usr/local/bin/pip3 /usr/local/bin/pip


