sessionInfo()

qwc = function(...) { as.character( unlist( as.list( match.call() )[ -1 ] ) ) }


cranlist = qwc (
    ##Biostrings,
    Seurat,
    DT,
    devtools,
    ##GEOquery,
    GGally,
    Hmisc,
    RCurl,
    Rtsne,
    amap,
    bigmemory,
    BiocManager,
    boot,
    cowplot,
    data.table,
    DBI,
    doMC,
    doParallel,
    editData,
    ##enrichplot,
    factoextra,
    flextable,
    foreach,
    ggpubr,
    ggridges,
    ggpubr,
    ggthemes,
    ggrepel,
    ggsci,
    ggnewscale,
    glue,
    gridExtra,
    gtable,
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
    ##printr,
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
    ##shinybusy,
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
    pathview,
    GO.db,
    DO.db,
    org.Hs.eg.db,
    org.Mm.eg.db,
    enrichplot,
    GOSemSim,
    ##clusterProfiler,
    ##HTSeqGenie,
    topGO
)    
    

install_it = function() {

        for ( i in cranlist ) {
            ##try(remove.packages( i, '/usr/local/lib/R/library') )
            ##try(remove.packages( i, '/usr/local/lib/R/site-library') )
            print('building in cran')
            print(i)
            install.packages(i)
            if ( ! library(i, character.only=TRUE, logical.return=TRUE) ) {
                quit(status=1, save='no')
            }
        }

    for ( i in bioconductorlist ) {
            print('building in bioconductor')
            print(i)
            BiocManager::install( i, type = "source" )
            if ( ! library(i, character.only=TRUE, logical.return=TRUE) ) {
                quit(status=1, save='no')
            }
    }
}

install_it()
