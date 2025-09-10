## DEFINICIONES

- Se publican los productos del catalog unicamente (no maestros, no variantes)
- Tenemos un token por store. El id del catalogo viene por parametro.
- El token no vence nunca, para invalidarlo hay que generar uno nuevo.
- Todos los servicios seran paginados. (definir max por pagina)


## ENDPOINTS

### Categorias

- __/api/v1/:catalog_id/categories__ -> Devuelve las categorias del catalogo.


### Brands

- __/api/v1/:catalog_id/brands__ -> Devuelve las brands que existen en el catalogo


### Productos

- __/api/v1/:catalog_id/products__ -> Devuelve productos del catalog (o busqueda)

#### Inputs:
- category_id
- brand_id
- q (algolia)
- order_by -> precio, nombre, marca
- order_sense -> asc, desc
- page
- per_page

- __/api/v1/:catalog_id/products/:id__ -> Devuelve un producto.

### Tag infos

- __/api/v1/:catalog_id/products/:product_id/tags__ -> Devuelve los "tag infos" de un producto.

### Reviews

- __/api/v1/:catalog_id/products/:id/reviews__ -> Devuelve las reviews de un producto.
