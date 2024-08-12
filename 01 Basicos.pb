;Programa simple para llevar control de empleados y guardar los datos en un base de datos SQL
;Conectarse a una base de datos y crear una tabla
;guardar datos en la tabla
;busqueda en la base de datos por apellido
;Rodry Ramirez (c) 2024
;rodrymza@gmail.com

Enumeration
  #guardar
  #dni
  #surname
  #name
  #age
  #salary
  #database
  #ventana_lista
  #lista_empleados
  #ventana_principal
  #boton_agregar_empleado
  #boton_ver_lista
  #ventana_anadir
  #boton_buscar
EndEnumeration
table_name.s="empleados"
dbname.s="rodry_datos"
Global database_name.s="host=localhost port=3306 dbname=" + dbname, codigo_lista.s="parametro vacio"
Procedure guardar()
  dni=Val(GetGadgetText(#dni))
  surname.s=GetGadgetText(#surname)
  name.s=GetGadgetText(#name)
  age=Val(GetGadgetText(#age))
  salary=Val(GetGadgetText(#salary))
  If OpenDatabase(#database,database_name,"rodry","jcmc1719")
    DatabaseUpdate(#database,"INSERT INTO empleados (dni, surname, name, age, salary)  VALUES (" + dni + ", '" + surname + "', '" + name + "', " + age + ", " + salary + ")")
    MessageRequester("Exito","Empleado añadido a la base de datos")
    For i=1 To 5
      SetGadgetText(i,"")
    Next
    
  Else
    MessageRequester("Error","No se pudo agregar el empleado")
  EndIf
  
EndProcedure

Procedure anadir_empleado()
OpenWindow(#ventana_anadir, 0, 0, 310, 340, "", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
TextGadget(#PB_Any, 70, 20, 160, 25, "Añadir empleado", #PB_Text_Center)
TextGadget(#PB_Any, 40, 60, 70, 25, "DNI")
TextGadget(#PB_Any, 40, 100, 70, 25, "Apellido")
TextGadget(#PB_Any, 40, 140, 70, 25, "Nombre")
TextGadget(#PB_Any, 40, 180, 70, 25, "Edad")
TextGadget(#PB_Any, 40, 220, 70, 25, "Sueldo")
StringGadget(#dni, 120, 60, 140, 25, "")
StringGadget(#surname, 120, 100, 140, 25, "")
StringGadget(#name, 120, 140, 140, 25, "")
StringGadget(#age, 120, 180, 140, 25, "")
StringGadget(#salary, 120, 220, 140, 25, "")
ButtonGadget(#guardar, 90, 280, 120, 25, "Guardar")


Repeat 
  event = WindowEvent()
  
  If event= #PB_Event_Gadget And EventGadget()=#guardar
    guardar()
  EndIf 
    If event= #PB_Event_CloseWindow : CloseWindow(#ventana_anadir) : EndIf  
  Until event=#PB_Event_CloseWindow
EndProcedure

Procedure lista_empleados(busqueda.s)
  OpenWindow(#ventana_lista, 0, 0, 420, 400, "Consulta Empleados", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  ListIconGadget(#lista_empleados, 10, 60, 400, 330, "DNI", 80)
  AddGadgetColumn(#lista_empleados, 1, "Apellido", 100)
  AddGadgetColumn(#lista_empleados, 2, "Nombre", 100)
  AddGadgetColumn(#lista_empleados, 3, "Edad", 35)
  AddGadgetColumn(#lista_empleados, 4, "Sueldo", 100)
  TextGadget(#PB_Any, 50, 20, 330, 25, "Lista de empleados", #PB_Text_Center)
  
  If OpenDatabase(#database,database_name,"rodry","jcmc1719")
    If busqueda=codigo_lista
      DatabaseQuery(#database,"SELECT * FROM empleados ORDER BY surname")
    Else
      DatabaseQuery(#database,"SELECT * FROM empleados WHERE surname ='" + busqueda + "'")
    EndIf 
    
    While NextDatabaseRow(#database)
      AddGadgetItem(#lista_empleados,-1,Str(GetDatabaseLong(#database,0)) + Chr(10) + GetDatabaseString(#database,1) + Chr(10) + GetDatabaseString(#database,2) + Chr(10) + Str(GetDatabaseLong(#database,3)) + Chr(10) + Str(GetDatabaseLong(#database,4)))
    Wend  
  EndIf 
  
  Repeat 
    event = WindowEvent()
    
    If event= #PB_Event_CloseWindow 
      CloseWindow(#ventana_lista) 
    EndIf 
  Until event=#PB_Event_CloseWindow
EndProcedure

UseMySQLDatabase()




  OpenWindow(#ventana_principal, 0, 0, 310, 250, "Gestion de Empleados", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget(#PB_Any, 50, 20, 220, 25, "Gestion de Empledos MySQL", #PB_Text_Center)
  ButtonGadget(#boton_agregar_empleado, 80, 70, 160, 25, "Agregar Empleado")
  ButtonGadget(#boton_ver_lista, 80, 120, 160, 25, "Ver Lista Empleados")
  ButtonGadget(#boton_buscar, 80, 170, 160, 25, "Buscar Empleado")

  If OpenDatabase(#database,database_name,"rodry","jcmc1719")
    MessageRequester("Exito","Conectado a la base de datos " + dbname)
    If DatabaseUpdate(#database,"CREATE TABLE empleados (dni INT, surname VARCHAR(45), name varchar(45), age int, salary int, PRIMARY KEY (dni))")
      MessageRequester("Atencion","Se creo la tabla 'empleados' en la base de datos")
      CloseDatabase(#database)
         
    EndIf
  EndIf
  Repeat 
    event = WindowEvent()
    Select Event
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #boton_agregar_empleado
            anadir_empleado()
          Case #boton_ver_lista
            lista_empleados(codigo_lista)
          Case #boton_buscar
            lista_empleados(InputRequester("Buscar empleado","Ingrese apellido del empleado a buscar",""))
        EndSelect
    EndSelect
  Until event=#PB_Event_CloseWindow
