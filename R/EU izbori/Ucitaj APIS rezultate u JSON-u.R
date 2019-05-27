library(jsonlite)
library(purrr)
library(rlist)

files_dir <- "data/EU/2019/APIS rezultati JSON/"

rezultati_json_files <- list.files(
    path = files_dir,
    pattern = '*.json',
    full.names = FALSE, 
    recursive = FALSE
)

# run once, dalje radi s jedinstvenaSifra
liste <- data_raw$lista %>% 
    select(sifra_liste = jedinstvenaSifra, stranke) %>% 
    unnest(stranke) %>% 
    arrange(sifra_liste, naziv) %>%
    rename(stranka = naziv)


# rezultati_json_files
sve.objave <- tibble()
svi.glasovi_stranka <- tibble()
svi.glasovi_preferencijalni <- tibble()

for (f in rezultati_json_files) {
    print(paste('Reading file:', f))
    full_name <- paste0(files_dir, f)
    
    data_raw <- fromJSON(read_file(full_name))
    
    id <- paste0(data_raw$zupSifra, '_', f %>% str_split('_') %>% pluck(1) %>% pluck(4))
    grop_id <- f %>% str_split('_') %>% pluck(1) %>% pluck(4)
    izbori_id <- data_raw$izboriOznaka
    zupanija_id <- data_raw$zupSifra
    bm_id <- data_raw$bmSifra
    
    # izvuci zaglavlje fajla
    zaglavlje <- data_raw[1:19] %>% as_data_frame() %>% rename(
        bm_id = bmSifra,
        zupanija_id = zupSifra,
        izbori_id = izboriOznaka
    ) %>% mutate(grop_id = grop_id, id)
    
    # izvuci glasove na razini stranaka
    glasovi_stranaka <- data_raw$lista %>% 
        select(-lista, -stranke) %>%
        mutate(
            id = id,
            bm_id = bm_id,
            grop_id = grop_id,
            zupanija_id = zupanija_id,
            izbori_id = izbori_id,
            rez_id = paste0(id, '_', jedinstvenaSifra)
        ) %>% as_tibble()

    # izvuci glasove na razini osobe
    glasovi_preferencijalni <- data_raw$lista %>% 
        select(sifra_liste = jedinstvenaSifra, lista) %>%
        unnest(lista) %>% mutate(
            id = id,
            bm_id = bm_id,
            grop_id = grop_id,
            zupanija_id = zupanija_id,
            izbori_id = izbori_id,
            rez_id = paste0(id, '_', sifra_liste)
        )
    
    sve.objave <- rbind(zaglavlje, sve.objave)
    svi.glasovi_stranka <- rbind(glasovi_stranaka, svi.glasovi_stranka)
    svi.glasovi_preferencijalni <- rbind(glasovi_preferencijalni, svi.glasovi_preferencijalni)
}

sve.objave <- sve.objave %>% mutate(
    zupNaziv = if_else(zupanija_id == "22", 'INOZEMSTVO', zupNaziv)
)

sve.objave <- sve.objave %>% mutate(
    zupNaziv = if_else(zupanija_id == "00", 'UKUPNO RH', zupNaziv)
)

list(
    dim_liste = liste,
    rezultati = sve.objave,
    glasovi_stranaka = svi.glasovi_stranka,
    glasovi_preferencijalni = svi.glasovi_preferencijalni
) %>% saveRDS('export/rezultati_EU2019.RDS')

df <- readRDS("C:/Users/filip/Documents/R projects/izbori/export/rezultati_EU2019.RDS")

liste <- df$dim_liste
rezultati <- df$rezultati
glasovi_stranaka <- df$glasovi_stranaka
glasovi_preferencijalni <- df$glasovi_preferencijalni
