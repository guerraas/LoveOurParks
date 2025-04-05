#for initial load use code below
us_states <- states(cb = TRUE) #us shapefile
#st_write(us_states, here("data","shapefiles","us_states_shape.shp"))
#us_states <- st_read(here("data","shapefiles","us_states_shape.shp"))


bbox48 <- st_bbox(c(xmin = -130, ymin = 20, xmax = -65, ymax = 50), crs = st_crs(us_states))
bboxAK <- st_bbox(c(xmin = -170, ymin = 50, xmax = -120, ymax = 90), crs = st_crs(us_states))
bboxHI <- st_bbox(c(xmin = -161, ymin = 0, xmax = -120, ymax = 22.5), crs = st_crs(us_states))

## crop shapefiles
lower_48 <- st_crop(us_states, bbox48)
alaska <- st_crop(us_states, bboxAK)
hawaii <- st_crop(us_states, bboxHI)

st_write(lower_48, here("data","shapefiles","lower_48_shape.shp"))
st_write(alaska, here("data","shapefiles","alaska_shape.shp"))
st_write(hawaii, here("data","shapefiles","hawaii_shape.shp"))