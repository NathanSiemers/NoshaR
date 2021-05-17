FROM rocker/rstudio:3.6.3

RUN cat /etc/apt/sources.list
RUN   apt-get update 

RUN Rscript -e 'print( .libPaths() ) '

## install debian packages

##RUN apt-get remove -y python2.7

RUN apt-get install -y python3.7

RUN apt-get install -y python3-pip


##RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.7

##RUN update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1

RUN apt-get install -y \
     sudo gdebi-core  pandoc  pandoc-citeproc  \
     libcairo2-dev   libxt-dev  libjpeg-dev  wget \
      libssl-dev libxml2-dev psmisc dselect libmariadbclient-dev \
      libcurl4-openssl-dev git emacs libhdf5-dev python-pip \
      python-virtualenv bowtie2 salmon samtools jellyfish cmake 



################################################################
RUN rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python
##RUN mv /usr/bin/pip /usr/bin/pip.old && ln -s /usr/bin/pip2 /usr/bin/pip
RUN mv /usr/bin/pip /usr/bin/pip.old && ln -s /usr/bin/pip3 /usr/bin/pip
################################################################

################################################################
## Tracer stuff



#Trinity - depends on zlib1g-dev and openjdk-8-jre installed previously
RUN wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.11.0/trinityrnaseq-v2.11.0.FULL.tar.gz
RUN tar xvzf trinityrnaseq-v2.11.0.FULL.tar.gz  && rm trinityrnaseq-v2.11.0.FULL.tar.gz
RUN cd /trinityrnaseq-v2.11.0  && make

#IgBLAST, plus the setup of its super weird internal_data thing. don't ask. just needs to happen
#and then on top of that, the environmental variable thing facilitates the creation of a shell wrapper. fun
RUN wget ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/1.7.0/ncbi-igblast-1.7.0-x64-linux.tar.gz
RUN tar -xzvf ncbi-igblast-1.7.0-x64-linux.tar.gz && rm ncbi-igblast-1.7.0-x64-linux.tar.gz
RUN cd /ncbi-igblast-1.7.0/bin/ && wget -r ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/old_internal_data && \
	wget -r ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release/old_optional_file && \
	mv ftp.ncbi.nih.gov/blast/executables/igblast/release/old_internal_data . && \
	mv ftp.ncbi.nih.gov/blast/executables/igblast/release/old_optional_file . && \
	rm -r ftp.ncbi.nih.gov

#aligners - kallisto and salmon
RUN wget https://github.com/pachterlab/kallisto/releases/download/v0.43.1/kallisto_linux-v0.43.1.tar.gz
RUN tar -xzvf kallisto_linux-v0.43.1.tar.gz && rm kallisto_linux-v0.43.1.tar.gz
#RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v0.8.2/Salmon-0.8.2_linux_x86_64.tar.gz
#RUN tar -xzvf Salmon-0.8.2_linux_x86_64.tar.gz && rm Salmon-0.8.2_linux_x86_64.tar.gz

#graphviz, which lives in a sufficient form (dot/neato) in apt-get apparently
RUN apt-get -y install graphviz
## wait wot, tracer isn't in this download...



RUN wget https://github.com/Teichlab/tracer/archive/refs/heads/master.zip && unzip master.zip && mv tracer-master tracer

RUN pip3 install numpy --upgrade
RUN pip3 install pyparsing --upgrade

#tracer proper
COPY . /tracer
##RUN cd /tracer && pip install -r docker_helper_files/requirements_stable.txt && python setup.py install

RUN cd /tracer && pip install -r docker_helper_files/requirements_stable.txt && python setup.py install

#obtaining the transcript sequences. no salmon/kallisto indices as they make dockerhub unhappy for some reason
RUN mkdir GRCh38 && cd GRCh38 && wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_27/gencode.v27.transcripts.fa.gz && \
	gunzip gencode.v27.transcripts.fa.gz && python3 /tracer/docker_helper_files/gencode_parse.py gencode.v27.transcripts.fa && rm gencode.v27.transcripts.fa
RUN mkdir GRCm38 && cd GRCm38 && wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M15/gencode.vM15.transcripts.fa.gz && \
	gunzip gencode.vM15.transcripts.fa.gz && python3 /tracer/docker_helper_files/gencode_parse.py gencode.vM15.transcripts.fa && rm gencode.vM15.transcripts.fa

#placing a preconfigured tracer.conf in ~/.tracerrc
RUN cp /tracer/docker_helper_files/docker_tracer.conf ~/.tracerrc

#this is a tracer container, so let's point it at a tracer wrapper that sets the silly IgBLAST environment variable thing
ENTRYPOINT ["bash", "/tracer/docker_helper_files/docker_wrapper.sh"]

################################################################
## end of tracer stuff


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

RUN pip install RSeQC



## any stuff from github

RUN Rscript -e  'devtools::install_github("homerhanumat/shinyCustom")'

RUN Rscript -e  'devtools::install_github("hylasD/tSpace", build = TRUE, build_opts = c("--no-resave-data", "--no-manual"), force = T)'




