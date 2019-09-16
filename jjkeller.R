library(tidyverse)
library(janitor)
library(scales)

source("data/locations.R")

JjkGraphs <- function(territory) {

df <- read.csv("data/jjkeller.csv")

jjk.qual <- df %>%
  left_join(jjkeller.locations, "Assigned.Location") %>%
  filter(manager == "TAMPA",
         DQ.File == "In Compliance" | DQ.File == "Out of Compliance") %>%
  mutate(dq.binary = recode(DQ.File,
                            "In Compliance" = 1,
                            "Out of Compliance" = 0)) %>%
  group_by(Assigned.Location) %>%
  summarise(num.compliant     = sum(dq.binary      ),
            total             = length(dq.binary   ),
            percent.compliant = num.compliant/total * 100)

jjk.qual.totals <- data.frame("Total:", sum(jjk.qual$num.compliant), sum(jjk.qual$total), round(sum(jjk.qual$num.compliant)/sum(jjk.qual$total) * 100,2))

colnames(jjk.qual.totals) <- colnames(jjk.qual)

# driver qual table
dq.table <- rbind(jjk.qual,jjk.qual.totals)

dq.table







df.table <- df %>%
  left_join(jjkeller.locations, "Assigned.Location") %>%
  filter(manager == territory,
         DQ.File == "In Compliance" | DQ.File == "Out of Compliance")

dq <- df.table %>%
  mutate(dq.binary = recode(DQ.File,
                            "In Compliance" = 1,
                            "Out of Compliance" = 0)) %>%
  group_by(Assigned.Location) %>%
  summarise(num.compliant     = sum(dq.binary      ),
            total             = length(dq.binary   ),
            percent.compliant = num.compliant/total*100)

dq.totals <- data.frame("Total:", sum(dq$num.compliant), sum(dq$total), round(sum(dq$num.compliant)/sum(dq$total) * 100,2))

colnames(dq.totals) <- colnames(dq)

# driver qual table
dq.table <- rbind(dq,dq.totals)


# DQ pie chart

dq.pie <- df %>%
 filter(DQ.File == "In Compliance" | DQ.File == "Out of Compliance") %>%
 group_by(DQ.File) %>%
 summarise (n = n()) %>%
 mutate(DQ.File = recode(DQ.File,
                         "In Compliance" = "Drivers In Compliance",
                         "Out of Compliance" = "Drivers Out Of Compliance"),
        freq = round((n / sum(n)) * 100, 2),
        label = paste(DQ.File, "-", paste(freq, "%", sep = ""))) %>%
 select(-c(n, DQ.File)) %>%
 ggplot(aes(x = 1, y = freq, fill = label)) +
 coord_polar(theta = 'y') +
 geom_bar(stat = "identity", color = 'black') +
 scale_fill_manual(values = c("darkgreen", "red")) +
 theme_minimal()+
 theme(
   axis.title.x = element_blank(),
   axis.text = element_blank(),
   axis.title.y = element_blank(),
   panel.border = element_blank(),
   panel.grid = element_blank(),
   axis.ticks = element_blank(),
   plot.title = element_text(size=14, face="bold"),
   legend.title = element_blank(),
   axis.text.x = element_blank(),
   legend.background = element_rect(linetype = "solid"))



# Driver Stats pie chart

dq.stats <- df %>%
 group_by(Status) %>%
 summarise (n = n()) %>%
 mutate(freq = round((n / sum(n)) * 100, 2),
        Status = recode(Status,
                        "Not Driving-" = "Not Driving"),
        label = paste(Status, "-", paste(freq, "%", sep = ""))) %>%
 select(-c(n, Status)) %>%
 ggplot(aes(x = 1, y = freq, fill = label)) +
 coord_polar(theta='y') +
 geom_bar(stat = "identity", color = 'black') +
 scale_fill_manual(values = c("deepskyblue4",
                              "firebrick4",
                              "yellowgreen",
                              "darkslateblue",
                              "darkcyan",
                              "chocolate3",
                              "lightsteelblue2",
                              "lightpink4",
                              "darkolivegreen4")) +
 theme_minimal()+
 theme(
   axis.title.x = element_blank(),
   axis.text = element_blank(),
   axis.title.y = element_blank(),
   panel.border = element_blank(),
   panel.grid = element_blank(),
   axis.ticks = element_blank(),
   plot.title = element_text(size=14, face="bold"),
   legend.title = element_blank(),
   axis.text.x = element_blank(),
   legend.background = element_rect(linetype = "solid")) +
 guides(fill = guide_legend(override.aes = list(colour=NA)))

return(list(dq.table, dq.pie, dq.stats))

}

JjkGraphs("TAMPA")