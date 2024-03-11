# SS2 - Proyecto Fase 1 - 202010055

## Fases ETL

### Eliminar

Lo primero que se hace es eliminar los datos de las tablas temporales y del datawarehouse.
![eliminar](/images/eliminar.png)

### Carga Temporales

Luego se pasa a cargar los datos en las temporales.

Primero se pasa a cargas las variables:

```C#
string Delimitador = Dts.Variables["User::Delimitador"].Value.ToString();
string ExtensionVentas = Dts.Variables["User::ExtensionVentas"].Value.ToString();
string ExtensionCompras = Dts.Variables["User::ExtensionCompras"].Value.ToString();
string FolderOrigen = Dts.Variables["User::OrigenMySQL"].Value.ToString();
string TablaCompras = Dts.Variables["User::TablaCompras"].Value.ToString();
string TablaVentas = Dts.Variables["User::TablaVentas"].Value.ToString();
```

Luego utilizamos `getFiles` para leer los archivos de datos:

```C#
string[] fileentriesCompras = Directory.GetFiles(FolderOrigen, "*" + ExtensionCompras);
string[] fileentriesVentas = Directory.GetFiles(FolderOrigen, "*" + ExtensionVentas);
```

Una vez leidos los datos se pasa a crear la conexión con la base de datos:

```C#
string cadenaConecion = "Server=localhost; Database=proyecto1; Uid=root; Pwd=<<pass>>;" +
        "port=3306";

MySqlConnection connection = new MySqlConnection(cadenaConecion);
connection.Open();
```

Ahora se pasa a leer los datos de los archivos, esto se hace leyendo linea por linea:

```C#
string linea;

System.IO.StreamReader SourceFile = new System.IO.StreamReader(filename);

while ((linea = SourceFile.ReadLine()) != null)
{
 ...
}

```

Una vez leida la linea, se pasa a separar los campos y a cargarlos a la base de datos:

```C#
string[] campos = linea.Split(Delimitador.ToCharArray()[0]);

string query = "INSERT INTO " + TablaCompras +
    "(Fecha, CodProveedor, NombreProveedor, DireccionProveedor, NumeroProveedor, WebProveedor, CodProducto, NombreProducto, MarcaProducto, Categoria, SodSuSursal, NombreSucursal, DireccionSucursal, Region, Departamento, Unidades, CostoU)" +
    "VALUES" +
    "(@Fecha, @CodProveedor, @NombreProveedor, @DireccionProveedor, @NumeroProveedor, @WebProveedor, @CodProducto, @NombreProducto, @MarcaProducto, @Categoria, @SodSuSursal, @NombreSucursal, @DireccionSucursal, @Region, @Departamento, @Unidades, @CostoU);";

using (MySqlCommand myCommand = new MySqlCommand(query, connection))
{
    myCommand.Parameters.AddWithValue("@Fecha", campos[0]);
    myCommand.Parameters.AddWithValue("@CodProveedor", campos[1]);
    myCommand.Parameters.AddWithValue("@NombreProveedor", campos[2]);
    myCommand.Parameters.AddWithValue("@DireccionProveedor", campos[3]);
    myCommand.Parameters.AddWithValue("@NumeroProveedor", campos[4]);
    myCommand.Parameters.AddWithValue("@WebProveedor", campos[5]);
    myCommand.Parameters.AddWithValue("@CodProducto", campos[6]);
    myCommand.Parameters.AddWithValue("@NombreProducto", campos[7]);
    myCommand.Parameters.AddWithValue("@MarcaProducto", campos[8]);
    myCommand.Parameters.AddWithValue("@Categoria", campos[9]);
    myCommand.Parameters.AddWithValue("@SodSuSursal", campos[10]);
    myCommand.Parameters.AddWithValue("@NombreSucursal", campos[11]);
    myCommand.Parameters.AddWithValue("@DireccionSucursal", campos[12]);
    myCommand.Parameters.AddWithValue("@Region", campos[13]);
    myCommand.Parameters.AddWithValue("@Departamento", campos[14]);
    myCommand.Parameters.AddWithValue("@Unidades", campos[15]);
    myCommand.Parameters.AddWithValue("@CostoU", campos[16]);

    myCommand.ExecuteNonQuery();
}
```

Esto se repite por todas las lineas y todos los archivos.

### Transformación de datos

Para iniciar la transformación de datos primero cargamos todos los datos las tablas temporales y se unen todos.

![carga1](/images/carga.png)

La carga de cada base de datos se realiza por medio de una fuente de ADO.NET, en este caso como es MySQL y MariaDB es necesario realizarlo por medio de un SELECT:

![modelodb](/images/carga_db.png)

Una vez se han unido los datos de las tres fuentes se pasan a convertir los datos, en este caso es necesario convertir la fecha al tipo de datos DATE, convertir el numero del proveedor y las unidades a integer y pasar el costo a decimales.

![conversion](/images/conversion.png)

Para eliminar los datos con errores se utiliza una columna derivada para filtrar los datos que nos seran utiles y cuales no.

![modelo](/images/c_derivada.png)

En este caso se eliminaran las tuplas con valores NULL.

Ahora realizamos un split condicional, este funciona comno un IF que nos permitirá separar la informacion, en este caso queremos separar los datos validos de los no validos.

![modelo](/images/split.png)

Por ultimo se realiza un sort, esto ademas de ordenar los datos nos permite seleccionar solo las columnas que necesitamos cargar para una tabla en especifico y eliminar repetidos.

![modelo](/images/sort.png)

Aqui terminaria el proceso de transformacion para casi todas las tablas, sin embargo, algunas tablas contienen llaves foraneas de otras tablas, por lo que es necesario realizar un join.

Este se hace cuando una tabla ya ha sido cargada a la base de datos y se desea obtener las llaves primarias que le asigno la base de datos. Por lo que aqui extraemos los datos de esa tabla y realizamos un Merge Join

![modelo](/images/join.png)

Esto nos permite realizar una union de tuplas de dos fuentes tomando un valor comun. En este ejemplo se estan cargando las categorias en la tabla 'Productos', por lo que se toma como valor comun el nombre de la categoria. Luego en la tabla resultado queremos obtener todos los valores del producto, pero en lugar de tener el nombre de la categoria queremos reemplazarla con la llave foranea de este valor en la tabla 'Categoria'

### Carga

Una vez se han transformado los datos se pasa a hacer la carga. Primero se selecciona la base de datos donde se hará la carga y la columna donde se guardará.

![modelo](/images/carga_into_db.png)

Luego tomando en cuenta los datos disponibles se mapean con las columnas correspondientes en la base de datos y se procede a cargar los datos.

![modelo](/images/map.png)

## Modelo

![modelo](/images/modelo.png)

Para el modelo del datawarehouse se decidio utilizar un modelo constelacion, ya que son necesarias dos tablas de hechos: compras y ventas.

Estas tablas de hechos se conectan con las sigueines dimensiones:

- Fecha: Esta tabla contiene los datos relacionados al tiempo del hecho (año, mes, dia)
- Proveedor: Contiene los datos del proovedor al que se le compraron los productos.
- Cliente: Contiene los datos del cliente al cual se le hizo la venta.
- Producto: Contiene los datos del producto.
  - Marca: Marca del producto.
  - Categoria: Categoria a la que pertenece el producto.
- Vendedor: Informacion del vendedor que efectuo la venta.
- Sucursal: Sucursal donde se realizo la compra o venta.
  - Region: Region donde se encuentra ls sucursal
  - Depertamento: Departamento donde se encuentra el sucursal.

Asi mismo, el datawarehouse cuenta con 4 metricas

- Unidades (Compra): Cantidad de productos que se compraron
- CostoU: Costo unitario al que se compraron los productos
- Unidades (Ventas): Cantidad de productos que se vendieron
- PrecioUnitario: Precio unitario al que se vendio cada producto
