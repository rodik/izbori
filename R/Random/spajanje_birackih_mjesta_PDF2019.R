# spoji biracka mjesta na razini opcina s popisom opcina
bm_opcine <- sva_bm_2016 %>%
    filter(`Oznaka Gr/Op/Dr` == 'općina') %>%
    mutate(`Grad/općina/država` = if_else(`Grad/općina/država` == "ZLATAR BISTRICA", 'ZLATAR-BISTRICA', `Grad/općina/država`)) %>%
    mutate(`Grad/općina/država` = if_else(`Grad/općina/država` == "TAR-VABRIGA - TORRE-ABREGA", 'TAR - VABRIGA - TORRE - ABREGA', `Grad/općina/država`)) %>%
    inner_join(opcine_sudreg %>% 
                  mutate(naziv = stringi::stri_trans_toupper(naziv)), 
              by=c('Grad/općina/država' = 'naziv')) # %>% View()

# spoji biracka mjesta iz gradova s popisom opcina
bm_gradovi <- sva_bm_2016 %>%
    filter(`Oznaka Gr/Op/Dr` == 'grad') %>% 
    mutate(`Grad/općina/država` = if_else(grepl('zagreb',`Grad/općina/država`, ignore.case = T), 'ZAGREB', `Grad/općina/država`)) %>%
    inner_join(opcine_sudreg %>% 
                   mutate(naziv = stringi::stri_trans_toupper(naziv)), 
               by=c('Grad/općina/država' = 'naziv')) # %>% View()


# dodaj INOZEMSTVO redak u opcine_sudreg kolekciju
opcine_sudreg <- rbind(c(-2, -1, -2, 'N/A'), opcine_sudreg)
opcine_sudreg <- rbind(c(-1, -1, -1, 'INOZEMSTVO'), opcine_sudreg)

# spoji biracka mjesta iz inozemstva s prosirenim popisom opcina
bm_inozemstvo <- sva_bm_2016 %>%
    filter(`Oznaka Gr/Op/Dr` == 'država' & `Grad/općina/država` != 'HRVATSKA') %>% 
    mutate(join_col = 'INOZEMSTVO') %>% 
    inner_join(opcine_sudreg, 
               by=c('join_col' = 'naziv')) %>% select(-join_col)

# spoji sva biracka mjesta u jednu kolekciju
rbind(bm_opcine, bm_gradovi, bm_inozemstvo) %>%
    mutate(opcina_id = as.integer(id)) %>% 
    select(-zupanija_id, -sifra, -id)  %>%
    spremiXLSX(fileName = 'export/biracka_mjesta.XLSX')

opcine_sudreg %>% spremiXLSX('export/opcine.XLSX')
