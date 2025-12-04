// script loads an openlayers map into a div#map 

const osmLayer = new ol.layer.Tile({
  source: new ol.source.OSM(),
  title: 'OpenStreetMap',
  type: 'base'
});

const map = new ol.Map({
  target: 'map',
  layers: [osmLayer],
  view: new ol.View({
    center: ol.proj.fromLonLat([38,0]),
    zoom: 8
  })
});

// LayerSwitcher control
const layerSwitcher = new ol.control.LayerSwitcher({tipLabel:'Layers'});
map.addControl(layerSwitcher);

let cogLayers = []; // {layer, data, width, height, extent, title}

// Load and colorize a TIFF layer with custom min/max
async function createCOGLayer(fileName, title, minVal, maxVal) {
  const tiff = await GeoTIFF.fromUrl(fileName);
  const image = await tiff.getImage();
  const width = image.getWidth();
  const height = image.getHeight();
  const bbox = image.getBoundingBox() || [3766444.016, -533262.071, 4674893.445, 608302.686];
  const data = await image.readRasters({ interleave:true });

  const canvas = document.createElement('canvas');
  canvas.width = width; canvas.height = height;
  const ctx = canvas.getContext('2d');
  const imgData = ctx.createImageData(width,height);
  const out = imgData.data;

  // 8-class color palette
  const palette=[[255,255,178],[254,204,92],[253,141,60],[240,59,32],
                 [189,0,38],[128,0,38],[77,0,75],[26,0,54]];
  const n=palette.length, step=(maxVal-minVal)/n;

  for(let i=0,p=0;i<data.length;i++,p+=4){
    const v=data[i];
    if(v===undefined||v===null||Number.isNaN(v)||v<minVal||v>maxVal){ out[p+3]=0; continue; }
    let idx=Math.floor((v-minVal)/step); if(idx<0) idx=0; if(idx>=n) idx=n-1;
    const c = palette[idx];
    out[p]=c[0]; out[p+1]=c[1]; out[p+2]=c[2]; out[p+3]=255;
  }

  ctx.putImageData(imgData,0,0);
  const dataUrl = canvas.toDataURL();

  const layer = new ol.layer.Image({
    source: new ol.source.ImageStatic({
      url: dataUrl,
      imageExtent: bbox,
      projection: 'EPSG:3857'
    }),
    title: title,
    visible: false,
    opacity: 0.85
  });

  map.addLayer(layer);
  cogLayers.push({layer, data, width, height, extent: bbox, title});
  return layer;
}

// Load all COG layers with their min/max ranges
async function loadCOGLayers() {
  await createCOGLayer('maps/SOC_Kenya_cog.tif','SOC', 0.280, 4.674);
  await createCOGLayer('maps/soilPH_Kenya_cog.tif','Soil pH', 4.292, 8.962);
  await createCOGLayer('maps/soilPhosphorus_Kenya_cog.tif','Phosphorus', 2.602, 72.610);
  await createCOGLayer('maps/soilPotassium_Kenya_cog.tif','Potassium', 10.809, 546.157);

  // show first layer by default (SOC)
  if(cogLayers.length>0) cogLayers[0].layer.setVisible(true);

  // zoom to first layer extent
  const extent = cogLayers[0].extent;
  map.getView().fit(extent,{size:map.getSize(),maxZoom:18,padding:[20,20,20,20]});
}

loadCOGLayers();

map.on('pointermove', function(evt){
  const coord = evt.coordinate;
  popup.style.display = 'none';
  const visibleLayer = cogLayers.find(l=>l.layer.getVisible());
  if(!visibleLayer) return;

  const {extent, width, height, data, title} = visibleLayer;
  const [minX,minY,maxX,maxY] = extent;
  const xPix = Math.floor((coord[0]-minX)/(maxX-minX)*width);
  const yPix = Math.floor((maxY-coord[1])/(maxY-minY)*height); // y inverted

  if(xPix<0||xPix>=width||yPix<0||yPix>=height) return;

  const idx = yPix*width + xPix;
  const value = data[idx];

  if(value===undefined||value===null||Number.isNaN(value)) return;

  // Position relative to map container
  const pixel = map.getPixelFromCoordinate(coord);
  popup.style.display = 'block';
  popup.style.left = pixel[0] + 10 + 'px';
  popup.style.top = pixel[1] + 10 + 'px';
  popup.innerHTML = `${title}: ${value.toFixed(2)}`;
});