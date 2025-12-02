# Server setup

The Kensis server has multiple components:

- a [postgres](./postgres/) database server 
- a NGINX service hosting the [kensis website](./cms/) (port 80/443)
- a [mapserver](./mapserver/) instance providing access to various data files (mapped to path /ows)
- a [terria-js](./terriajs/) instance for advanced map viewing options (mapped to path /maps)