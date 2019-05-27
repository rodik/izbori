library(tidyverse)
library(openxlsx)

options(stringsAsFactors = FALSE)

my_read <- function(file_path) {
    read.csv2(file_path, encoding = 'windows-1250', check.names=FALSE) %>%
        as_tibble()
}

P2016_Dohvati_Sva_Biracka_Mjesta <- function(){
    
    df <- my_read('data/Parlamentarni/2016/CSV/001_00_rezultati.csv') %>% select(1:10)
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/001_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/002_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/002_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/003_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/003_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/004_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/004_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/005_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/005_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/006_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/006_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/007_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/007_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/008_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/008_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/009_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/009_00_rezultati_posebna.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/010_00_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2016/CSV/010_00_rezultati_posebna.csv') %>% select(1:10))
    
    # procitaj biracka mjesta 11. izborne jedinice
    xi <- my_read('data/Parlamentarni/2016/CSV/011_00_rezultati.csv') %>% select(1:10)
    xi_pos <- my_read('data/Parlamentarni/2016/CSV/011_00_rezultati_posebna.csv') %>% select(1:10)
    
    # uzmi bilo koji fajl s manjinskih lista i od tamo pokpi sva izborna mjesta iz inozemstva
    ino <- my_read('data/Parlamentarni/2016/CSV/012_13_rezultati_inozemstvo.csv') %>% select(1:10)
    
    # spoji ove tri tablice u jednu
    svi <- rbind(df, xi, xi_pos, ino)
    
    # izvuci samo fizicke lokacije birackih mjesta
    svi <- svi %>% select(
        -`Rbr IJ`,
        -`Naziv izborne jedinice`
    )
    
    # spoji
    svi <- svi %>% unique()
    # dodaj ID koji ce biti jedinstven na razini svih fizikckih birackih mjesta
    svi <- svi %>% mutate(bm_guid = row_number())
    # vrati
    return(svi)
    
    # # moguce je iz jednog fajla iz 12. 
    # rbind(
    #     izb_jed_01$biracka_mjesta,
    #     izb_jed_02$biracka_mjesta,
    #     izb_jed_03$biracka_mjesta,
    #     izb_jed_04$biracka_mjesta,
    #     izb_jed_05$biracka_mjesta,
    #     izb_jed_06$biracka_mjesta,
    #     izb_jed_07$biracka_mjesta,
    #     izb_jed_08$biracka_mjesta,
    #     izb_jed_09$biracka_mjesta,
    #     izb_jed_10$biracka_mjesta
    # ) %>% 
    # select(-bmid, -`Rbr IJ`, -`Naziv izborne jedinice`) %>% 
    #     filter(duplicated(.))
}

Parl_2016_Obradi_Obicnu_Jedinicu <- function(
    obicni_rezultati_filename, # path do CSV fajla s obicnim glasovanjem
    posebne_liste_filename,    # path do CSV fajla s rezultatima posebnih lista
    inozemstvo_filename,       # path do CSV fajla s rezultatima iz inozemstva
    last_fixed_col = 15,       # zadnja kolona koja sadrzava atribute birackog mjesta (prva iduca je ime liste ili kandidata)
    kandidata_na_listi = 14,   # broj kandidata na svakoj listi (mora biti konstantan unutar dokumenta)
    sva_biracka_mjesta         # data.frame s popisom svih fizickih birackih mjesta
) {
    # ucitaj rezultate iz CSV-a
    df <- read.csv2(obicni_rezultati_filename, 
                    encoding = 'windows-1250',
                    check.names=FALSE) %>% as_tibble() 
    
    # ucitaj rezultate posebnih lista iz CSV-a
    df_posebna <- read.csv2(posebne_liste_filename, 
                            encoding = 'windows-1250',
                            check.names=FALSE) %>% as_tibble() 
    
    # ucitaj rezultate inozemstva iz CSV-a
    df_inozemstvo <- read.csv2(inozemstvo_filename, 
                               encoding = 'windows-1250',
                               check.names=FALSE) %>% as_tibble() 
    
    # spoji sva tri dataseta u jedan
    df <- rbind(df %>% mutate(izvor = 'obicni'), 
                df_posebna %>% mutate(izvor = 'posebna'), 
                df_inozemstvo %>% mutate(izvor = 'inozemstvo'))
    
    # df %>% head() %>% View()
    
    # dodaj numericki ID birackog mjesta
    # df <- df %>% mutate(bmid = row_number())
    df <- df %>% inner_join(sva_biracka_mjesta, by = c(
        "Rbr.županije"="Rbr.županije",
        "Županija"="Županija",
        "Oznaka Gr/Op/Dr"="Oznaka Gr/Op/Dr",
        "Grad/općina/država"="Grad/općina/država",
        "Rbr BM"="Rbr BM",
        "Naziv BM"="Naziv BM",
        "Lokacija BM"="Lokacija BM",
        "Adresa BM"="Adresa BM"
    ))
    
    # last_fixed_col <- 15
    last_col <- ncol(df)
    # kandidata_na_listi <- 14
    
    # napravi vektor naziva fiksnih kolona (atributi birackih mjesta i agregirani rezultati)
    fixed_cols <- df[, c(1:last_fixed_col, last_col - 1, last_col)] %>% colnames() 
    # vektor naziva lista
    liste_cols <- df[, seq(from = (last_fixed_col + 1), to = (last_col - 2), by = kandidata_na_listi + 1)] %>% colnames()
    # vektor osoba na listama
    osobe_cols <- df[, setdiff((last_fixed_col + 1):(last_col - 2), seq(from = (last_fixed_col + 1), to = (last_col - 2), by = (kandidata_na_listi + 1)))] %>% colnames()
    
    # konstruiraj veze izmedu osoba i njihovih lista
    liste_df <- tibble()
    for (i in 0:(length(liste_cols)-1)) {
        
        lista <- liste_cols[i + 1]
        # logika kaze: iza kolone koja predstavlja listu, iducih 11 kolona su osobe s te liste
        prvi <- (i * kandidata_na_listi) + 1
        zadnji <- prvi + kandidata_na_listi - 1
        
        osobe <- osobe_cols[prvi:zadnji]
        
        spojeni <- data_frame(
            lista = lista,
            osoba = osobe
        )
        
        liste_df <- rbind(spojeni, liste_df)
    }
    # dodaj redni broj na listi
    liste_df <- liste_df %>% group_by(lista) %>% mutate(poz = row_number()) 
    
    # napravi tablicu od fiksnih atributa, to su podaci o birackim mjestima i agregiranim rezultatima ()
    biracka_mjesta_df <- df %>% select(fixed_cols)
    
    # konstruiraj normaliziranu tablicu s glasovima na razini BM, Entitet
    glasovi <- df %>% # head(100) %>% 
        select(c(liste_cols, osobe_cols,'bm_guid','izvor'))  %>%
        gather(key = 'entitet', 
               value = 'glasova',
               df[,(last_fixed_col + 1):(last_col - 2)] %>% colnames(),
               na.rm = TRUE)
    
    # oznaci koji su entiteti liste kako bi ih se moglo filtrirati kasnije
    glasovi <- glasovi %>% 
        mutate(is_lista = if_else(entitet %in% liste_cols, TRUE, FALSE)) %>% 
        mutate(glasova = as.integer(glasova))
    
    # return
    list(
        glasovi = glasovi,
        biracka_mjesta = biracka_mjesta_df,
        liste = liste_df
    )
}

Parl_2016_Obradi_11_Jedinicu <- function(
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/011_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/011_00_rezultati_posebna.csv',
    last_fixed_col = 15,
    sva_biracka_mjesta
) {
    # ucitaj rezultate iz CSV-a
    df <- read.csv2(obicni_rezultati_filename, 
                    encoding = 'windows-1250',
                    check.names=FALSE) %>% as_tibble() %>% 
                    mutate(izvor = 'obicni')
    
    # ucitaj rezultate posebnih lista iz CSV-a
    df_posebna <- read.csv2(posebne_liste_filename, 
                            encoding = 'windows-1250',
                            check.names=FALSE) %>% as_tibble() %>% 
                            mutate(izvor = 'posebna')
    
    # spoji oba dataseta u jedan
    df <- rbind(df, df_posebna)
    
    # dodaj numericki ID birackog mjesta
    df <- df %>% inner_join(sva_biracka_mjesta, by = c(
        "Rbr.županije"="Rbr.županije",
        "Županija"="Županija",
        "Oznaka Gr/Op/Dr"="Oznaka Gr/Op/Dr",
        "Grad/općina/država"="Grad/općina/država",
        "Rbr BM"="Rbr BM",
        "Naziv BM"="Naziv BM",
        "Lokacija BM"="Lokacija BM",
        "Adresa BM"="Adresa BM"
    ))
    
    # last_fixed_col <- 15
    last_col <- ncol(df)
    # kandidata_na_listi <- 14

    # liste_indexi <- c(16,25,40,55,63,78,86,94,104,111,126,138,145,156)
    # duljina_liste <- c(8, 14, 14, 7, 14, 7, 7, 9, 6, 14, 11, 6, 10, 7)
    
    # napravi vektor naziva fiksnih kolona (atributi birackih mjesta i agregirani rezultati)
    fixed_cols <- df[, c(1:last_fixed_col, last_col - 1, last_col)] %>% colnames() 
    # vektor naziva lista
    liste_cols <- df[, c(16,25,40,55,63,78,86,94,104,111,126,138,145,156)] %>% colnames()
    # vektor osoba na listama
    osobe_cols <- df[, c(17:24,26:39,41:54,56:62,64:77,79:85,87:93,95:103,105:110,112:125,127:137,139:144,146:155,157:163)] %>% colnames()
    # vektor broja osoba na pojedinoj listi
    osobe_breaks <- c(8, 14, 14, 7, 14, 7, 7, 9, 6, 14, 11, 6, 10, 7)
    
    # konstruiraj veze izmedu osoba i njihovih lista
    liste_df <- tibble()
    osobe_counter <- 0
    for (i in 0:(length(liste_cols)-1)) {
        
        lista <- liste_cols[i + 1]
        o <- osobe_breaks[i + 1]
        # logika kaze: iza kolone koja predstavlja listu, iducih 11 kolona su osobe s te liste
        prvi <- osobe_counter + 1
        zadnji <- prvi + o - 1
        osobe_counter <- osobe_counter + o
        
        osobe <- osobe_cols[prvi:zadnji]
        
        spojeni <- data_frame(
            lista = lista,
            osoba = osobe
        )
        
        liste_df <- rbind(spojeni, liste_df)
    }
    # dodaj redni broj na listi
    liste_df <- liste_df %>% group_by(lista) %>% mutate(poz = row_number()) 
    
    # napravi tablicu od fiksnih atributa, to su podaci o birackim mjestima i agregiranim rezultatima ()
    biracka_mjesta_df <- df %>% select(fixed_cols)
    
    # konstruiraj normaliziranu tablicu s glasovima na razini BM, Entitet
    glasovi <- df %>% # head(100) %>% 
        select(c(liste_cols, osobe_cols,'bm_guid','izvor'))  %>%
        gather(key = 'entitet', 
               value = 'glasova',
               df[,(last_fixed_col + 1):(last_col - 2)] %>% colnames(),
               na.rm = TRUE) 
    
    # oznaci koji su entiteti liste kako bi ih se moglo filtrirati kasnije
    glasovi <- glasovi %>% 
        mutate(is_lista = if_else(entitet %in% liste_cols, TRUE, FALSE)) %>% 
        mutate(glasova = as.integer(glasova))
    
    # return
    list(
        glasovi = glasovi,
        biracka_mjesta = biracka_mjesta_df,
        liste = liste_df
    )
}

Parl_2016_Obradi_12_Jedinicu <- function(
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_13_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_13_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_13_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 7,
    sva_biracka_mjesta
) {
    # ucitaj rezultate iz CSV-a
    df <- read.csv2(obicni_rezultati_filename, 
                    encoding = 'windows-1250',
                    check.names=FALSE) %>% as_tibble() 
    
    # ucitaj rezultate posebnih lista iz CSV-a
    df_posebna <- read.csv2(posebne_liste_filename, 
                            encoding = 'windows-1250',
                            check.names=FALSE) %>% as_tibble() 
    
    # ucitaj rezultate inozemstva iz CSV-a
    df_inozemstvo <- read.csv2(inozemstvo_filename, 
                               encoding = 'windows-1250',
                               check.names=FALSE) %>% as_tibble() 
    
    # spoji sva tri dataseta u jedan
    df <- rbind(df %>% mutate(izvor = 'obicni'), 
                df_posebna %>% mutate(izvor = 'posebna'), 
                df_inozemstvo %>% mutate(izvor = 'inozemstvo'))
    
    # dodaj numericki ID birackog mjesta
    df <- df %>% inner_join(sva_biracka_mjesta, by = c(
        "Rbr.županije"="Rbr.županije",
        "Županija"="Županija",
        "Oznaka Gr/Op/Dr"="Oznaka Gr/Op/Dr",
        "Grad/općina/država"="Grad/općina/država",
        "Rbr BM"="Rbr BM",
        "Naziv BM"="Naziv BM",
        "Lokacija BM"="Lokacija BM",
        "Adresa BM"="Adresa BM"
    ))
    
    # last_fixed_col <- 15
    last_col <- ncol(df)
    # kandidata_na_listi <- 14
    
    # liste_indexi <- c(16,25,40,55,63,78,86,94,104,111,126,138,145,156)
    # duljina_liste <- c(8, 14, 14, 7, 14, 7, 7, 9, 6, 14, 11, 6, 10, 7)
    
    # napravi vektor naziva fiksnih kolona (atributi birackih mjesta i agregirani rezultati)
    fixed_cols <- df[, c(1:last_fixed_col, last_col - 1, last_col)] %>% colnames() 
    # vektor osoba na listama
    osobe_cols <- df[, c((last_fixed_col + 1):((last_fixed_col + kandidata_na_listi)))] %>% colnames()
    
    # napravi tablicu od fiksnih atributa, to su podaci o birackim mjestima i agregiranim rezultatima ()
    biracka_mjesta_df <- df %>% select(fixed_cols)
    
    # konstruiraj normaliziranu tablicu s glasovima na razini BM, Entitet
    glasovi <- df %>% # head(100) %>% 
        select(c(osobe_cols,'bm_guid','izvor')) %>%
        gather(key = 'entitet', 
               value = 'glasova',
               df[,(last_fixed_col + 1):(last_col - 2)] %>% colnames(),
               na.rm = TRUE) 
    
    # u 12. jedinici se ne biraju liste ali dodaj flag da bude u skladu s drugim rezultatima
    glasovi <- glasovi %>% 
        mutate(is_lista = FALSE) %>% 
        mutate(glasova = as.integer(glasova))
    
    # return
    list(
        glasovi = glasovi,
        biracka_mjesta = biracka_mjesta_df,
        liste = osobe_cols
    )
}


# # ucitaj rezultate iz CSV-a
# df <- read.csv2('data/Parlamentarni/2016/CSV/001_00_rezultati.csv', 
#                      encoding = 'windows-1250',
#                      check.names=FALSE) %>% as_tibble() 
# 
# # ucitaj rezultate posebnih lista iz CSV-a
# df_posebna <- read.csv2('data/Parlamentarni/2016/CSV/001_00_rezultati_posebna.csv', 
#                 encoding = 'windows-1250',
#                 check.names=FALSE) %>% as_tibble() 
# 
# # ucitaj rezultate inozemstva iz CSV-a
# df_inozemstvo <- read.csv2('data/Parlamentarni/2016/CSV/001_00_rezultati_inozemstvo.csv', 
#                 encoding = 'windows-1250',
#                 check.names=FALSE) %>% as_tibble() 
# 
sva_bm_2016 <- P2016_Dohvati_Sva_Biracka_Mjesta()

izb_jed_01 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/001_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/001_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/001_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_02 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/002_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/002_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/002_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_03 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/003_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/003_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/003_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_04 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/004_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/004_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/004_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_05 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/005_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/005_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/005_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_06 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/006_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/006_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/006_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_07 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/007_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/007_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/007_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_08 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/008_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/008_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/008_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_09 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/009_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/009_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/009_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_10 <- Parl_2016_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/010_00_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/010_00_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/010_00_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_11 <- Parl_2016_Obradi_11_Jedinicu(sva_biracka_mjesta = sva_bm_2016)

izb_jed_12__13 <- Parl_2016_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_13_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_13_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_13_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 7,
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_12__23 <- Parl_2016_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_23_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_23_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_23_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 2,
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_12__33 <- Parl_2016_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_33_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_33_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_33_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 2,
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_12__43 <- Parl_2016_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_43_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_43_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_43_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 2,
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_12__53 <- Parl_2016_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_53_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_53_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_53_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 8,
    sva_biracka_mjesta = sva_bm_2016
)
izb_jed_12__63 <- Parl_2016_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2016/CSV/012_63_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2016/CSV/012_63_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2016/CSV/012_63_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 8,
    sva_biracka_mjesta = sva_bm_2016
)


#### sva biracka mjesta export 
sva_bm_2016 %>% select(bm_key = bm_guid, c(1:8)) %>% spremiCSV(
    fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2016\\popis_birackih_mjesta.csv'
)
    

#### glasovi export

rbind(
    izb_jed_01$glasovi %>% mutate(izborna_jedinica = "1"),    
    izb_jed_02$glasovi %>% mutate(izborna_jedinica = "2"),    
    izb_jed_03$glasovi %>% mutate(izborna_jedinica = "3"),    
    izb_jed_04$glasovi %>% mutate(izborna_jedinica = "4"),    
    izb_jed_05$glasovi %>% mutate(izborna_jedinica = "5"),    
    izb_jed_06$glasovi %>% mutate(izborna_jedinica = "6"),    
    izb_jed_07$glasovi %>% mutate(izborna_jedinica = "7"),    
    izb_jed_08$glasovi %>% mutate(izborna_jedinica = "8"),    
    izb_jed_09$glasovi %>% mutate(izborna_jedinica = "9"),    
    izb_jed_10$glasovi %>% mutate(izborna_jedinica = "10"),
    izb_jed_11$glasovi %>% mutate(izborna_jedinica = "11"),
    izb_jed_12__13$glasovi %>% mutate(izborna_jedinica = "12_13"),
    izb_jed_12__23$glasovi %>% mutate(izborna_jedinica = "12_23"),
    izb_jed_12__33$glasovi %>% mutate(izborna_jedinica = "12_33"),
    izb_jed_12__43$glasovi %>% mutate(izborna_jedinica = "12_43"),
    izb_jed_12__53$glasovi %>% mutate(izborna_jedinica = "12_53"),
    izb_jed_12__63$glasovi %>% mutate(izborna_jedinica = "12_63")
) %>% 
    mutate(
        is_lista = if_else(is_lista == TRUE,"1","0"),
        bm_key = bm_guid
    ) %>% spremiCSV(
        fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2016\\glasovi.csv'
        
    )

#### biracka mjesta sumarno export

rbind(
    izb_jed_01$biracka_mjesta %>% mutate(izborna_jedinica = "1"),    
    izb_jed_02$biracka_mjesta %>% mutate(izborna_jedinica = "2"),    
    izb_jed_03$biracka_mjesta %>% mutate(izborna_jedinica = "3"),    
    izb_jed_04$biracka_mjesta %>% mutate(izborna_jedinica = "4"),    
    izb_jed_05$biracka_mjesta %>% mutate(izborna_jedinica = "5"),    
    izb_jed_06$biracka_mjesta %>% mutate(izborna_jedinica = "6"),    
    izb_jed_07$biracka_mjesta %>% mutate(izborna_jedinica = "7"),    
    izb_jed_08$biracka_mjesta %>% mutate(izborna_jedinica = "8"),    
    izb_jed_09$biracka_mjesta %>% mutate(izborna_jedinica = "9"),    
    izb_jed_10$biracka_mjesta %>% mutate(izborna_jedinica = "10"),
    izb_jed_11$biracka_mjesta %>% mutate(izborna_jedinica = "11"),
    izb_jed_12__13$biracka_mjesta %>% mutate(izborna_jedinica = "12_13"),
    izb_jed_12__23$biracka_mjesta %>% mutate(izborna_jedinica = "12_23"),
    izb_jed_12__33$biracka_mjesta %>% mutate(izborna_jedinica = "12_33"),
    izb_jed_12__43$biracka_mjesta %>% mutate(izborna_jedinica = "12_43"),
    izb_jed_12__53$biracka_mjesta %>% mutate(izborna_jedinica = "12_53"),
    izb_jed_12__63$biracka_mjesta %>% mutate(izborna_jedinica = "12_63")
) %>% select(
    bm_guid,
    izvor,
    izborna_jedinica,
    `Rbr IJ`,
    `Naziv izborne jedinice`,
    `Ukupno birača`,
    `Glasovalo birača`,
    `Glasovalo birača (po listićima)`,
    `Važeći listići`,
    `Nevažeći listići`
) %>% mutate(
        bm_key = bm_guid
    ) %>% spremiCSV(
        fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2016\\bm_total.csv'
    )


#### liste export

rbind(
    izb_jed_01$liste %>% mutate(izborna_jedinica = "1") %>% ungroup(),    
    izb_jed_02$liste %>% mutate(izborna_jedinica = "2") %>% ungroup(),    
    izb_jed_03$liste %>% mutate(izborna_jedinica = "3") %>% ungroup(),    
    izb_jed_04$liste %>% mutate(izborna_jedinica = "4") %>% ungroup(),    
    izb_jed_05$liste %>% mutate(izborna_jedinica = "5") %>% ungroup(),    
    izb_jed_06$liste %>% mutate(izborna_jedinica = "6") %>% ungroup(),    
    izb_jed_07$liste %>% mutate(izborna_jedinica = "7") %>% ungroup(),    
    izb_jed_08$liste %>% mutate(izborna_jedinica = "8") %>% ungroup(),    
    izb_jed_09$liste %>% mutate(izborna_jedinica = "9") %>% ungroup(),    
    izb_jed_10$liste %>% mutate(izborna_jedinica = "10") %>% ungroup(),
    izb_jed_11$liste %>% mutate(izborna_jedinica = "11") %>% ungroup(),
    izb_jed_12__13$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_13"),
    izb_jed_12__23$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_23"),
    izb_jed_12__33$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_33"),
    izb_jed_12__43$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_43"),
    izb_jed_12__53$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_53"),
    izb_jed_12__63$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_63")
) %>% spremiCSV(
    fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2016\\liste.csv'
)

# folder <- 'data/Parlamentarni/2016/CSV/'
# file_list <- list.files(path = folder, pattern = 'rezultati.csv')
# file_list <- paste0(folder, file_list)
# file_list <- grep(pattern = '01[12]', x = file_list, invert = TRUE, value = TRUE)
# 
# df <- plyr::ldply(file_list, my_read)
