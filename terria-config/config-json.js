{
  /* Names of init files (in wwwroot/init), without the .json extension, to load by default */
  "initializationUrls": [
    "simple"
  ], 
  "parameters": {
    "googleUrlShortenerKey": null,
    "googleAnalyticsKey": null,
    "googleAnalyticsOptions": null,
    "cesiumIonAccessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIwZGNjYjdlMi01OWQ3LTQ3NTgtYWYyNC1mNGI2NWJmMGFjYzIiLCJpZCI6MTkzMDcwLCJpYXQiOjE3MDY2OTE2Mzl9.tEQfMX912pnQUJcBfvAuZxNKhNLWolwclypDMCJ4MoM",
    // Log ConsoleAnalytics events to console
    // logToConsole: true,
    /* Text that appears at the bottom of the map */
    "disclaimer": {
      "text": "Disclaimer: This map must not be used for navigation or precise spatial analysis",
      "url": ""
    },
    "developerAttribution": {
      "text": "Kalro ICT",
      "link": "https://github.com/KALRO-ICT"
    },
    // This is used in various text messages. You should also set <title> in index.html
    "appName": "LSC",
    // See comments in lib/Views/global.scss for further information about customising colors, logos, fonts etc.
    "brandBarElements": [
    ],
    // Shown when things go wrong.
    "supportEmail": "info@example.com",
    // You probably shouldn't change this.
    "proj4ServiceBaseUrl": "",
    "relatedMaps": [
    ],
    // Default mobile viewer mode when loading the map for the first time on mobile platforms.
    // Options are: "3DTerrain", "3DSmooth", "2D"
    "mobileDefaultViewerMode": "2d",
    // Enable experimental features, since its nice to have the bleeding edge.
    // Disable it if things go wrong with the experimental features or your users aren't robust to features which might change or disapear completly.
    "experimentalFeatures": true,
    // To enable welcome message when map first loads
    // "showWelcomeMessage": true,
    // To override the welcome message video displayed on the welcome message
    // By default, the Getting Started to Terria video is displayed
    // "welcomeMessageVideo": {
    //     "videoTitle": "Getting started with the map",
    //     "videoUrl": "https://www.youtube-nocookie.com/embed/NTtSM70rIvI", // use an embedded video link
    //     "placeholderImage": "https://img.youtube.com/vi/NTtSM70rIvI/maxresdefault.jpg"
    // },
    // True to display in-app guides.
    // "showInAppGuides": false,
    // see `languageOverrides.json` in languages/en
    "languageConfiguration": {
      "enabled": false,
      "debug": false,
      "languages": {
        "en": "English",
        "fr": "Français"
      },
      "fallbackLanguage": "en"
    },
    "searchBarConfig": {},
    "searchProviders": [
      {
        "id": "search-provider/cesium-ion",
        "type": "cesium-ion-search-provider",
        "name": "translate#viewModels.searchLocations",
        "url": "https://api.cesium.com/v1/geocode/search/",
        "flightDurationSeconds": 1.5,
        "minCharacters": 5,
        "isOpen": true
      }
    ],
    "helpContent": [
      {
        "title": "translate#gettingstarted.title",
        "itemName": "gettingstarted",
        "paneMode": "videoAndContent",
        "markdownText": "translate#gettingstarted.markdownText",
        "icon": "video",
        "videoUrl": "translate#gettingstarted.videoUrl",
        "placeholderImage": "translate#gettingstarted.placeholderImage"
      },
      {
        "title": "translate#stepbystepguide.title",
        "itemName": "stepbystepguide",
        "paneMode": "trainer",
        "markdownText": "translate#stepbystepguide.markdownText",
        "icon": "oneTwoThree",
        "trainerItems": [
          {
            "title": "translate#stepbystepguide.gettingstarted.title",
            "footnote": "translate#stepbystepguide.gettingstarted.footnote",
            "steps": [
              {
                "title": "translate#stepbystepguide.gettingstarted.step1.title",
                "markdownDescription": "translate#stepbystepguide.gettingstarted.step1.markdownDescription"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step2.title",
                "markdownDescription": "translate#stepbystepguide.gettingstarted.step2.markdownDescription"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step3.title",
                "markdownDescription": "translate#stepbystepguide.gettingstarted.step3.markdownDescription"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step4.title"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step5.title"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step6.title"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step7.title"
              },
              {
                "title": "translate#stepbystepguide.gettingstarted.step8.title"
              }
            ]
          }
        ]
      },
      {
        "icon": "story",
        "itemName": "storymigration",
        "markdownText": "## Share & Story Migration\n\n### Guide on updating share links, including stories\n\nIf you've received a warning telling you that a share link was based off an older version of TerriaJS, you'll want to do a few things to recreate them in the latest version of Terria!\n\n#### Creators\n\n1. Identify the share URL which causes a notification of share preservation effort when loading them into Terria. e.g. you may know where they are embedded, or come across them accidentally\n2. Open them in the newer (v8) based map application \n3. Check that everything is sharing as you expect, tweak the layers to fit if some are missing or not behaving correctly.\n4. Update the share link by clicking the Share/Print button and copy the new link\n5. If distribution of share link is known, update the url in your web page (if embedded), or send the new link to users \n\n#### Consumers\n1. Load the share URL\n2. If it doesn't quite look right, notify the provider so they can follow the above steps to recreate it in the latest version of Terria",
        "title": "Share & Story migration"
      }
      // For maps with satellite imagery, also see `showInAppGuides`
      // {
      //     "itemName": "satelliteimagery",
      //     "title": "Satellite Imagery",
      //     "paneMode": "slider",
      //     "icon": "satellite"
      // }
    ],
    "viewerMode": "2d",
    "baseMaps": {
      "defaultBaseMapId": "basemap-nasa-moon",
      "previewBaseMapId": "basemap-nasa-moon"
    },
    "helpContentTerms": [
      {
        "term": "translate#helpContentTerm1.term",
        "aliases": "translate#helpContentTerm1.aliases",
        "content": "translate#helpContentTerm1.content"
      },
      {
        "term": "translate#helpContentTerm2.term",
        "aliases": "translate#helpContentTerm2.aliases",
        "content": "translate#helpContentTerm1.content"
      },
      {
        "term": "translate#helpContentTerm3.term",
        "content": "translate#helpContentTerm3.content"
      },
      {
        "term": "translate#helpContentTerm4.term",
        "content": "translate#helpContentTerm4.content"
      },
      {
        "term": "translate#helpContentTerm5.term",
        "aliases": [
          "catalogue"
        ],
        "content": "translate#helpContentTerm5.content"
      },
      {
        "term": "translate#helpContentTerm6.term",
        "aliases": "translate#helpContentTerm6.aliases",
        "content": "translate#helpContentTerm6.content"
      },
      {
        "term": "translate#helpContentTerm7.term",
        "content": "translate#helpContentTerm7.content"
      },
      {
        "term": "translate#helpContentTerm8.term",
        "content": "translate#helpContentTerm8.content"
      }
    ]
  }
}