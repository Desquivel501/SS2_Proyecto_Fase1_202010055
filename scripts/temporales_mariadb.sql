CREATE TABLE TemporalCompras(
    Fecha					varchar(100),
    CodProveedor			varchar(100),
    NombreProveedor			varchar(100),
    DireccionProveedor		varchar(255),
    NumeroProveedor			varchar(100),
    WebProveedor			varchar(100),
    CodProducto				varchar(100),
    NombreProducto			varchar(100),
    MarcaProducto			varchar(100),
    Categoria				varchar(100),
    SodSuSursal				varchar(100),
    NombreSucursal			varchar(100),
    DireccionSucursal		varchar(255),
    Region					varchar(100),
    Departamento			varchar(100),
    Unidades				varchar(100),
    CostoU					varchar(100)
);



CREATE TABLE TemporalVentas(
    Fecha				varchar(100),
    CodigoCliente		varchar(100),
    NombreCliente		varchar(100),
    TipoCliente			varchar(100),
    DireccionCliente	varchar(255),
    NumeroCliente		varchar(100),
    CodVendedor			varchar(100),
    NombreVendedor		varchar(100),
    Vacacionista		varchar(100),
    CodProducto			varchar(100),
    NombreProducto		varchar(100),
    MarcaProducto		varchar(100),
    Categoria			varchar(100),
    SodSuSursal			varchar(100),
    NombreSucursal		varchar(100),
    DireccionSucursal	varchar(255),
    Region				varchar(100),
    Departamento		varchar(100),
    Unidades			varchar(100),
    PrecioUnitario		varchar(100)
);