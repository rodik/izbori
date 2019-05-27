# geocoding
install.packages('ggmap')
library(ggmap)

unq_lokacije <- biracka_mjesta_df_2014 %>% filter(bmid %in% 1:10) %>% 
    mutate(
        geo_string = paste0(
            `Adresa BM`, ', ',
            `Grad/općina/država`, ', ',
            Županija
        ) %>% enc2utf8()
    ) %>% #View()
    select(bmid, geo_string) %>% unique()
    # mutate_geocode()

geocoded_lokacije <- mutate_geocode(unq_lokacije, geo_string)
