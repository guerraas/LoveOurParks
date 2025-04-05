### ANALYSIS OF VISITATION AND INTEREST TRENDS


nps_analysis <-nps_visit_adj %>% 
  left_join(GTtime_df, by=c("state", "date"))



### CORRELATION 
# do states with higher search interest in national parks also have higher visitation?



#SPEARMAN CORRELATION

nps_visit_score <- nps_analysis %>% filter(visit_metric == "visit_score")
nps_visit_ppark <- nps_analysis %>% filter(visit_metric == "visit_p_park")
nps_park_density <- nps_analysis %>% filter(visit_metric == "park_density")

# Spearman Correlation
spear_cor_vs <-  cor.test(nps_visit_score$visit_value, nps_visit_score$interest, method = "spearman")
spear_cor_vs

spear_cor_vp <-  cor.test(nps_visit_ppark$visit_value, nps_visit_ppark$interest, method = "spearman")
spear_cor_vp

spear_cor_pd <-  cor.test(nps_park_density$visit_value, nps_park_density$interest, method = "spearman")
spear_cor_pd



#spearman correlation plot - only plotting visitation score
spearman_plot <- nps_analysis %>% filter(visit_metric=="visit_score") %>% 
  ggplot(aes(x=interest, y=visit_value, color=date))+
  geom_point()+
  geom_smooth(method = "lm", se = FALSE,  size=1.5, color="red")+
  theme_minimal()+
  ggtitle("Correlation between visitation score and relative interest")+
  #geom_text(x=25,y=200000,
       #       label=paste0("correlation coefficient: ",round(spear_cor$estimate,2)),
      #        size=4,)+
 # geom_text(x=25,y=190000,
       #     label=paste0("p-value: <0.05"),
        #    size=4)+
  labs(x="relative interest", y="visitation score")+
  theme(axis.title = element_text(size=15),
        axis.text = element_text(size=12))
  




### INTEREST VS VISITATION DISCREPANCIES
# which states have high  interest but low visitation

nps_analysis_iv_ratio <- nps_analysis %>% filter(visit_metric == "visit_score") %>% 
  mutate(ratio = interest/visit_value) %>% arrange(desc(ratio))

## the outliers seem to be NJ and RI


plot_ratio_all <- nps_analysis_iv_ratio %>% 
  group_by(state) %>% 
  summarise(ratio = mean(ratio)) %>% 
  mutate(state = fct_reorder(state, ratio)) %>% 
  ggplot(aes(x=state,y=ratio))+
  geom_segment( aes(xend=state, yend=0)) +
  geom_point( size=2, color="darkblue") +
  coord_flip()+
  ylab("ratio (interest/visitation)")+ xlab(" ")+
  theme_classic()+
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size=12),
        axis.text = element_text(size=12),
        legend.position = "none")

plot_ratio_all 

## looking at time series, this might be due to:
#April , May 2020 for NJ (covid) and December 2020 for RI where tot_visits were 0. 
plot_ratio_outlier <- nps_analysis_iv_ratio %>% 
  group_by(state) %>% 
  filter(state %in% c("new jersey", "rhode island") &
           date < "2021-03-01") %>% 
ggplot(aes(x = date1, y = ratio, color=state)) +
  geom_line() +
  scale_x_date(date_labels="%b %y",date_breaks  ="2 month")+
  scale_color_manual(values=c("blue4", "chocolate1"))+
  theme_classic()+
  ylab("interest / visitation")+ xlab(" ")+
  theme(
    plot.title = element_text(size = 14, 
                              face = "bold", hjust = 0.5),
    axis.title.y = element_text(size=14),
    axis.title.x = element_blank(),
    axis.text = element_text(size=12, angle=90),
    axis.ticks = element_blank(),
    legend.title = element_blank(),
    legend.text = element_text(size=12))


### removing those outliers for the  view of remaining  points


highlights_ratio_plot <- nps_analysis_iv_ratio %>% 
  filter(!(state == "new jersey" & date1 %in% c("2020-04-01", "2020-05-01"))) %>% #remove the outlier dates
  filter(!(state == "rhode island" & date1 == "2020-12-01")) %>% 
  group_by(state) %>% 
  summarise(ratio = mean(ratio)) %>% 
  mutate(state = fct_reorder(state, ratio)) %>% 
  ggplot(aes(x=state,y=ratio))+
  geom_bar(stat = "identity")+
  coord_flip()+
  ylab("ratio (interest/visitation)")+ xlab(" ")+
  theme_classic()+
  theme(axis.title.y = element_blank(),
        axis.title.x = element_text(size=12),
        axis.text = element_text(size=12),
        legend.position = "none")


highlights_ratio_plot



