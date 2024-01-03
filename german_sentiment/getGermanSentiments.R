# Ich habe bis jetzt keine Quelle gefunden die:
# a) den aktuellsten v2.0-Datensatz benutzt (Stand: März 2019) und
# b) die Wort-Inflektionen zusammenführt.
# Ich hoffe Menschen die Deutsche Sentiment-Analyse machen wollen können diesen Code gebrauchen

# Source/Quelle: http://wortschatz.uni-leipzig.de/de/download

# Load Packages/Pakete laden
library(readr)
library(reshape2)
library(stringr)
library(tidyr)
library(dplyr)

# DL, Unzip and Read Data 
# Daten herunterladen, entpacken und einlesen
temp <- tempfile()
download.file("https://downloads.wortschatz-leipzig.de/etc/SentiWS/SentiWS_v2.0.zip", temp)
sentPos <- read_tsv(unz(temp, "SentiWS_v2.0_Positive.txt"), col_names = c("Stammwort", "Wert", "Inflektionen"))
sentNeg <- read_tsv(unz(temp, "SentiWS_v2.0_Negative.txt"), col_names = c("Stammwort", "Wert", "Inflektionen"))
unlink(temp)

# Get maximum number of word inflections 
# Maximale Anzahl an Inflektionen berechnen (für spätere Erweiterung des Datensatzes)
numInflekt <- max(str_count(c(sentPos$Inflektionen, sentNeg$Inflektionen), ","), na.rm = TRUE) + 1

# 1) Inflektionen in neue Spalten schieben (separate) 
# 2) Stammwort und Wortyp trennen (str_sub) 
# 3) Inflektionen zusammenführen (melt)
sentPos <- sentPos %>% separate(Inflektionen, sep = ",", into = paste0("Inflekt", 1:numInflekt), remove = TRUE, 
    extra = "merge", fill = "right") %>% mutate(Wort = str_sub(Stammwort, 1, regexpr("\\|", .$Stammwort) - 
    1), POS = str_sub(Stammwort, start = regexpr("\\|", .$Stammwort) + 1)) %>% select(-Stammwort) %>% 
    mutate(id = row_number())
sentPos <- melt(sentPos, id.vars = c("id", "Wert", "POS"), value.name = "Wort") %>% na.omit()

sentNeg <- sentNeg %>% separate(Inflektionen, sep = ",", into = paste0("Inflekt", 1:numInflekt), remove = TRUE, 
    extra = "merge", fill = "right") %>% mutate(Wort = str_sub(Stammwort, 1, regexpr("\\|", .$Stammwort) - 
    1), POS = str_sub(Stammwort, start = regexpr("\\|", .$Stammwort) + 1)) %>% select(-Stammwort) %>% 
    mutate(id = row_number())
sentNeg <- melt(sentNeg, id.vars = c("id", "Wert", "POS"), value.name = "Wort") %>% na.omit()

# Append Neg & Pos data (select&tolower are optional)
# Negativ & Positiv zusammenführen (select und tolower sind optional)
sentiDat <- bind_rows(neg = sentNeg, pos = sentPos, .id = "type") %>% select(-id, -variable) %>% 
    mutate(Wort = tolower(Wort))
# Glimpse/Anschauen
head(sentiDat)

# Cleanup
rm(sentNeg, sentPos, temp, numInflekt)