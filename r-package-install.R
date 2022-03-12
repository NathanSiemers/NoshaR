options(install.packages.check.source = "no")
options(install.packages.compile.from.source = "always")

qwc = function(...) { as.character( unlist( as.list( match.call() )[ -1 ] ) ) }

cranlist.first = qwc(
    scales,
    gridExtra )

cranlist = qwc (
    ##Biostrings,
    DT,
    devtools,
    GEOquery,
    GGally,
    Hmisc,
    RCurl,
    Rtsne,
    amap,
    bigmemory,
    BiocManager,
    boot,
    data.table,
    DBI,
    doMC,
    doParallel,
    editData,
    ##enrichplot,
    factoextra,
    flextable,
    foreach,
    furrr,
    ggpubr,
    ggridges,
    ggpubr,
    ggthemes,
    ggrepel,
    ggsci,
    ggnewscale,
    glue,
    gtable,
    igraph,
    knitr,
    meta,
    miniUI,
    officer,
    openssl,
    openxlsx,
    patchwork,
    pheatmap,
    plotly,
    plotrix,
    plyr,
    pROC,
    pool,
    ppcor,
    printr,
    psych,
    qgraph,
    qlcMatrix,
    reshape2,
    reticulate,
    RColorBrewer,
    rmarkdown,
    scales,
    shiny,
    shinyBS,
    shinycssloaders,
    shinydashboard,
    shinyjs,
    shinythemes,
    shinyWidgets,
    stringdist,
    stringr,
    survival,
    survminer,
    tidyverse,
    umap,
    viridis,
    wesanderson
) 

bioconductorlist = qwc (
    scran,
    Seurat,
    SeuratData,
    SeuratDisk,
    TENxPBMCData,
    glmGamPoi,
    pathview,
    GO.db,
    DO.db,
    org.Hs.eg.db,
    org.Mm.eg.db,
    enrichplot,
    GOSemSim,
    ##clusterProfiler,
    ##HTSeqGenie,
    topGO,
    limma
)        

install_it = function() {

    ## optionally remove packages
    for ( i in c(cranlist.first, cranlist, bioconductorlist) ) {
        ##    try( remove.packages( i ) )
    }

    ## some packages might be needed first?
    for ( i in cranlist.first ) {

        install.packages(cranlist, type = 'binary', dependencies = TRUE)

        if ( ! library(i, character.only=TRUE, logical.return=TRUE) ) {
            ##quit(status=1, save='no')
            stop(paste('THERE WAS A PROBLEM WITH', i, 'NATHAN'))
        }
    }


    ## bioconductor
    for ( i in bioconductorlist ) {
        print('building in bioconductor')
        install.packages('BiocManager')

        ################################################################
        BiocManager::install( i,  ask = FALSE,
                             update = FALSE, force = FALSE)
        ################################################################


        ## error checking
        if ( ! library(i, character.only=TRUE, logical.return=TRUE) ) {
            ##quit(status=1, save='no')
            stop(paste('THERE WAS A PROBLEM WITH', i, 'NATHAN'))
        }
    }

    ## cran main body of packages
    for ( i in cranlist ) {
        print('building in cran')
        print(i)
        print(.libPaths())

        ################################################################
        install.packages(i, dependencies = TRUE, type = 'binary',
                         repos = 'https://cloud.r-project.org/')
        ################################################################


        ## error checking
        if ( ! library(i, character.only=TRUE, logical.return=TRUE) ) {
            ##quit(status=1, save='no')
            stop(paste('THERE WAS A PROBLEM WITH', i, 'NATHAN'))
        }
    }

}

install_it()






