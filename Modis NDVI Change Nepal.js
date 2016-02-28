
// Define the area or interest (used to mask extext)

var Nepal = ee.Geometry.Polygon(
        [[[79.65087890625, 28.729130483430154],
          [81.826171875, 27.46928747369202],
          [85.1220703125, 26.56887654795065],
          [87.73681640625, 25.99754991957211],
          [88.3740234375, 26.33280692289788],
          [88.39599609375, 27.293689224852404],
          [88.43994140625, 28.188243641850313],
          [86.923828125, 28.32372455354601],
          [85.78125, 28.767659105691255],
          [84.61669921875, 29.305561325527698],
          [83.583984375, 29.783449456820605],
          [82.1337890625, 30.54333895423022],
          [81.27685546875, 30.713503990354965],
          [80.419921875, 30.240086360983426],
          [79.6728515625, 29.401319510041485]]]);
    
        
          
var palette = ['FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718',
               '74A901', '66A000', '529400', '3E8601', '207401', '056201',
               '004C00', '023B01', '012E01', '011D01', '011301'];
               
               
// CLOUD and WATER MASK

// Extract MODIS QA information from the "state_1km" QA band
// and use it to mask out cloudy and deep ocean areas.
//
// QA Band information is available at:
// https://lpdaac.usgs.gov/products/modis_products_table/mod09ga
// Table 1: 1-kilometer State QA Descriptions (16-bit)


/**
 * Returns an image containing just the specified QA bits.
 *
 * Args:
 *   image - The QA Image to get bits from.
 *   start - The first bit position, 0-based.
 *   end   - The last bit position, inclusive.
 *   name  - A name for the output image.
 */
var getQABits = function(image, start, end, newName) {
    // Compute the bits we need to extract.
    var pattern = 0;
    for (var i = start; i <= end; i++) {
       pattern += Math.pow(2, i);
    }
    return image.select([0], [newName])
                  .bitwiseAnd(pattern)
                  .rightShift(start);
};



///////   CALCULATE CHANGE IN NDVI AND EUCLIDEAN DISTANCE FOR B1-7



// IMPORT RAW DATA 


// Reference a single MODIS MOD09GA image.
var image_pre = ee.Image('MOD09GA/MOD09GA_005_2015_04_08');
var image_post = ee.Image('MOD09GA/MOD09GA_005_2015_05_03');


// CREATE MASK FOR ICE/CLOUD/WATER/SHADOW

// Select the QA band
var QA_pre = image_pre.select('state_1km');
var QA_post = image_post.select('state_1km');

// Get the cloud_state bits and find cloudy areas.
// cloud mask2 true = clear no clouds
var cloud2_pre = getQABits(QA_pre, 0, 1, 'cloud_state2').neq(0)
var cloud2_post = getQABits(QA_post, 0, 1, 'cloud_state2').neq(0)

// Get the cloud_state bits and find shadows.
// cloud shadow true =  no shadow
var shadow_pre = getQABits(QA_pre, 2, 2, 'cloud_shadow').neq(0)
var shadow_post = getQABits(QA_post, 2, 2, 'cloud_shadow').neq(0)

                    
// Get the land_water_flag bits.
// 7= deep ocean, 5 = deep inland water https://lpdaac.usgs.gov/products/modis_products_table/mod09ga
// landWaterFlag = T = 1 if is land
var landWaterFlag_pre = getQABits(QA_pre, 3, 5, 'land_water_flag_pre').neq(1);
var landWaterFlag_post = getQABits(QA_post, 3, 5, 'land_water_flag_post').neq(1);


// Get internal snow ice flag =1 ice 
var iceFlag_pre = getQABits(QA_pre, 15, 15, 'iceFlag_pre');
var iceFlag_post = getQABits(QA_post, 15, 15, 'iceFlag_post');

// Get Mod 35 snow ice flag =1 ice 
var iceFlag35_pre = getQABits(QA_pre, 12, 12, 'iceFlag_pre');
var iceFlag35_post = getQABits(QA_post, 12, 12, 'iceFlag_post');


// Create a mask that filters out water, ice,  and cloudy areas.
var mask_pre  = image_pre.mask(landWaterFlag_pre.not()).and(iceFlag_pre.not().and(iceFlag35_pre.not()).and(cloud2_pre.not()).and(shadow_pre.not()));
var mask_post = image_post.mask(landWaterFlag_post.not()).and(iceFlag_post.not().and(iceFlag35_post.not()).and(cloud2_post).not().and(shadow_post.not()));

 
// Add a map layer with water, ice and clouds areas masked out.
Map.addLayer(
  image_pre.mask(mask_pre).clip(Nepal),
  {bands: 'sur_refl_b01,sur_refl_b04,sur_refl_b03', min: -100, max: 2000},
  'MOD09GA 2015_04_08'
);

Map.addLayer(
  image_post.mask(mask_post).clip(Nepal),
  {bands: 'sur_refl_b01,sur_refl_b04,sur_refl_b03', min: -100, max: 2000},
  'MOD09GA 2015_05_03'
);

/**
// Add a semi-transparent map layer that displays the clouds.
Map.addLayer(
  cloud2_pre.mask(cloud2_pre),
  {palette: 'FF3300', opacity: 0.4},
  'cloud2_pre'
);

Map.addLayer(
  cloud2_post.mask(cloud2_post),
  {palette: 'FF3300', opacity: 0.4},
  'cloud2_post'
);

// Add a semi-transparent map layer that displays the cloud shadows.
Map.addLayer(
  shadow_pre.mask(shadow_pre),
  {palette: 'CC3399', opacity: 0.4},
  'shadow_pre'
);

Map.addLayer(
  shadow_post.mask(shadow_post),
  {palette: 'CC3399', opacity: 0.4},
  'shadow_post'
);

// Add a semi-transparent map layer that displays the ice/snow internal flag.
Map.addLayer(
  iceFlag_pre.mask(iceFlag_pre),
  {palette: '0066FF', opacity: 0.8},
  'iceFlag_pre'
);

Map.addLayer(
  iceFlag_post.mask(iceFlag_post),
  {palette: '0066FF', opacity: 0.8},
  'iceFlag_post'
);

// Add a semi-transparent map layer that displays the ice/snow mod35 flag.
Map.addLayer(
  iceFlag_pre.mask(iceFlag_pre),
  {palette: '000099', opacity: 0.5},
  'iceFlag_pre'
);

Map.addLayer(
  iceFlag_post.mask(iceFlag_post),
  {palette: '000099', opacity: 0.5},
  'iceFlag_post'
);
**/



// Normalized Difference Vegetation .
//
// Compute Normalized Difference Vegetation Index over MOD09GA product.
// NDVI = (NIR - RED) / (NIR + RED), where
// RED is sur_refl_b01, 620-670nm
// NIR is sur_refl_b02, 841-876nm


Map.setCenter( 85.333333,27.700000, 8);


// earthquake hit 4/25 near  Bharatpur, Nepal
//MOD09GA_005_2015_04_08
// pre event date 005_2015_04_24
//
// next clear image 005_2015_05_03
//var image_pre = 
//var image_post =  

// Calculate both NDVI values
var ndvi_pre = image_pre.normalizedDifference(['sur_refl_b02', 'sur_refl_b01']).clip(Nepal);
var ndvi_post = image_post.normalizedDifference(['sur_refl_b02', 'sur_refl_b01']).clip(Nepal);

// Mask NDVI to avoid cloud/water/ice/shadow
var maskNDVI_pre  = ndvi_pre.mask(landWaterFlag_pre.not()).and(iceFlag_pre.not().and(iceFlag35_pre.not()).and(cloud2_pre.not()).and(shadow_pre.not()));
var maskNDVI_post = ndvi_post.mask(landWaterFlag_pre.not()).and(iceFlag_pre.not().and(iceFlag35_pre.not()).and(cloud2_pre.not()).and(shadow_pre.not()));

// Add image of masked NDVI values
Map.addLayer(ndvi_pre.mask(maskNDVI_pre).clip(Nepal), {min: 0, max: 1, palette: palette}, 'NDVI_pre_MASKED');
Map.addLayer(ndvi_post.mask(maskNDVI_post).clip(Nepal), {min: 0, max: 1, palette: palette}, 'NDVI_post_MASKED');

// calculate change in NDVI
// subtract post-pre (negative is loss of vegetation)
var ndvi_difference = ndvi_post.subtract(ndvi_pre)
var palette2 = ['FF0000', '009900'];
Map.addLayer(ndvi_difference, {min: -1, max: 1, palette:palette2}, 'ndvi_difference');



 

// CALCULATE EUCLIDEAN DISTANCE 

var euc_pre_in = image_pre.select(['sur_refl_b01', 'sur_refl_b02', 'sur_refl_b03', 'sur_refl_b04', 'sur_refl_b05', 'sur_refl_b06', 'sur_refl_b07'])
var euc_post_in = image_post.select(['sur_refl_b01', 'sur_refl_b02', 'sur_refl_b03', 'sur_refl_b04', 'sur_refl_b05', 'sur_refl_b06', 'sur_refl_b07'])

// Calculate euc distance sqrt(sum((pre-post)^2)
var diff_euc = euc_post_in.subtract(euc_pre_in)
var diff_euc_sq = diff_euc.multiply(diff_euc)

// Define function that sums bands pixelwise
var SUMIT = function(image) {
  return image.expression('(b("sur_refl_b01")+b("sur_refl_b02")+b("sur_refl_b03")+b("sur_refl_b04")+b("sur_refl_b05")+b("sur_refl_b06")+b("sur_refl_b07")  )');
};


// Calculate the sqrt of the sum and apply flag mask
var euc_pre_out = SUMIT(diff_euc_sq).sqrt().mask(maskNDVI_pre)
print(diff_euc_sq.getInfo())

Map.addLayer(euc_pre_out, {min: -300, max: 300,palette:palette }, 'euc_pre_out');



////////////////////////////////////////////////////////
// DOWNLOAD DATA 


// This displays a link containing the URL of the image to download.
// get bounding box
print( Nepal2.bounds() )
//print(Nepal.coordinates())
var path = ndvi_difference.getDownloadURL({
  'scale': 30,
  'crs': 'EPSG:4326',
   'region': '[  [84.605712890625,27.46928747369202],[85.5340576171875,27.249746156836583],[85.9405517578125,28.008951712550974],[85.023193359375,28.22697003891834],[84.605712890625,27.46928747369202] ]'
});
print(path);

var path = euc_pre_out.getDownloadURL({
  'scale': 30,
  'crs': 'EPSG:4326',
   'region': '[ [84.605712890625,27.46928747369202],[85.5340576171875,27.249746156836583],[85.9405517578125,28.008951712550974],[85.023193359375,28.22697003891834],[84.605712890625,27.46928747369202] ]'
});
print(path);
