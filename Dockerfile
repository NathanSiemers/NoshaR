FROM rocker/rstudio:4.1.1

RUN   apt-get update -y
## RUN Rscript -e 'print( .libPaths() ) '
################################################################
## install debian packages
################################################################

RUN apt-get install -y \
     sudo gdebi-core  pandoc  pandoc-citeproc  \
     libcairo2-dev   libxt-dev  libjpeg-dev  wget \
      libssl-dev libxml2-dev psmisc dselect libmariadbclient-dev \
      libcurl4-openssl-dev git libhdf5-dev python3-pip \
      python3-virtualenv bowtie2 salmon samtools jellyfish cmake \
      emacs ess elpa-ess libglpk-dev
RUN apt-get install -y rustc wget gcc make libffi-dev zlib1g-dev 
RUN apt-get install -y libgirepository1.0-dev libbz2-dev
RUN apt-get install -y libffi-dev


################################################################
## python
## install python MANUALLY and put it in /usr/local/bin
## /usr/local/bin precedes other bin dirs in path (rocker)
################################################################

ARG BUILDDIR="/tmp/build"
ARG PYTHON_VER="3.8.10"
WORKDIR ${BUILDDIR}


RUN wget --quiet https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz > /dev/null 2>&1 && \
tar zxf Python-${PYTHON_VER}.tgz && \
cd Python-${PYTHON_VER} && \
##./configure  --disable-ipv6 --with-libs='bzip' && \
./configure && \
make > /dev/null 2>&1 && \
make install > /dev/null 2>&1 && \
rm -rf ${BUILDDIR} 

## make symlinks for python in /usr/local/bin
RUN ln -s /usr/local/bin/python3 /usr/local/bin/python
RUN ln -s /usr/local/bin/pip3 /usr/local/bin/pip


## install/upgrade a couple python things

RUN pip3 install numpy --upgrade
RUN pip3 install pyparsing --upgrade
RUN pip3 install pandas --upgrade


################################################################
## ## install bioconductor packages
## ################################################################

## ## Seurat is a monstera, try to build early so if it fails we know sooner.

## RUN Rscript -e 'install.packages("BiocManager") '

## RUN Rscript -e 'BiocManager::install( "Seurat" ) '
## RUN Rscript -e 'BiocManager::install( "pathview" ) '
## RUN Rscript -e 'BiocManager::install("GO.db" ) '
## RUN Rscript -e 'BiocManager::install("DO.db" ) '
## RUN Rscript -e 'BiocManager::install("org.Hs.eg.db" ) '
## RUN Rscript -e 'BiocManager::install("enrichplot" ) '
## RUN Rscript -e 'BiocManager::install("GOSemSim" ) '
## RUN Rscript -e 'BiocManager::install("clusterProfiler" ) '
## RUN Rscript -e 'BiocManager::install("topGO" ) '
## RUN Rscript -e 'BiocManager::install("HTSeqGenie") '

## ################################################################
## ## install a ton of other packages, see r-package-install.R
################################################################

ADD r-package-install.R r-package-install.R
RUN Rscript r-package-install.R

################################################################
## stuff from github
################################################################

RUN Rscript -e  'devtools::install_github("homerhanumat/shinyCustom")'

RUN Rscript -e  'devtools::install_github("hylasD/tSpace", build = TRUE, build_opts = c("--no-resave-data", "--no-manual"), force = T)'



