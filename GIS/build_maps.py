import processing

# Adding layers
us = QgsVectorLayer("C:\Users\dgentil1\Documents\repo\Katrina\GIS\Layers\cb_2016_us_nation_5m\cb_2016_us_nation_5m.shp", "US", "ogr")
QgsMapLayerRegistry.instance().addMapLayer(us)

msa = QgsVectorLayer("C:\Users\dgentil1\Documents\repo\Katrina\GIS\Layers\cb_2016_us_cbsa_5m\cb_2016_us_cbsa_5m.shp", "MSAs", "ogr")
QgsMapLayerRegistry.instance().addMapLayer(msa)

matched = QgsVectorLayer("C:\Users\dgentil1\Documents\repo\Katrina\GIS\Layers\cbsa_metcode_matched.csv", "cbsa_metcode_matched", "ogr")
QgsMapLayerRegistry.instance().addMapLayer(matched)

# Joining shapefile and csv
msaField='GEOID'
matchedField='geoid'
joinObject = QgsVectorJoinInfo()
joinObject.joinLayerId = matched.id()
joinObject.joinFieldName = matchedField
joinObject.targetFieldName = msaField
joinObject.memoryCache = True
msa.addJoin(joinObject)

processing.runalg("qgis:polygoncentroids","C:/Users/dgentil1/Documents/repo/Katrina/GIS/Layers/cb_2016_us_cbsa_5m/cb_2016_us_cbsa_5m.shp", "Centroids")
