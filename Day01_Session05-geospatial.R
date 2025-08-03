
# Check Package Requirements ----------------------------------------------

# List of required packages
required_packages <- c("sf", "tidyverse", "ggrepel", "viridis")

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load all packages
lapply(required_packages, library, character.only = TRUE)



# Load Mapped Data --------------------------------------------------------

load(url("https://raw.githubusercontent.com/minerva79/GMS5204/main/geospatial.RData"))
# geo_data_clean_2d: base map for 332 subzones
# goe_data_pa: base map with 55 planning areas
# hospital_sf: hospital locations in Singapore
# fire_stations_sf: fire station locations in Singapore
# patients_sf: synthetic patient spatial location


library(sf); library(tidyverse)


# Visualisation of Base map ------------------

# visualisation of all 332 subzones in Singapore
ggplot(geo_data_clean_2d) +
  geom_sf(fill = "white", color = "black", size = 0.2) +
  theme_minimal() +
  labs(title = "Singapore Master Plan 2019 Subzones")


# visualisation of planning areas in Singapore
ggplot(geo_data_pa) +
  geom_sf(fill = "white", color = "black", size = 0.2) +
  theme_minimal() +
  labs(title = "Singapore Planning Areas")


# visualisation of subzones by region
ggplot(geo_data_clean_2d) +
  geom_sf(aes(fill = PLN_AREA_C), color = "white") +
  theme_minimal() +
  labs(title = "Singapore Administrative Region", fill = "Region") +
  theme(legend.position = "bottom") + 
  guides(fill = guide_legend(nrow = 2, byrow = TRUE))

# plot all towns in central region
central <- geo_data_clean_2d %>% filter(REGION_N == "CR")

ggplot(central) +
  geom_sf(aes(fill = CA_IND), color = "grey30") +
  theme_minimal() +
  labs(title = "Central Region Towns", fill = "") +
  theme(legend.position = "bottom",
        legend.key.size = unit(0.4, "cm"),
        legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 4, byrow = TRUE))


# plot all subzones in Bedok town area
bedok <- geo_data_clean_2d %>% filter(CA_IND == "BEDOK")

ggplot(bedok) +
  geom_sf(aes(fill = SUBZONE_NO), color = "grey30") +
  theme_minimal() +
  labs(title = "Bedok Town Area", fill = "Subzones") +
  theme(legend.position = "bottom",
        legend.key.size = unit(0.4, "cm"),
        legend.text = element_text(size = 8)) +
  guides(fill = guide_legend(ncol = 3, byrow = TRUE))


# Visualisation of point location of hospital and firestation -------------

# Visualisation of hospital location onto basemap
ggplot() +
  geom_sf(data = geo_data_clean_2d, fill = "white", color = "grey80") +
  geom_sf(data = hospital_sf, colour="black", size = 2) +
  geom_text_repel(
    data = hospital_sf,
    aes(geometry = geometry, label = toupper(hospital_name)),
    colour = "blue",
    stat = "sf_coordinates",
    # Convert sf geometry to x/y for plotting
    size = 3,
    min.segment.length = 0,
    box.padding = 0.3
  ) +
  theme_minimal() +
  labs(title = "Public Hospitals in Singapore", x = "", y = "")


# Visualisation of fire station locations in Singapore
ggplot() +
  geom_sf(data = geo_data_clean_2d, fill = "white", color = "grey80", size = 0.2) +
  geom_sf(data = fire_stations_sf, colour="red", size=3) +
  theme_minimal() +
  labs(title = "Locations of SCDF fire stations in Singapore")


# Inserting SDOH SES ------------------------------------------------------

# Creating Socioeconomic Advantage Index by Planning Area
sai_summary <- data.frame(
  planning_area = toupper(c(
    "Tanglin", "River Valley", "Newton", "Bukit Timah", "Marine Parade", "Novena",
    "Bishan", "Serangoon", "Pasir Ris", "Clementi", "Bedok", "Bukit Batok",
    "Queenstown", "Choa Chu Kang", "Jurong East", "Hougang", "Tampines",
    "Bukit Panjang", "Toa Payoh", "Ang Mo Kio", "Downtown Core", "Sembawang",
    "Geylang", "Kallang", "Yishun", "Bukit Merah", "Jurong West", "Sengkang",
    "Woodlands", "Rochor", "Outram", "Changi"
  )),
  sai = c(
    126.7, 123.7, 123.5, 122.2, 107.4, 105.8,
    103.4, 102.7, 100.2, 99.5, 98.8, 98.0,
    97.2, 95.7, 95.6, 95.5, 95.4,
    95.2, 95.1, 95.0, 95.0, 94.9,
    94.4, 94.4, 94.3, 94.3, 93.5, 93.5,
    93.3, 93.1, 91.5, 91.0
  )
)

# merging SAI into geo data at planning area
geo_data_sai <- geo_data_pa %>%
  left_join(sai_summary, by = c("CA_IND" = "planning_area"))

head(geo_data_sai)

# check planning areas that are not matched
setdiff(unique(geo_data_pa$CA_IND), sai_summary$planning_area)

library(viridis)
ggplot(geo_data_sai) +
  geom_sf(aes(fill = sai), color = "grey80") +
  scale_fill_viridis(
    name = "SAI",
    option = "C",
    direction = -1,
    na.value = "white"
  ) +
  labs(title = "Socioeconomic Advantage Index (SAI) by Planning Area") +
  theme_minimal()



# Mapping of patient location ---------------------------------------------

# Basic map: raw patient locations
ggplot() +
  geom_sf(data = geo_data_pa, fill="white", colour="grey80")+
  geom_sf(data = patients_sf,
             color = "blue", alpha = 0.6) +
  labs(title = "Raw Locations of Ambulance Call-Outs") +
  theme_minimal()




# Calculating distance of patient to all hospitals ------------------------

# Simulated patient locations (example)
patients_df <- data.frame(
  patient_id = c("P1", "P2"),
  lon = c(103.835, 103.900),
  lat = c(1.300, 1.360)
)

# Convert to sf object
patients_sf_demo <- st_as_sf(patients_df, coords = c("lon", "lat"), crs = 4326)

# Ensure both geometries use the same projection
# Optionally, transform to a projected CRS (e.g., EPSG:3414 for Singapore) for meters
patients_proj <- st_transform(patients_sf_demo, 3414)
hospitals_proj <- st_transform(hospital_sf, 3414)

# Calculate distances (in meters) between patients and hospitals
dist_matrix <- st_distance(patients_proj, hospitals_proj)

# Convert to a data frame for easy viewing
dist_df <- as.data.frame(dist_matrix)
rownames(dist_df) <- patients_sf$patient_id
colnames(dist_df) <- hospital_sf$hospital_name

print(dist_df)


# Unsupervised Learning of patient location -------------------------------

# Extract planar coordinates of patients
coords <- st_coordinates(patients_sf)


# Perform K-means clustering (adjust centers as needed)
set.seed(42)
kmeans_result <- kmeans(coords, centers = 4)

kmeans_result %>% head

# Attach cluster assignment
patients_sf$cluster <- as.factor(kmeans_result$cluster)

# Visualize clusters
ggplot() +
  geom_sf(data = geo_data_pa %>% st_transform(3414), fill = "white", color = "grey90") +
  geom_sf(data = patients_sf, aes(color = cluster), size = 2) +
  scale_color_brewer(palette = "Set1") +
  theme_minimal() +
  labs(title = "K-means Clustering of Ambulance Call-Outs", color = "Cluster")



# Smoother to identify potential cluster ----------------------------------

# Kernel density plot with filled contours

# Convert sf to data frame with lon/lat
patient_location <- patients_sf %>%
  st_transform(4326) %>%  # Ensure WGS84 for plotting
  mutate(longitude = st_coordinates(.)[,1],
         latitude = st_coordinates(.)[,2]) %>%
  st_drop_geometry()

ggplot() +
  geom_sf(data = geo_data_pa %>% st_transform(4326), fill = "white", color = "grey80") +
  stat_density_2d(data = patient_location,
                  aes(x = longitude, y = latitude, fill = ..level..),
                  color = "black",
                  alpha = 0.4,
                  bins = 8,
                  geom = "polygon") +
  scale_fill_viridis_c(option = "D", direction = -1) +
  theme_minimal() +
  labs(title = "Hotspot Map with Soft Fill and Contours", fill = "Density")


