library(readxl)
library(dplyr)
library(tidyr)

# lokalni izbori funkcije
lokalni_izbori_procitaj <- function(file_path, drugi_krug = FALSE){
    # procitaj oba sheeta
    rt <- list()
    
    if (drugi_krug) {
        zupan <- read_excel(file_path, 1)
        
        zupan_lst <- lokalni_obradi_sheet(zupan)
        
        rt <- zupan_lst
    }
    else {
        skupstina <- read_excel(file_path, 1)
        zupan <- read_excel(file_path, 2)
        
        skupstina_lst <- lokalni_obradi_sheet(skupstina)
        zupan_lst <- lokalni_obradi_sheet(zupan)
        
        rt <- list(
            skupstina = skupstina_lst,
            zupan = zupan_lst
        )
    }
    
    rt
}

lokalni_obradi_sheet <- function(raw_data){
    
    df <- raw_data
    # dodaj id kolonu birackog mjesta na razini zupanije 
    df <- df %>% mutate(bm_id = row_number())
    
    fiksne_kolone <- c("bm_id", names(df)[1:13])
    varijabilne_kolone <- names(df)[14:(length(names(df))-1)]
    
    # izvuci zaglavlje - statistike prema birackim mjestima
    header <- df %>% select(fiksne_kolone) %>%
        rename(zupanija_id = `Rbr.županije`)
    
    rbr_zupanije <- max(header$zupanija_id)
    
    # izvuci glasove po birackom mjestu i izbornoj listi
    glasovi <- df %>% gather(Lista, Glasova, varijabilne_kolone) %>%
        mutate(zupanija_id = rbr_zupanije) %>%
        select(bm_id, zupanija_id, Lista, Glasova)
    
    list(
        header = header,
        glasovi = glasovi
    )
} 
