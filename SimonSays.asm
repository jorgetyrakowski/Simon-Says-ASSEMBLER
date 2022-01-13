.model small
.stack 200h
.data          
          
    ; [-AREGLOS-]          
    
    ; sentencias --> todas las sentencias del juego. 
    ; simon_dice --> almacena las setencias del juego. 
    ; respuestas --> almacena las respuestas del usuario.
    sentencias db 'cat0','ruby0','world0','poetry0','ability0','scientist0','loneliness0','electricity0','teleportation0','$' 
    simon_dice db 80 dup (0)   
    respuestas db 80 dup(0)   
    
    ; [-VARIABLES DE LAS CADENAS DE TEXTO QUE SE MOSTRARAN EN EL JUEGO-]   
    
    titulo db '[*****************************   SIMON SAYS   *********************************]', 13d, 10d,'$'                                      
    introduccion db ' Este juego te pondra a prueba...', 13d, 10d,' Veremos si eres capaz de memorizar las sentencias y posteriormente repetirlas.',13d, 10,'$'
    instrucciones db ' Existen 3 niveles, cada 3 sentencias pasaras al siguiente!',13d, 10d,' Si pierdes tres veces consecutivas estas fuera!',13d, 10,'$'   
    mensaje_tiempo db ' Al comienzo tendras 25 segundos para introducir las sentencias, cada vez que', 13d, 10d ,' avances de nivel tendras 2 segundos menos.',13d, 10,'$'
    mensaje_puntos db " [ Nivel 1 ]",13d, 10d,"- Por cada sentencia --> 2P",13d, 10d," [ Nivel 2 ]",13d, 10d,"- Por cada sentencia --> 4P",13d, 10d," [ Nivel 3 ]",13d, 10d,"- Por cada sentencia --> 6P$" 
    ready db 13d, 10d," Presiona una tecla para continuar: $"
    verificando db "Verificando sentencias..", 13d, 10d,'$'  
    continue db "Desea continuar jugando [Y o N ]: $" 
    correct db "BUEN TRABAJO, SENTENCIA CORRECTA.$"
    incorrect db "HAS FALLADO$"
    destiempo db "FUERA DE TIEMPO!$" 
    puntaje db "Has alcanzado un puntaje de: $"
    nivel_alcanzado db "Nivel: $"
    vidas_restantes db "Vidas restantes: $"
    mensaje_victoria db "CONGRATULACIONES! HAS GANADO EL JUEGO$"
    mensaje_derrota db "[ GAME OVER ]", 13d, 10d,'$'
    mensaje_aumento_nivel db " Bien hecho, has avanzado al nivel: $" 
    mensaje_dificultad db " Se ha aumentado la dificultad ;)$"
    
    ; [-VARIABLES DEL JUEGO-]    
    
    cont_sentencias db 0d,'$'
    nivel db 49d,'$'                    ; Representa el nivel en donde se encuentra el jugador.
    score db 0d,'$'                     ; Representa los puntos que obtiene el jugador.
    vidas db 3d,'$'                     ; Representa las vidas del jugador.    
    puntos_por_nivel db 2d,'$'          ; Representa el puntaje otorgado por cada sentencia correcta.          
    cont_sentencias_por_nivel db 0d,'$' ; Representa en que sentencia del nivel se encuentra el jugador.
    linebreak db 13d, 10d,"$"           ; Salto de Linea 
    retardo db 25d, '$'                 ; Numeros de espacios que retardaran para mostrar las sentencias al usuario.
    color db 0d, '$'                    ; Representa el color que tendra el texto.
                         
    ; [-VARIABLES PARA REALIZAR EL CALCULAR LA DEMORA DEL JUGADOR AL INTRODUCIR LAS SENTENCIAS-] 
                                 
    minuto_inicial db 0d, '$'           ; Minuto en el que el jugador comienza a introducir la sentencia.
    segundo_inicial db 0d, '$'          ; Segundo en el que el jugador comienza a introducir la sentencia.
    minuto_final db 0d, '$'             ; Minuto en el que el jugador termina de introducir la sentenica.
    segundo_final db 0d, '$'            ; Segundo en el que el jugador termina de introducir la sentenica.
    demora db 0d, '$'                   ; Los segundos que el jugador demora introduciendo la sentencia.
    tiempo_limite db 25d, '$'           ; El limite de segundos que el jugador tiene para introducir la sentencia.
                                                                                                                                                         
.code
start: 
 
    mov ax, @data
    mov ds, ax     
    mov SI, 0d             
    mov bx, offset sentencias           ; Utilizamos bx para el direccionamiento indirecto del arreglo de sentencias.
     
    call game
    
;------------------------------------ 
   
    game:                 
        call imprimir_introduccion     ; Muestra la introduccion al usuario.
    start_game:
        call preparar_sentencias        ; Prepara las sentencias que se mostraran al usuario.
    checkpoint: 
        call imprimir_titulo            ; Imprime el titulo del juego.
        call mostrar_sentencias         ; Muestra las sentencias que el usuario debe repetir.
        call breakline                  ; Realiza un salto de linea.
        call timer                      ; Espera un momento para que el usuario memorice las sentencias.
        call clean_screen               ; Limpia la pantalla.
        call imprimir_titulo            ; Imprime el titulo del juego.
        call comenzar_cuenta            ; Comienza la cuenta de demora al introducir las sentencias.
        call get_str                    ; Pide al usuario las sentencias.
        call terminar_cuenta            ; Termina la cuenta de demora al introducir las sentencias.
        call clean_screen               ; Limpia la pantalla.
        call verificar                  ; Verifica si las sentencias son correctas.
        jmp start_game:                 ; Salta al comienzo del juego.
        
;------------------------------------
                           
    victoria:           ; Muestra el mensaje de Victoria, los puntos alcanzados por el jugador y finaliza el juego. 
        call clean_screen
        mov color, 0eh                  ; Cambiamos el color a amarillo | 0E --> Representa el color amarillo. 
        call cambiar_color
        mov ax, offset mensaje_victoria ; Mueve a ax el mensaje de victoria.
        call puts                       ; Muestra el mensaje.
        call breakline                  ; Realiza un salto de linea.
        mov ax, offset puntaje          ; Mueve a ax el mensaje del score.
        call puts                       ; Muestra el mensaje.
        mov al, score                   ; Mueve a ax el mensaje que contiene el score.
        call mostrar_num_dos_digitos    ; Muestra el score.  
        call fin                        ; FINALIZA EL JUEGO.
        
;------------------------------------ 
                                      
    game_over:          ; Muestra el mensje de Derrota y finaliza el juego.
        call clean_screen
        mov ax, offset mensaje_derrota  ; Mueve a ax el mensaje de derrota.
        call puts                       ; Muestra en mensaje.
        call breakline
        mov ax, offset nivel_alcanzado  ; Mueve a ax el mensaje del nivel alcanzado.
        call puts                       ; Muestra el mensaje.
        mov ax, offset nivel            ; Mueve a ax el nivel alcanzado.
        call puts                       ; Muestra el nivel alcanzado
        call breakline                  ; Realiza un salto de pantalla.
        mov ax, offset puntaje          ; Mueve a ax el mensaje del puntaje alcanzado.
        call puts                       ; Muestra el el mensaje del puntaje alcanzado.
        mov al, score                   ; al = score
        call mostrar_num_dos_digitos    ; Muestra el puntaje alcanzado.
        call fin                        ; FINALIZA EL JUEGO.
        
;------------------------------------ 
    
    consultar_seguimiento: ; Consulta al jugador si es que quiere continuar jugando.  
        push ax                         ; guarda ax
        push bx                         ; guarda bx
        push cx                         ; guarda cx
        push dx                         ; guarda dx
        mov ax, offset continue         ; Mueve a ax el mensaje de consulta.
        call puts                       ; Muestra el mensaje.
        call getc                       ; Pide un caracter de confirmacion al usuario.
        cmp al, 'N'                     
        call clean_screen               ; if( caracterDelUsuario.equals('N') ) --> FINALIZAR DEL JUEGO.
        je game_over                            
        mov color, 0fh                  ; color = 0f  | 0f --> Representa el color blanco. 
        call cambiar_color              ; Cambia el color del texto a blanco.
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        ret
        
;------------------------------------       
    
    status:               ; Muestra en pantalla los datos del juego, Nivel, Score y Vidas restantes del jugador.
        push ax                         ; guardar ax
        push bx                         ; guardar bx
        push cx                         ; guardar cx
        push dx                         ; guardar dx
        call breakline                  ; Realiza un salto de pantalla.
        mov ax, offset nivel_alcanzado  ; Mueve a ax el mensaje del nivel alcanzado.
        call puts                       ; Muestra el mensaje.
        mov ax, offset nivel            ; Mueve a ax el nivel alcanzado.
        call puts                       ; Muestra el nivel alcanzado
        call breakline                  ; Realiza un salto de pantalla.
        mov ax, offset puntaje          ; Mueve a ax el mensaje del puntaje alcanzado.
        call puts                       ; Muestra el el mensaje del puntaje alcanzado.
        mov al, score                   ; al = score
        call mostrar_num_dos_digitos    ; Muestra el puntaje alcanzado.
        call breakline                  ; Realiza un salto de pantalla.
        mov ax, offset vidas_restantes  ; Mueve a ax el mensaje las vidas restantes.
        call puts                       ; Muestra el mensaje del puntaje alcanzado.
        mov al, vidas                   ; al = vidas 
        add al,48d                      ; Lo convertimos de ASCII para mostrarlo en pantalla. 
        call putc                       ; Muestra en pantalla las vidas restantes.
        call breakline                  ; Realiza un salto de pantalla.
        pop dx                          ; recupera dx.
        pop cx                          ; recupera cx.
        pop bx                          ; recupera bx.
        pop ax                          ; recupera ax.
        ret                             
                              
;------------------------------------   
                            
    preparar_sentencias:    ; Prepara las sentencias desde el arreglo de sentencias a el arreglo de sentencias del juego.
        push ax                         ; guarda ax
        push cx                         ; guarda bx
        push dx                         ; guarda cx 
        mov bx, 0d                      ; reseteamos bx
        mov bl, cont_sentencias         ; bl = cont_sentencia | cont_sentencias usamos como el indice del arreglo de sentencias.
        cmp cont_sentencias_por_nivel, 3d ; Verifica si avanzaste a un siguiente nivel, si es asi, aumentara la dificultad.
        jnl aumentar_dificultad         ; Si lograste la tercera sentencia de un nivel, avanzas al siguiente nivel y aumenta la dificultad.
        
    cargar_sentencia:                   ; Utilizamos bx para el direccionamiento indirecto de el arreglo sentencias.
        cmp byte ptr [bx], '0'          ; if( sentencias[bx] == '0' ) --> Terminara la preparacion.
        je terminar_preparacion         ; Ya que cada sentencia esta separada por un 0.
        mov al, byte ptr [bx]           ; al =  sentencias[bx]
        mov [simon_dice+SI], al         ; simon_dice[SI] = al  | Guardamos un caracter en el arreglo de sentencias del juego.
        inc bx                          ; ++bx   |   aumentamos el bx que utilizamos para recorrer el arreglo de sentencias.
        inc SI                          ; ++SI   |   aumentamos el SI que utilizamos para recorrer el arreglo de sentencias del juego.
        inc cont_sentencias             ; Incrementa el contador de sentencias del juego.
        jmp cargar_sentencia            ; regresa a cargar_sentencia para verificar si ya ha cargado toda la sentencia. si no, repite el proceso.
        
                            
    terminar_preparacion:   ; Termina el proceso de preparacion de sentencias.
        mov [simon_dice+SI], ' '        ; simon_dice = ' '  |   Separa cada sentencia con un espacio.
        inc SI                          ; ++SI 
        inc bx                          ; ++bx
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop ax                          ; recupera ax
        ret         
      
;____________________________________
                                      
    aumentar_dificultad:     ; Aumenta la dificultad del juego, reduce el tiempo al introducir sentencias y al mostrar sentencias.
        cmp tiempo_limite, 15d          ; if (tiempo_limite <= 15) --> Reducir el tiempo 
        jle reducir_limite_tiempo       ; Esto lo hacemos por si agregamos mas niveles de modo a que el el tiempo no baje de 15 segundos.
        inc nivel                       ; ++nivel  | Aumenta el nivel en donde esta el jugador.
        add puntos_por_nivel, 2d        ; Aumenta en 2 los puntos que el jugador obtendra por sentencia correcta en el nivel actual.
        mov cont_sentencias_por_nivel, 0d ; Resetea el contador de sentencias por nivel.
        mov ax, offset mensaje_aumento_nivel ; Mueve a ax el mensaje que notifica que el jugador ha avanzado de nivel.
        call puts                       ; Muestra el mensaje.
        mov ax, offset nivel            ; Mueve a ax el mensaje que notifica el nivel actual del jugador.
        call puts                       ; Muestra el mensaje.
        call breakline                  ; Realiza un salto de linea.
        mov ax, offset mensaje_dificultad ; Mueve a ax el mensaje que notifica al jugador que se ha aumentado la dificultad.
        call puts                       ; Muestra el mensaje.
        call breakline                  ; Realiza un salto de linea.
        mov ax, offset ready            ; Mueve a ax el mensaje que consulta al jugador si esta listo para continuar el juego.
        call puts                       ; Muestra el mensaje.
        call getc                       ; Pide un caracter al jugador.
        call clean_screen               ; Limpia la la pantalla.
        jmp cargar_sentencia            ; Continua preparando la sentencia del juego.
        
    reducir_limite_tiempo:
        sub tiempo_limite, 2d           ; tiempo_limite = tiempo_limite - 2 | Tiempo al introducir un caracter. 
        sub retardo, 4d                 ; retardo = retardo - 4             | Asteriscos al mostrar caracteres.   
                                      
;____________________________________                                     
                                                                  
    mostrar_sentencias:      ; Muestra al jugador las sentencias del juego. 
        push ax                         ; guarda ax
        push bx                         ; guarda bx
        push cx                         ; guarda cx
        push dx                         ; guarda dx
        mov ax, offset simon_dice       ; Almacena la direccion del areglo simon_dice en ax
        mov bx, ax                      ; Almacena ax en bx | Utilizaremos bx para el direccionamiento indirecto al arreglo que contiene las sentencias que se mostraran al jugador.
        mov al, byte ptr [bx]           ; al = simon_dice[bx]
    put_loop: cmp al, 0 ; al == 0 ?     ; while( simon_dice[bx] != '0' ) -> Continuara cargando mostrando los caracteres.
        je put_fin                      ; Dejara de mostrar.
        call putc                       ; Muestra el caracter.
        inc bx                          ; bx = bx + 1
        mov al, byte ptr [bx]           ; al = simon_dice[bx]
        jmp put_loop                    ; repite la prueba del bucle
    put_fin:                            ; finaliza el bucle
        pop dx ;                        ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        ret   
    
;____________________________________
 
    verificar:               ; Verifica si los caracteres ingresados por el jugador componen la sentencias del juego.  
        push ax                         ; guarda ax
        push bx                         ; guarda bx
        push cx                         ; guarda cx
        push dx                         ; guarda dx
        call verificar_tiempo           ; Verifica si el jugador ha introducido la sentencia en el tiempo establecido.
        mov ax, offset verificando      ; Almacena la direccion del mensaje que notifica al jugador que se esta verificando la sentencia. 
        call puts                       ; Muestra el mensaje.
        call breakline                  ; Realiza un salto de pantalla.
        mov cx, 0d                      ; Resetea cx para utilizarlo para el loop.
        mov DI, 0d                      ; Resetea DI para utilizarlo como indice en el arreglo de respuestas.
        mov cl, cont_sentencias         ; cx = bx (Cantidad de caracteres que tiene las sentencias del simon dice)
                                        ; con esto haremos for(int i = 0; 0 < simon_dice.length;i++)                           
     
    verif_loop:                         ; Bucle que verifica si el jugador ha introducido correctamente la sentencia del juego.
        mov bh, simon_dice [DI]         ; bh = simon_dice[DI] | Guardamos un caracter de la sentencia del juego a bh.
        cmp respuestas[DI], bh          ; while ( respuestas[DI] == bh ) -> Si el caracter es correcto, continua verificando.
        jne verif_erroneamente          ; if(answers[SI] != bh) Termina el bucle y el jugador pierde.  
        mov al, bh                      ; Copia bh en al, para luego mostarlo en pantalla.
        call putc                       ; Muestra el caracter en pantalla.
        inc DI                          ; ++DI incrementa en indice de el arreglo de respuestas. 
        loop verif_loop                 ; vuelve al inicio del bucle.   
    
;------------------------------------    
                             ; Si el jugador ha ingresado la sentencia correctamente
    verif_correctamente:                ; Aumenta el contador y verifica si el jugador ha completado todas las sentencias del juego.
        call clean_screen               ; Limpia la la pantalla. 
        mov color, 2d                   ; Cambiamos a color verde | 2 --> Representa el color verde.
        call cambiar_color              ; Cambia el color a color verde.
        call aumentar_score             ; Aumentar_score del jugador.
        inc cont_sentencias             ; ++inc cont_sentencias
        inc cont_sentencias_por_nivel   ; ++inc cont_sentencias_por_nivel 
        mov vidas, 3d                   ; Establece que las vidas restantes del jugador es 3.
        mov ax, offset correct          ; Almacena la direccion del mensaje que notifica al jugador que ha introducido la sentencia correctamente.
        call puts                       ; Muestra el mensaje.
        call breakline                  ; Realiza un salto de pantalla.
        mov DI, 0d                      ; DI = 0
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        mov bx, 0d                      ; Reseteamos bx
        mov bl, cont_sentencias         ; bl = cont_sentencias | cont_sentencias tiene la cantidad de caracteres en el arreglo de sentenciasl.
        cmp byte ptr [bx], '$'          ; while( sentencias [bx] != * ). Como * es el ultimo caracter del arreglo de sentencias
        je victoria                     ; El jugador ganara si cuando llegue el caracter *.
        call consultar_seguimiento      ; Consulta al jugador si quiere terminar el juego.
        ret  
    
;------------------------------------
                              ; Si el jugador ha ingresado la sentencia erroneamente
    verif_erroneamente:                 ; Se pierde una vida, muestra el nivel y el score del jugador, luego consulta si quiere continuar.
        call clean_screen               ; Limpia la la pantalla.
        mov color,12d                   ; color = 12 | 12 --> Representa el color Rojo. 
        call cambiar_color              ; Cambia el color a color rojo.
        dec vidas                       ; --vidas. El jugador ha fallado y ha perdido una vida.
        mov ax, offset incorrect        ; Almacena la direccion del mensaje que notifica al jugador que ha perdido.
        call puts                       ; Muestra el mensaje. 
        call breakline                  ; Realiza un salto de pantalla.
        call status                     ; Muestra el nive, el score y las vidas restantes del jugador.
        cmp vidas, 0d                   ; if ( vidas !> 0 ) --> GAME OVER
        jng game_over                   ; Si el jugador ya no tiene vidas, pierde y termina el juego.
        call breakline                  ; Realiza un salto de pantalla.
        call consultar_seguimiento      ; Consulta al jugador si quiere terminar el juego.
        mov DI, 0d                      ; Resetea DI.
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        jmp checkpoint                  ; Salta al punto de carga del juego | Donde se muestra la sentencia al jugador.
      
;------------------------------------ 
                              
    verificar_tiempo:         ; Verifica si el jugador ha introducido la sentencia en el tiempo establecido. 
        push ax                         ; guarda ax
        push bx                         ; guarda bx
        push cx                         ; guarda cx
        push dx                         ; guarda dx
        call get_dif_tiempo             ; Obtiene los segundos que el jugador se demoro introduciendo las sentencias.
        mov cl, demora                  ; cl = demora
        cmp tiempo_limite, cl           ; Compara la demora con el tiempo establecido. 
        jl fuera_de_tiempo              ; if ( demora > tiempo_limite ) --> Pierde por fuera de tiempo.
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        ret                             
    
               
    fuera_de_tiempo:          ; Notifica al jugador que ha perdido por no introducir la sentencia dentro del tiempo establecido.
        mov ax, offset destiempo        ; Almacena la direccion del mensaje que notifica al jugador que ha estado en fuera de tiempo. 
        call puts                       ; Muestra el mensaje.
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        jmp verif_erroneamente          ; Salta a verif_erroneamnte
     
;------------------------------------   
                        
    get_dif_tiempo:          ; Compara el tiempo inicial y final para almacenar la diferencia de segundos en la variable "demora".
        push ax                         ; guarda ax
        push bx                         ; guarda bx
        push cx                         ; guarda cx
        push dx                         ; guarda dx
        mov cl, minuto_inicial          ; cl = minuto_inicial de la cuenta.
        mov ch, minuto_final            ; ch = minuto_final de la cuenta.
        mov dl, segundo_inicial         ; dl = segundo_incial de la cuenta.
        mov dh, segundo_final           ; dh = segundo_final de la cuenta.
        
        cmp ch, cl              ; if( minuto_final !> minuto_inicial ), Si ocurre esto solo sera necesario restar el segundo final con el inicial para obtener la demora.
        jg  else                ; pero si el minuto final es mayor, se tendra que sumarle 60*(diferenia de minutos) a  los segundos finale.
        mov demora, dh          ; demora = dh | Guardamos en demora los segundos finales.
        sub demora, dl          ; demora = demora - dl | Le restamos  los segundos iniciales y obtendremos la demora.
        pop dx                          ; recupera dx
        pop cx                          ; recupera cx
        pop bx                          ; recupera bx
        pop ax                          ; recupera ax
        ret
        
        else:                ; Si ha pasado de minuto, sera necesario sumar 60*(diferenia de minutos) a los segundos finales.
        mov bl, ch              ; bl = minutos_final
        sub bl, cl              ; bl = minuto_final - minuto_inicial
        mov al, 60d             ; al = 60
        mul bl                  ; al = bl*al   | Realizamos al = 60*(diferenia de minutos)
        add dh, al              ; dh = dh + al | Sumamos a los segundos finales 60*(diferenia de minutos) 
        mov demora, dh          ; demora = dh  | Guardamos en demora los segundos finales. 
        sub demora, dl          ; demora = demora - dl | Como demora contiene la cantidad final de segundos, se le resta la inicial.
        pop dx                  ; recupera dx
        pop cx                  ; recupera cx
        pop bx                  ; recupera bx
        pop ax                  ; recupera ax
        ret 
                     
;------------------------------------                
                             ; Registra el minuto y segundo en donde comienza la cuenta de tiempo.
    comenzar_cuenta:                     
        push ax                          ; guarda ax
        push bx                          ; guarda bx
        push cx                          ; guarda cx
        push dx                          ; guarda dx
        call get_date                    ; Leemos la hora en nuestra PC   
        mov minuto_inicial, cl           ; minuto_inicial = cl --> cl contiene el minuto actual de nuestra PC. 
        mov segundo_inicial, dh          ; segundo_inicial = dh --> dh contiene el segundo inicial de nuestra PC.
        pop ax                           ; recupera dx
        pop bx                           ; recupera cx
        pop cx                           ; recupera bx
        pop dx                           ; recupera ax
        ret   
        
;------------------------------------
                             ; Registra el minuto y segundo en donde termina la cuenta del tiempo.
   terminar_cuenta:
        push ax                           ; guarda ax
        push bx                           ; guarda bx
        push cx                           ; guarda cx
        push dx                           ; guarda dx
        call get_date                     ; Leemos la hora en nuestra PC   
        mov minuto_final, cl              ; minuto_final = cl --> cl contiene el minuto actual de nuestra PC.
        mov segundo_final, dh             ; segundo_final = dh --> dh contiene el segundo inicial de nuestra PC.
        pop ax                            ; recupera dx
        pop bx                            ; recupera cx
        pop cx                            ; recupera bx
        pop dx                            ; recupera ax
        ret        
            
;------------------------------------
                             ; Obtiene la fecha de nuestra PC y lo almacena de este modo.
    get_date:                ; ch -> hora | cl -> minuto | dh -> segundo | dl -> centesimas
        mov ah,02ch
        int 21h    
        ret                    
       
       
;------------------------------------    
    
   aumentar_score:          ; Aumenta el puntaje del jugador.
        push ax                           ; guarda ax  
        push bx                           ; guarda bx
        push cx                           ; guarda cx
        push dx                           ; guarda dx
        mov al, puntos_por_nivel          ; al = puntos_por_nivel | almacenamos los puntos que recibira el jugador
        add score, al                     ; score = al | aumentamos el score del jugador.
        pop dx                            ; recupera dx
        pop cx                            ; recupera cx
        pop bx                            ; recupera bx
        pop ax                            ; recupera ax
        ret

;------------------------------------   
      
    imprimir_titulo:         ; Muestra el titulo del juego.
        push ax                           ; guarda ax  
        push bx                           ; guarda bx
        push dx                           ; guarda cx
        push cx                           ; guarda dx
        mov ax, offset titulo             ; Almacena la direccion del mensaje que contiene el titulo.
        call puts                         ; Muestra el mensaje.
        pop cx                            ; recupera dx
        pop dx                            ; recupera cx
        pop bx                            ; recupera bx
        pop ax                            ; recupera ax
        ret
        
;------------------------------------           
              
    imprimir_introduccion:   ; Muestra la introduccion del juego.
        push ax                           ; guarda ax  
        push bx                           ; guarda bx
        push dx                           ; guarda cx
        push cx                           ; guarda dx 
        mov color, 0eh                    ; Color = 0Eh  | 0E --> Representa el color amarillo
        call cambiar_color                ; Cambia el color a amararillo.
        mov ax, offset titulo             ; Almacena la direccion del mensaje que contiene el titulo.
        call puts                         ; Muestra el mensaje.
        mov ax, offset introduccion       ; Almacena la direccion del mensaje que contiene la introduccion.
        call puts                         ; Muestra el mensaje.
        call breakline                    ; Realiza un salto del pantalla.
        mov ax, offset instrucciones      ; Almacena la direccion del mensaje que contiene las instrucciones.
        call puts                         ; Muestra el mensaje.
        call breakline                    ; Realiza un salto del pantalla.
        mov ax, offset mensaje_tiempo     ; Almacena la direccion del mensaje que notifica el limite de tiempo.
        call puts                         ; Muestra el mensaje.
        call breakline                    ; Realiza un salto del pantalla.
        mov ax, offset mensaje_puntos     ; Almacena la direccion del mensaje que notifica los puntos que se ganara por cada sentencia.
        call puts                         ; Muestra el mensaje.
        call breakline                    ; Realiza un salto del pantalla.
        mov ax, offset ready              ; Almacena la direccion del mensaje que consulta al jugador si esta listo.
        call puts                         ; Muestra el mensaje.
        call getc                         ; Pide un caracter al jugador.
        mov color, 0fh                    ; color = 0f  | 0f --> Representa el color blanco.
        call cambiar_color                ; Cambia a color blanco
        call clean_screen                 ; Limpia la pantalla
        pop cx                            ; recupera dx
        pop dx                            ; recupera cx
        pop bx                            ; recupera bx
        pop ax                            ; recupera ax
        ret

;------------------------------------     
                       
    mostrar_num_dos_digitos: ; Muestra un numero de dos digitos cargado AL.                 
        push bx                           
        push dx                           
        AAM        
        MOV BX, AX
        MOV AH, 02h
        MOV DL, BH
        ADD DL, 30h
        INT 21H
        MOV AH, 02h
        MOV DL, BL
        ADD DL, 30H
        INT 21H
        pop dx
        pop bx
        ret  

;------------------------------------
        
    clean_screen:             ; Limpia la pantalla.
        push ax
        push bx
        push cx
        push dx
        mov ah, 00h
        mov al, 03h
        int 10h
        pop dx
        pop cx
        pop bx
        pop ax
        ret

;------------------------------------
        
    get_str:                  ; Lee el mensaje terminado por CR (ENTER) dentro del arreglo cuya direccion esta en ax
        push ax                             ; guarda ax
        push bx                             ; guarda bx
        push cx                             ; guarda cx
        push dx                             ; guarda dx
        mov bx, offset respuestas           ; Almacena la direccion del mensaje que contiene el arreglo de respuestas. 
        call getc                           ; Pide un caracter
        mov byte ptr [bx], al               ; respuestas [bx] = al 
    
    get_loop:                               ; while( al =! CR ) -> Mientras el caracter introducido no sea ENTER
        cmp al, 13d                         ; Si el jugador introcude ENTER, terminara el ciclo.
        je get_fin   
        inc DI                              ; DI contendra la cantidad de caracteres introducidos por el usuario.
        inc bx                              ; bx = bx +1
        call getc                           ; Pide el siguiente caracter al jugador
        mov byte ptr [bx], al               ; respuestas[bx] = al 
        jmp get_loop                        ; repite el bucle 
        
    get_fin:
        mov byte ptr [bx], '0'              ; Termina de cargar los caracteres con un 0
        pop dx                              ; recupera dx
        pop cx                              ; recupera cx
        pop bx                              ; recupera bx
        pop ax                              ; recupera ax
        ret  
          
;------------------------------------
           
    getc:                      ; Lee un caracter en consola.
        push bx                             ; guardar bx
        push cx                             ; guardar cx
        push dx                             ; guardar dx
        mov ah, 1h
        int 21h  
        pop dx                              ; recuperar dx
        pop cx                              ; recuperar cx
        pop bx                              ; recuperar bx
        ret 
            
;------------------------------------        
   
    putc:                      ; Muestra un caracter en al.
        push ax                             ; guardar ax
        push bx                             ; guardar bx
        push cx                             ; guardar cx
        push dx                             ; guardar dx
        mov dl, al
        mov ah, 2h
        int 21h   
        pop dx                              ; recuperar dx
        pop cx                              ; recuperar cx
        pop bx                              ; recuperar bx
        pop ax                              ; recuperar ax
        ret                      
        
;------------------------------------         
         
    puts:                      ; Muestra un string con direccion en ax.
        push ax                             ; guardar ax
        push bx                             ; guardar bx
        push cx                             ; guardar cx
        push dx                             ; guardar dx
        mov dx, ax
        mov ah, 9h
        int 21h  
        pop dx                              ; recuperar dx
        pop cx                              ; recuperar cx
        pop bx                              ; recuperar bx
        pop ax                              ; recuperar ax
        ret  
           
;------------------------------------  
    
    cambiar_color:              ; Cambia el color de texto a color verde.
        push ax
        push bx
        push cx
        push dx 
        
        mov cx, 0d
        mov dx, 2470h
        mov bh, color                          ; Cargamos el color que queremos mostrar.
        mov ax, 0600h
        int 10h
        
        pop dx
        pop cx
        pop bx
        pop ax
        ret
                                                                     
;------------------------------------          
                                         
    timer: ;                ; Realiza un ciclo que imprime espacios, lo utilizamos una rutina de tiempo. 
        push ax                             ; guarda ax  
        push bx                             ; guarda bx
        push cx                             ; guarda cx
        mov cl, retardo                     ; cl = reardo | retardo contiene la cantidad de espacios a imprimir.
        mov ax, " "                         ; ax = ' '
        call breakline                      ; Realiza un salto de linea.
        
        printas:                            ; bucle para imprimir asteriscos
            cmp cl, 0d                      ; while (cl > 0) mientras cl sea mayor a 0 se repetrida el bucle.
            jng end_printas                              
            call putc                       ; imprime   
            dec cl                          ; --cl decrementa en uno el contador.
            jmp printas                     ; salta al comienzo del bucle.
                        
            end_printas:                    ; termina el bucle, si cl no es mayor a 0. 
            pop cx                          ; recuperamos cx.
            pop bx                          ; recupera bx
            pop ax                          ; recuperamos ax.
            ret                  
                
;------------------------------------
                                      
     breakline:             ; Realiza un salto de pantalla.
        push ax                             ; guardar ax  
        mov ax, offset linebreak            ; Almacena la direccion del mensaje que contiene el salto de linea. 
        call puts                           ; Imprime 
        pop ax                              ; recuperar ax
        ret   
        
;------------------------------------        
                         
     fin:                   ; FINALIZA EL PROGRAMA. 
        mov ax, 4c00h
        int 21h

end start