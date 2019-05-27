library(tidyverse)
library(openxlsx)

options(stringsAsFactors = FALSE)

# ucitaj podatke iz CSV-a
df_2013 <- read.csv2('data/EU/2013/EUP2013_rezultati_po_BM_Work.csv', 
                encoding = 'windows-1250',
                check.names=FALSE) %>% as_tibble() 

# df_2013 %>% head() %>% View()

# dodaj numericki ID birackog mjesta
df_2013 <- df_2013 %>% mutate(bmid = row_number())
# napravi vektor naziva fiksnih kolona (atributi birackih mjesta i agregirani rezultati)
fixed_cols <- df_2013[, c(1:13,378)] %>% colnames() 
# vektor naziva lista
liste_cols <- df_2013[, seq(from = 14, to = 377, by = 13)] %>% colnames()
# vektor osoba na listama
osobe_cols <- df_2013[, setdiff(14:377, seq(from = 14, to = 377, by = 13))] %>% colnames()

# konstruiraj veze izmedu osoba i njihovih lista
liste_df_2013 <- tibble()
for (i in 0:(length(liste_cols)-1)) {
    
    lista <- liste_cols[i + 1]
    # logika kaze: iza kolone koja predstavlja listu, iducih 11 kolona su osobe s te liste
    prvi <- (i * 12) + 1
    zadnji <- prvi + 11
    
    # print(prvi)
    # print(zadnji)
    # print(' ## ')
    
    osobe <- osobe_cols[prvi:zadnji]
    
    spojeni <- data_frame(
        lista = lista,
        osoba = osobe
    )
    
    liste_df_2013 <- rbind(spojeni, liste_df_2013)
}
# dodaj redni broj na listi
liste_df <- liste_df %>% group_by(lista) %>% mutate(poz = row_number()) 

# napravi tablicu od fiksnih atributa, to su podaci o birackim mjestima i agregiranim rezultatima ()
biracka_mjesta_df_2013 <- df_2013 %>% select(fixed_cols)

# konstruiraj normaliziranu tablicu s glasovima na razini BM, Entitet
glasovi_2013 <- df_2013 %>% # head(100) %>% 
    select(-c(fixed_cols %>% setdiff('bmid'))) %>%
    gather(key = 'entitet', value = 'glasova',
           df_2013[,14:377] %>% colnames()) 

# oznaci koji su entiteti liste kako bi ih se moglo filtrirati kasnije
glasovi_2013 <- glasovi_2013 %>% 
    mutate(is_lista = if_else(entitet %in% liste_cols, TRUE, FALSE))

glasovi_2013 %>% head(10000) %>% View()

