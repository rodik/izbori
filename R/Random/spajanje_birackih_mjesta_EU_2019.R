library(googlesheets)
# spajanje bm

bm_2019_unmatched <- read.xlsx('data/EU/2019/Copy of bm_2019.XLSX') %>%
                        as_tibble()

# list google sheets
# gs_ls()
# get specific sheet document by key
gs <- gs_key('1H9RmlpTeliG3A-dS5-OD6aSM0cyY8khgpi08LiE6lJ4')
# list worksheets on doc
gs_ws_ls(gs)

# dohvati sifrant zupanija
sif_zupanije <- gs_read(ss=gs, ws = "Popis županija") %>%
    select(zupanija_id, naziv)

# spoji BM sa zupanijama
bm_2019_zup_matched <- sif_zupanije %>% 
    mutate(naziv = toupper(naziv)) %>%
    inner_join(bm_2019_unmatched, by=c('naziv'='ŽUPANIJA')) %>%
    rename(`ŽUPANIJA` = naziv)

bm_2019_zup_matched <- bm_2019_zup_matched %>% 
    mutate(`GRAD/OPĆINA` = if_else(`GRAD/OPĆINA` == "GRAD ZAGREB", 'ZAGREB', `GRAD/OPĆINA`)) %>%
    mutate(`GRAD/OPĆINA` = if_else(`GRAD/OPĆINA` == "ZLATAR BISTRICA", 'ZLATAR-BISTRICA', `GRAD/OPĆINA`)) %>%
    mutate(`GRAD/OPĆINA` = if_else(`GRAD/OPĆINA` == "TAR-VABRIGA - TORRE-ABREGA", 'TAR - VABRIGA - TORRE - ABREGA', `GRAD/OPĆINA`))

# dodaj id
bm_2019_zup_matched <- bm_2019_zup_matched %>%
    mutate(bm_id = row_number())

bm_2019_matched_all <- bm_2019_zup_matched %>% 
    inner_join(opcine_sudreg %>% mutate(naziv = toupper(naziv)),
               by = c('GRAD/OPĆINA' = 'naziv', 'zupanija_id' = 'zupanija_id')) %>%
    select(-sifra) %>%
    rename(opcina_id = id) %>%
    mutate(opcina_id = as.integer(opcina_id)) %>%
    select(
        bm_id, opcina_id, zupanija_id, `ŽUPANIJA`:ADRESA
    )

bm_2019_matched_all %>%
    spremiXLSX(fileName = 'export/biracka_mjesta_2019.XLSX')


###################################################
### 20.05.2019. nova verzija BM
bm <- read_xlsx('data/EU/2019/Popis redovnih BM za RHxlsx.xlsx')
pbm <- read_xlsx('data/EU/2019/PBM.xlsx')

# prilagodi nazive zupanija
bm <- bm %>% mutate(
    ŽUPANIJA = substr(ŽUPANIJA, 4, 100) %>% str_replace(' ŽUPANIJA', replacement = '') %>% trimws()
) %>% mutate(
    RedniBrojBM = as.character(`REDNI BROJ BM`)
) %>% select(-`REDNI BROJ BM`)

pbm <- pbm %>% group_by(ŽUPANIJA, `GRAD/OPĆINA`) %>% mutate(
    RedniBrojBM = (row_number() + 100) %>% as.character()
) %>% ungroup()

spojena_bm <- rbind(bm, pbm)

bm_2019_zup_matched <- sif_zupanije %>% 
    mutate(naziv = toupper(naziv)) %>%
    inner_join(spojena_bm, by=c('naziv'='ŽUPANIJA')) %>%
    rename(`ŽUPANIJA` = naziv)

bm_2019_zup_matched <- bm_2019_zup_matched %>% 
    mutate(`GRAD/OPĆINA` = if_else(`GRAD/OPĆINA` == "GRAD ZAGREB", 'ZAGREB', `GRAD/OPĆINA`)) %>%
    mutate(`GRAD/OPĆINA` = if_else(`GRAD/OPĆINA` == "ZLATAR BISTRICA", 'ZLATAR-BISTRICA', `GRAD/OPĆINA`)) %>%
    mutate(`GRAD/OPĆINA` = if_else(`GRAD/OPĆINA` == "TAR-VABRIGA - TORRE-ABREGA", 'TAR - VABRIGA - TORRE - ABREGA', `GRAD/OPĆINA`))

bm_2019_zup_matched <- bm_2019_zup_matched %>%
    mutate(bm_id = row_number())

bm_2019_matched_all <- bm_2019_zup_matched %>% 
    inner_join(opcine_sudreg %>% mutate(naziv = toupper(naziv)),
               by = c('GRAD/OPĆINA' = 'naziv', 'zupanija_id' = 'zupanija_id')) %>%
    select(-sifra) %>%
    rename(opcina_id = id) %>%
    mutate(opcina_id = as.integer(opcina_id)) %>%
    select(
        bm_id, opcina_id, zupanija_id, `ŽUPANIJA`: ADRESA, RedniBrojBM
    )

bm_2019_matched_all %>%
    spremiXLSX(fileName = 'export/biracka_mjesta_2019_v2.XLSX')
# sva_bm_2019 %>% anti_join(bm, by=c(
#     'GRAD/OPĆINA' = 'GRAD/OPĆINA',
#     'REDNI BROJ BM' = 'REDNI BROJ BM',
#     'NAZIV' = 'NAZIV'
# )) %>% View()
