FROM rocker/rstudio:3.5.3

RUN cat /etc/apt/sources.list
RUN   apt-get update 

RUN Rscript -e 'print( .libPaths() ) '

## install debian packages

RUN apt-get install -y \
     sudo gdebi-core  pandoc  pandoc-citeproc  \
     libcairo2-dev   libxt-dev  libjpeg-dev  wget \
      libssl-dev libxml2-dev psmisc dselect libmariadbclient-dev \
      libcurl4-openssl-dev git emacs libhdf5-dev python3.5 python-pip \
      python-virtualenv


## Seurat is a monster, try to build early so if it fails we know sooner.

RUN Rscript -e 'options("BioC_mirror" = "https://bioconductor.org"); setRepositories(ind = 1:2); install.packages("Seurat") '

## install a bunch of other packages, see r-package-install.R

ADD r-package-install.R r-package-install.R
RUN Rscript r-package-install.R

## any stuff from github

RUN Rscript -e  'devtools::install_github("homerhanumat/shinyCustom")'

RUN Rscript -e  'devtools::install_github("hylasD/tSpace", build = TRUE, build_opts = c("--no-resave-data", "--no-manual"), force = T)'




