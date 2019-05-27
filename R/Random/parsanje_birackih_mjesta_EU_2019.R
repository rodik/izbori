library(rvest)
library(tidyverse)
library(pdftools)
library(devtools)
# devtools::install_github("ropensci/tabulizer", args="--no-multiarch")
library(tabulizer)
# library(stringi)
# library(stringr)

# skrejpanje birackih mjesta za EU izbore 2019.

# kreni od stranice s popisom pdf-ova
list_url <- "https://www.izbori.hr/site/izbori-referendumi/izbori-clanova-u-europski-parlament-iz-republike-hrvatske/izbori-clanova-u-europski-parlament-iz-republike-hrvatske-2019-1759/aktualnosti-1760/biracka-mjesta-1798/1798"
# procitaj stranicu
lista <- read_html(list_url, encoding = 'utf-8')
# izvuci linkove na sve PDF fajlove
pdfovi <- lista %>% 
    html_nodes(css = '.opis a') %>%
    html_attr('href') %>% 
    enc2utf8() %>%
    as_tibble() %>%
    rename(url = value)

## DOWNLOAD PDFs
for (i in 1:nrow(pdfovi)) {
    
    u <- pdfovi[i,"url"] %>% pull()
    
    file_name <- paste0(
                    'data/EU/2019/',
                    gsub(pattern = '.*/', replacement = '', u)
    ) %>% enc2utf8()
    
    # skini pdf
    download.file(u, file_name, mode="wb")
    print(file_name)
}

# OBRADI JEDAN PO JEDAN PDF
files <- list.files('data/EU/2019', full.names = T)

sva_bm_2019 <- tibble()
for (i in 1:length(files)) {
    
    file_name <- files[i]
    
    text <- pdf_text(file_name)
    
    tbl_list <- extract_tables(file = file_name, encoding = 'UTF-8', method = 'stream')
    
    # 15. dokument je govno i treba ga pocistiti ovako
    if (i == 15) {
        for (j in 1:length(tbl_list)) {
            t <- tbl_list[[j]]
            t[1,4] <- "NAZIV"
            t <- t[,-5]     # makni petu kolonu
            if (j == 1) {
                t[1,6] <- "ADRESA_OPISNA"
                t <- t[,-7]     # makni zadnju kolonu
            }
            if (j == 5) {
                t[1,5] <- "LOKACIJA"
                t <- t[,-6]     # makni predzadnju kolonu
            }
            t[1,6] <- "ADRESA" 
            tbl_list[[j]] <- t
        }
    }
    
    tibble_list <- tbl_list %>% plyr::ldply(function(x){
        t <- as_tibble(x)
        # if (i == 15) {
        #     
        # }
        # if (ncol(t) > 6) { # cetvrtoj koloni daj naziv
        #     t[1,4] <- "NAZIV"
        #     t <- t[,-5]     # makni petu kolonu
        # }
        # if (ncol(t) > 6) { # predzadnjoj koloni daj naziv
        #     t[1,6] <- "ADRESA_OPISNA"
        #     t <- t[,-6]     # makni zadnju kolonu
        # }
        colnames(t) <- t[1,]
        t <- t[-1,]
    }) %>% as_tibble()
    
    sva_bm_2019 <- rbind(sva_bm_2019, tibble_list)
    print(i)
}