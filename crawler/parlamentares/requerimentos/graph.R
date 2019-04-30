library(networkD3)
library(tidyverse)

# Load data
data(MisLinks)
data(MisNodes)

# Plot
forceNetwork(Links = MisLinks, Nodes = MisNodes,
             Source = "source", Target = "target",
             Value = "value", NodeID = "name",
             Group = "group", opacity = 0.8)


nodes <- pl_14493 %>% 
  dplyr::select(nome, id_req, prop_id) %>% 
  dplyr::group_by(noem) %>% 
  dplyr::summarise(size = n())
