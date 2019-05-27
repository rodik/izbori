library(tidyverse)
library(openxlsx)

options(stringsAsFactors = FALSE)

my_read <- function(file_path) {
    read.csv2(file_path, encoding = 'windows-1250', check.names=FALSE) %>%
        as_tibble()
}

Parl_2015_Dohvati_Sva_Biracka_Mjesta <- function(){
    
    df <- my_read('data/Parlamentarni/2015/CSV/02_01_rezultati.csv') %>% select(1:10)
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_01_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_02_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_02_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_03_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_03_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_04_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_04_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_05_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_05_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_06_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_06_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_07_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_07_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_08_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_08_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_09_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_09_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_10_rezultati.csv') %>% select(1:10))
    df <- rbind(df, my_read('data/Parlamentarni/2015/CSV/02_10_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`))
    
    # procitaj biracka mjesta 11. izborne jedinice
    xi <- my_read('data/Parlamentarni/2015/CSV/02_11_rezultati.csv') %>% select(1:10)
    xi_pos <- my_read('data/Parlamentarni/2015/CSV/02_11_rezultati_posebna.csv') %>% select(1:10) %>% rename(`Rbr IJ` = `Rbr izborne jedinice birača`, `Naziv izborne jedinice` = `Naziv izborne jedinice birača`)
    
    # uzmi bilo koji fajl s manjinskih lista i od tamo pokpi sva izborna mjesta iz inozemstva
    ino <- my_read('data/Parlamentarni/2015/CSV/13_12_rezultati_inozemstvo.csv') %>% select(1:10)
    
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
}
    
Parl_2015_Obradi_Obicnu_Jedinicu <- function(
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
                            check.names=FALSE) %>% as_tibble() %>% rename(
                                `Rbr IJ` = `Rbr izborne jedinice birača`,
                                `Naziv izborne jedinice` = `Naziv izborne jedinice birača`
                            )
    
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

Parl_2015_Obradi_11_Jedinicu <- function(
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_11_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_11_rezultati_posebna.csv',
    last_fixed_col = 15,
    sva_biracka_mjesta
) {
    # ucitaj rezultate iz CSV-a
    df <- read.csv2(obicni_rezultati_filename, 
                    encoding = 'windows-1250',
                    check.names=FALSE) %>% as_tibble() 
    
    # ucitaj rezultate posebnih lista iz CSV-a
    df_posebna <- read.csv2(posebne_liste_filename, 
                            encoding = 'windows-1250',
                            check.names=FALSE) %>% as_tibble() %>% rename(
                                `Rbr IJ` = `Rbr izborne jedinice birača`,
                                `Naziv izborne jedinice` = `Naziv izborne jedinice birača`
                            )
    
    # spoji sva tri dataseta u jedan
    df <- rbind(df %>% mutate(izvor = 'obicni'), 
                df_posebna %>% mutate(izvor = 'posebna'))
    
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
    
    # liste_indexi <- c(16,25,40,55,63,78,86,94,104,111,126,138,145,156)
    # duljina_liste <- c(8, 14, 14, 7, 14, 7, 7, 9, 6, 14, 11, 6, 10, 7)
    
    # napravi vektor naziva fiksnih kolona (atributi birackih mjesta i agregirani rezultati)
    fixed_cols <- df[, c(1:last_fixed_col, last_col - 1, last_col)] %>% colnames() 
    # vektor naziva lista
    liste_cols <- df[, c(16,24,32,47,54,62,69,78,88,96,104)] %>% colnames()
    # vektor osoba na listama
    osobe_cols <- df[, c(17:23,25:31,33:46,48:53,55:61,63:68,70:77,79:87,89:95,97:103,105:110)] %>% colnames()
    # vektor broja osoba na pojedinoj listi
    osobe_breaks <- c(7, 7, 14, 6, 7, 6, 8, 9, 7, 7, 6)
    
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
        select(c(liste_cols, osobe_cols,'bm_guid','izvor')) %>%
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

Parl_2015_Obradi_12_Jedinicu <- function(
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/13_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/13_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/13_12_rezultati_inozemstvo.csv',
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
                            check.names=FALSE) %>% as_tibble() %>% rename(
                                `Rbr IJ` = `Rbr izborne jedinice birača`,
                                `Naziv izborne jedinice` = `Naziv izborne jedinice birača`
                            ) 
    
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

sva_bm_parl_2015 <- Parl_2015_Dohvati_Sva_Biracka_Mjesta()

parl_2015_izb_jed_01 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_01_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_01_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_01_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_02 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_02_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_02_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_02_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_03 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_03_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_03_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_03_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_04 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_04_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_04_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_04_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_05 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_05_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_05_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_05_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_06 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_06_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_06_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_06_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_07 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_07_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_07_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_07_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_08 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_08_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_08_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_08_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_09 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_09_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_09_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_09_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_10 <- Parl_2015_Obradi_Obicnu_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/02_10_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/02_10_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/02_10_rezultati_inozemstvo.csv',
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_izb_jed_11 <- Parl_2015_Obradi_11_Jedinicu(sva_biracka_mjesta = sva_bm_parl_2015)

parl_2015_12__13 <- Parl_2015_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/13_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/13_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/13_12_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 11,
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_12__23 <- Parl_2015_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/23_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/23_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/23_12_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 2,
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_12__33 <- Parl_2015_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/33_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/33_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/33_12_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 3,
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_12__43 <- Parl_2015_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/43_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/43_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/43_12_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 2,
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_12__53 <- Parl_2015_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/53_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/53_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/53_12_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 11,
    sva_biracka_mjesta = sva_bm_parl_2015
)
parl_2015_12__63 <- Parl_2015_Obradi_12_Jedinicu (
    obicni_rezultati_filename = 'data/Parlamentarni/2015/CSV/63_12_rezultati.csv',
    posebne_liste_filename = 'data/Parlamentarni/2015/CSV/63_12_rezultati_posebna.csv',
    inozemstvo_filename = 'data/Parlamentarni/2015/CSV/63_12_rezultati_inozemstvo.csv',
    last_fixed_col = 15,
    kandidata_na_listi = 12,
    sva_biracka_mjesta = sva_bm_parl_2015
)



#### sva biracka mjesta export 
sva_bm_parl_2015 %>% select(bm_key = bm_guid, c(1:8)) %>% spremiCSV(
    fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2015\\popis_birackih_mjesta.csv'
)


#### glasovi export

rbind(
    parl_2015_izb_jed_01$glasovi %>% mutate(izborna_jedinica = "1"),    
    parl_2015_izb_jed_02$glasovi %>% mutate(izborna_jedinica = "2"),    
    parl_2015_izb_jed_03$glasovi %>% mutate(izborna_jedinica = "3"),    
    parl_2015_izb_jed_04$glasovi %>% mutate(izborna_jedinica = "4"),    
    parl_2015_izb_jed_05$glasovi %>% mutate(izborna_jedinica = "5"),    
    parl_2015_izb_jed_06$glasovi %>% mutate(izborna_jedinica = "6"),    
    parl_2015_izb_jed_07$glasovi %>% mutate(izborna_jedinica = "7"),    
    parl_2015_izb_jed_08$glasovi %>% mutate(izborna_jedinica = "8"),    
    parl_2015_izb_jed_09$glasovi %>% mutate(izborna_jedinica = "9"),    
    parl_2015_izb_jed_10$glasovi %>% mutate(izborna_jedinica = "10"),
    parl_2015_izb_jed_11$glasovi %>% mutate(izborna_jedinica = "11"),
    parl_2015_12__13$glasovi %>% mutate(izborna_jedinica = "12_13"),
    parl_2015_12__23$glasovi %>% mutate(izborna_jedinica = "12_23"),
    parl_2015_12__33$glasovi %>% mutate(izborna_jedinica = "12_33"),
    parl_2015_12__43$glasovi %>% mutate(izborna_jedinica = "12_43"),
    parl_2015_12__53$glasovi %>% mutate(izborna_jedinica = "12_53"),
    parl_2015_12__63$glasovi %>% mutate(izborna_jedinica = "12_63")
) %>% 
    mutate(
        is_lista = if_else(is_lista == TRUE,"1","0"),
        bm_key = bm_guid
    ) %>% spremiCSV(
        fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2015\\glasovi.csv'
        
    )

#### biracka mjesta sumarno

rbind(
    parl_2015_izb_jed_01$biracka_mjesta %>% mutate(izborna_jedinica = "1"),    
    parl_2015_izb_jed_02$biracka_mjesta %>% mutate(izborna_jedinica = "2"),    
    parl_2015_izb_jed_03$biracka_mjesta %>% mutate(izborna_jedinica = "3"),    
    parl_2015_izb_jed_04$biracka_mjesta %>% mutate(izborna_jedinica = "4"),    
    parl_2015_izb_jed_05$biracka_mjesta %>% mutate(izborna_jedinica = "5"),    
    parl_2015_izb_jed_06$biracka_mjesta %>% mutate(izborna_jedinica = "6"),    
    parl_2015_izb_jed_07$biracka_mjesta %>% mutate(izborna_jedinica = "7"),    
    parl_2015_izb_jed_08$biracka_mjesta %>% mutate(izborna_jedinica = "8"),    
    parl_2015_izb_jed_09$biracka_mjesta %>% mutate(izborna_jedinica = "9"),    
    parl_2015_izb_jed_10$biracka_mjesta %>% mutate(izborna_jedinica = "10"),
    parl_2015_izb_jed_11$biracka_mjesta %>% mutate(izborna_jedinica = "11"),
    parl_2015_12__13$biracka_mjesta %>% mutate(izborna_jedinica = "12_13"),
    parl_2015_12__23$biracka_mjesta %>% mutate(izborna_jedinica = "12_23"),
    parl_2015_12__33$biracka_mjesta %>% mutate(izborna_jedinica = "12_33"),
    parl_2015_12__43$biracka_mjesta %>% mutate(izborna_jedinica = "12_43"),
    parl_2015_12__53$biracka_mjesta %>% mutate(izborna_jedinica = "12_53"),
    parl_2015_12__63$biracka_mjesta %>% mutate(izborna_jedinica = "12_63")
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
    fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2015\\bm_total.csv'
)


#### liste export

rbind(
    parl_2015_izb_jed_01$liste %>% mutate(izborna_jedinica = "1") %>% ungroup(),    
    parl_2015_izb_jed_02$liste %>% mutate(izborna_jedinica = "2") %>% ungroup(),    
    parl_2015_izb_jed_03$liste %>% mutate(izborna_jedinica = "3") %>% ungroup(),    
    parl_2015_izb_jed_04$liste %>% mutate(izborna_jedinica = "4") %>% ungroup(),    
    parl_2015_izb_jed_05$liste %>% mutate(izborna_jedinica = "5") %>% ungroup(),    
    parl_2015_izb_jed_06$liste %>% mutate(izborna_jedinica = "6") %>% ungroup(),    
    parl_2015_izb_jed_07$liste %>% mutate(izborna_jedinica = "7") %>% ungroup(),    
    parl_2015_izb_jed_08$liste %>% mutate(izborna_jedinica = "8") %>% ungroup(),    
    parl_2015_izb_jed_09$liste %>% mutate(izborna_jedinica = "9") %>% ungroup(),    
    parl_2015_izb_jed_10$liste %>% mutate(izborna_jedinica = "10") %>% ungroup(),
    parl_2015_izb_jed_11$liste %>% mutate(izborna_jedinica = "11") %>% ungroup(),
    parl_2015_12__13$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_13"),
    parl_2015_12__23$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_23"),
    parl_2015_12__33$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_33"),
    parl_2015_12__43$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_43"),
    parl_2015_12__53$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_53"),
    parl_2015_12__63$liste %>% as_tibble() %>% transmute(lista = value, osoba = value, poz = as.integer(NA), izborna_jedinica = "12_63")
) %>% spremiCSV(
    fileName = 'C:\\Users\\filip\\Documents\\R projects\\ODD_2019_data\\Parlamentarni izbori 2015\\liste.csv'
)
