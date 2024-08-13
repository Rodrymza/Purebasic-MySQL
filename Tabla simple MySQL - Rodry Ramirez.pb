;Tabla simple de clientes con dni, apellido y nombre guardados en una base de datos
;ordenar por los diferentes campos
;Rodry Ramirez (c) 2024

Enumeration
  #ventana_principal
  #basedatos
  #lista_vista
  #dni
  #apellido
  #nombre
  #boton_guardar
  #debug_lista
  #combo_filtro
  #boton_modificar
  #boton_eliminar
  #ventana_modificar
  #dni_modificar
  #apellido_modificar
  #nombre_modificar
  #boton_guardar_modificar
EndEnumeration


Structure datos
  nombre.s
  apellido.s
EndStructure

NewMap clientes.datos() ; clientes guardados en un diccionario para que la clave-valor sea el dni

name.s="nombre"
surname.s="apellido"
id.s="dni"
Global dbname.s="rodry_datos", user.s="rodry", pass.s="rodry1234", tabla.s="clientes" ;variables para nombre de tabla, base de datos, usuario y contraseña

UseMySQLDatabase()

Procedure conectar_database(bdd) ; procedimiento para conectar a la base de datos
  If OpenDatabase(bdd,"host=localhost port=3306 dbname=" + dbname, user, pass)
  EndIf
EndProcedure

Procedure leer_bdd(Map lista.datos(),orden.s) ; procedimiento para leer la base de datos y asignar los valores al diccionario, a la vez se ordenan los datos segun la variable orden
  ClearGadgetItems(#lista_vista)
  conectar_database(#basedatos)
  DatabaseQuery(#basedatos,"SELECT * from " + tabla + " ORDER BY " + orden + " ASC") ; se traen todos los datos de la bdd
  While NextDatabaseRow(#basedatos)
    AddMapElement(lista(),GetDatabaseString(#basedatos,0))  ; el primer elemento es el mapkey
    lista()\apellido=GetDatabaseString(#basedatos,1)        ; los dos siguientes son el apellido y el nombre, siguiendo el mismo esquema tanto en la bdd como en el programa
    lista()\nombre=GetDatabaseString(#basedatos,2)
    AddGadgetItem(#lista_vista,-1,MapKey(lista()) + Chr(10) + lista()\apellido + Chr(10) + lista()\nombre)
  Wend
  FinishDatabaseQuery(#basedatos)
  CloseDatabase(#basedatos)
EndProcedure

Procedure modificar_valores(Map lista.datos(),valor.s)
  valor="'" + valor + "'"
  OpenWindow(#ventana_modificar, 0, 0, 340, 210, "Modificar ficha actual", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget(#PB_Any, 50, 20, 230, 25, "Modificar valores", #PB_Text_Center)
  TextGadget(#PB_Any, 30, 70, 70, 25, "DNI")
  TextGadget(#PB_Any, 30, 100, 70, 25, "Apellido")
  TextGadget(#PB_Any, 30, 130, 70, 25, "Nombre")
  StringGadget(#dni_modificar, 110, 70, 130, 25, "")
  StringGadget(#apellido_modificar, 110, 100, 130, 25, "")
  StringGadget(#nombre_modificar, 110, 130, 130, 25, "")
  ButtonGadget(#boton_guardar_modificar, 180, 170, 100, 25, "Guardar")
  
  OpenDatabase(#basedatos,"host=localhost port=3306 dbname=" + dbname, user, pass)
  If  DatabaseQuery(#basedatos,"SELECT * FROM clientes WHERE dni=" + valor)
    NextDatabaseRow(#basedatos)
    SetGadgetText(#dni_modificar,GetDatabaseString(#basedatos,0))
    SetGadgetText(#apellido_modificar,GetDatabaseString(#basedatos,1))
    SetGadgetText(#nombre_modificar,GetDatabaseString(#basedatos,2))
    CloseDatabase(#basedatos)
  Else
    Debug "error" + DatabaseError()
  EndIf 
  
  Repeat
    event= WindowEvent()
    Select event
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #boton_guardar_modificar
            conectar_database(#basedatos)
            If DatabaseUpdate(#basedatos,"UPDATE " + tabla + " SET dni='" + GetGadgetText(#dni_modificar) + "', apellido='" + GetGadgetText(#apellido_modificar) + "', nombre='" + GetGadgetText(#nombre_modificar) + "' WHERE dni=" + valor)
              leer_bdd(lista(),GetGadgetText(#combo_filtro))
              MessageRequester("Atencion","Datos actualizados")
            Else
              MessageRequester("Error",DatabaseError())
            EndIf
            
        EndSelect
      Case #PB_Event_CloseWindow
        CloseWindow(#ventana_modificar)
    EndSelect
    Until event=#PB_Event_CloseWindow
EndProcedure

Procedure eliminar_elemento(Map lista.datos(),valor.s)
  conectar_database(#basedatos)
   result=MessageRequester("Atencion","Se borrra el elemento con dni:" + valor,#PB_MessageRequester_YesNo)
   If result=#PB_MessageRequester_Yes
   If DatabaseUpdate(#basedatos,"DELETE FROM " + tabla + " WHERE dni='" + valor + "'")
      MessageRequester("Atencion","Se borro el cliente seleccionado")
      DeleteMapElement(lista(),valor)
    Else 
      Debug DatabaseError()
    EndIf 
    CloseDatabase(#basedatos)
    leer_bdd(lista(),GetGadgetText(#combo_filtro))
  EndIf  
EndProcedure

OpenWindow(#ventana_principal, 0, 0, 470, 570, "Lista de Clientes en base de datos", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
CreateMenu(#PB_Any,WindowID(#ventana_principal))
MenuTitle("Archivo")
MenuItem(#debug_lista,"Listar clientes")
TextGadget(#PB_Any, 0, 10, 470, 25, "Lista Clientes", #PB_Text_Center)
ListIconGadget(#lista_vista, 10, 80, 450, 310, "DNI", 100,#PB_ListIcon_FullRowSelect)
TextGadget(#PB_Any, 30, 50, 100, 25, "Ordenar por:")
ComboBoxGadget(#combo_filtro, 140, 50, 120, 25)
AddGadgetItem(#combo_filtro,-1,"Apellido")
AddGadgetItem(#combo_filtro,-1,"Nombre")
AddGadgetItem(#combo_filtro,-1,"DNI")
SetGadgetState(#combo_filtro,0)
AddGadgetColumn(#lista_vista, 1, "Apellido", 160)
AddGadgetColumn(#lista_vista, 2, "Nombre", 160)
TextGadget(#PB_Any, 60, 400, 100, 25, "DNI:")
TextGadget(#PB_Any, 60, 430, 100, 25, "Apellido:")
TextGadget(#PB_Any, 60, 460, 100, 25, "Nombre:")
StringGadget(#dni, 160, 395, 170, 25, "")
StringGadget(#apellido, 160, 425, 170, 25, "")
StringGadget(#nombre, 160, 455, 170, 25, "")
ButtonGadget(#boton_guardar, 320, 510, 130, 25, "Guardar")
ButtonGadget(#boton_modificar, 170, 510, 130, 25, "Modificar selec")
ButtonGadget(#boton_eliminar, 20, 510, 130, 25, "Eliminar")

conectar_database(#basedatos)
If DatabaseUpdate(#basedatos,"CREATE TABLE " + tabla +  " (dni VARCHAR(45), apellido VARCHAR(45), nombre VARCHAR(45), PRIMARY KEY(dni))")
  MessageRequester("Atencion","Tabla creada")
Else
  MessageRequester("Atencion","La tabla ya existe")
  
EndIf 

leer_bdd(clientes(),LCase(GetGadgetText(#combo_filtro)))

Repeat
  event=WindowEvent()
  Select event 
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #boton_guardar
          If Not FindMapElement(clientes(),GetGadgetText(#dni))
            AddMapElement(clientes(),GetGadgetText(#dni))
            clientes()\apellido=GetGadgetText(#apellido)
            clientes()\nombre=GetGadgetText(#nombre)
            conectar_database(#basedatos)
            aux_sql.s="VALUES ('" + GetGadgetText(#dni) + "', '" + GetGadgetText(#apellido) + "', '" + GetGadgetText(#nombre) + "')"
            If DatabaseUpdate(#basedatos,"INSERT INTO clientes (dni, apellido, nombre) "+ aux_sql)
              MessageRequester("Exito","Guardado en la base de datos")
              CloseDatabase(#basedatos)
            Else
              MessageRequester("Error","No se pudo guardar en la base de datos")
            EndIf 
          Else
            MessageRequester("Error","Ya existe un cliente con el dni ingresado")
          EndIf 
          leer_bdd(clientes(),LCase(GetGadgetText(#combo_filtro)))
        Case #combo_filtro
          leer_bdd(clientes(),LCase(GetGadgetText(#combo_filtro)))
        Case #boton_modificar
          modificar_valores(clientes(),GetGadgetText(#lista_vista))
        Case #boton_eliminar
          eliminar_elemento(clientes(),GetGadgetText(#lista_vista))
          
      EndSelect
    Case #PB_Event_Menu
      Select EventMenu()
        Case #debug_lista
          ForEach clientes()
            Debug MapKey(clientes()) + " - " +  clientes()\apellido + ", " + clientes()\nombre
          Next
          
      EndSelect
  EndSelect
Until event=#PB_Event_CloseWindow
