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
      Debug GetDatabaseString(#basedatos,1)

    AddMapElement(lista(),GetDatabaseString(#basedatos,0))  ; el primer elemento es el mapkey
    lista()\apellido=GetDatabaseString(#basedatos,1)        ; los dos siguientes son el apellido y el nombre, siguiendo el mismo esquema tanto en la bdd como en el programa
    lista()\nombre=GetDatabaseString(#basedatos,2)
    AddGadgetItem(#lista_vista,-1,MapKey(lista()) + Chr(10) + lista()\apellido + Chr(10) + lista()\nombre)
  Wend
  FinishDatabaseQuery(#basedatos)
  CloseDatabase(#basedatos)
EndProcedure




OpenWindow(#ventana_principal, 0, 0, 470, 570, "Lista de Clientes en base de datos", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
CreateMenu(#PB_Any,WindowID(#ventana_principal))
TextGadget(#PB_Any, 0, 10, 470, 25, "Lista Clientes", #PB_Text_Center)
ListIconGadget(#lista_vista, 10, 80, 450, 310, "DNI", 100)
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
ButtonGadget(#boton_guardar, 230, 510, 160, 25, "Guardar")

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
          Debug GetGadgetText(#combo_filtro)
          
      EndSelect
    Case #PB_Event_Menu
      Select EventMenu()
        Case #debug_lista
          ForEach clientes()
            Debug MapKey(clientes())
            Debug clientes()\apellido
          Next
          
      EndSelect
  EndSelect
Until event=#PB_Event_CloseWindow
; IDE Options = PureBasic 6.11 LTS (Windows - x64)
; CursorPosition = 36
; Folding = -
; EnableXP
; HideErrorLog