segment code
..start:
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	mov sp,top
	
	;Zera a saída da 319h:
	mov al,0
	mov dx,319h
	out dx,al
	
	call instala_interrupcoes	
	call ajuste_inicial
	call desenha_interface_fixa
	
  ;Loop principal do programa:
	loop_principal:
    ;Verifica se algum botão foi pressionado:
		call testa_botoes
    
    ;Se o elevador está subindo:
		cmp byte[estado_elevador],SUBINDO
		je testa_continua_subindo
    
    ;Se o elevador está descendo:
		cmp byte[estado_elevador],DESCENDO
		je testa_continua_descendo
    
		;Se o elevador está parado:
		call verifica_chamadas_acima
		cmp ax,1
		je comeca_subir
		call verifica_chamadas_abaixo
		cmp ax,1
		je comeca_descer
		
    ;Se não há chamadas nem acima nem abaixo:
		call verifica_chamada_andar_atual
		cmp ax,1
		jne sem_chamada_atual
		call parado
		
    ;Apaga as luzes do andar atual:
		sem_chamada_atual:
		xor bx,bx
		mov bl,byte[andar_elevador]
		dec bl
		mov al,byte[botao_subida+bx]
		mov al,byte[botoes]
		not al
		and al,00111111b
		and byte[botoes],al
		
		mov al,byte[botao_descida+bx]
		not al
		and al,00111111b
		and byte[botoes],al
		
    ;Atende as chamadas do andar atual:
		mov byte[chamadas_internas+bx],0
		jmp loop_principal
		
    ;Elevador vai começar a subir:
		comeca_subir:
			mov byte[estado_elevador],SUBINDO
			call verifica_parada
			jmp loop_principal
		
    ;Elevador vai começar a descer:
		comeca_descer:
			mov byte[estado_elevador],DESCENDO
			call verifica_parada
			jmp loop_principal
		
    ;Verifica se o elevador deve continuar subindo:
		testa_continua_subindo:
			call verifica_chamadas_acima
			cmp ax,1
			je continua_subindo
      
      ;Se o elevador vai parar,antes mudamos o estado e verificamos parada para desativar
      ;possíveis chamadas no sentido oposto do movimento:
			mov byte[estado_elevador],DESCENDO
			call verifica_parada
			mov byte[estado_elevador],PARADO
			jmp loop_principal
			
      ;Se o elevador deve continuar subindo,desloca um andar para cima:
			continua_subindo:
				call sobe1andar
				call verifica_parada
				jmp loop_principal
		
    ;Verifica se o elevador deve continuar descendo:
		testa_continua_descendo:
			call verifica_chamadas_abaixo
			cmp ax,1
			je continua_descendo
      
      ;Se o elevador vai parar,antes mudamos o estado e verificamos parada para desativar
      ;possíveis chamadas no sentido oposto do movimento:
			mov byte[estado_elevador],SUBINDO
			call verifica_parada
			mov byte[estado_elevador],PARADO
			call verifica_parada
			jmp loop_principal
			
      ;Se o elevador deve continuar descendo,desloca um andar para baixo:
			continua_descendo:
				call desce1andar
				call verifica_parada
				jmp loop_principal

;Desenha a parte fixa da interface (paredes,bonecos,etc):
desenha_interface_fixa:
	push ax
	push bx
	push cx
	push dx	
	
	mov byte[cor],cinza
	
	; desenhando o quadrado do elevador
	; linha esquerda
	mov ax,110
	push ax
	mov ax,405
	push ax
	mov ax,110
	push ax
	mov ax,75
	push ax
	call line
	
	; linha direita
	mov ax,510
	push ax
	mov ax,405
	push ax
	mov ax,510
	push ax
	mov ax,75
	push ax
	call line
  
	; linha de baixo
	mov ax,110
	push ax
	mov ax,75
	push ax
	mov ax,510
	push ax
	mov ax,75
	push ax
	call line	
	
	; linha de cima
	mov ax,110
	push ax
	mov ax,405
	push ax
	mov ax,510
	push ax
	mov ax,405
	push ax
	call line		
	
	; cabo direita
	mov ax,300
	push ax
	mov ax,500
	push ax
	mov ax,300
	push ax
	mov ax,405
	push ax
	call line	
	
	; cabo esquerdo
	mov ax,310
	push ax
	mov ax,500
	push ax
	mov ax,310
	push ax
	mov ax,405
	push ax
	call line		
	
	; linha de mais abaixo
	mov ax,0
	push ax
	mov ax,10
	push ax
	mov ax,640
	push ax
	mov ax,10
	push ax
	call line	

	; linha mais direita
	mov ax,610
	push ax
	mov ax,510
	push ax
	mov ax,610
	push ax
	mov ax,10
	push ax
	call line	
	
	; linha mais esquerda
	mov ax,30
	push ax
	mov ax,510
	push ax
	mov ax,30
	push ax
	mov ax,10
	push ax
	call line	
	
	; desenhando o boneco 1
	mov byte[cor],azul	;cabeça
	mov ax,200
	push ax
	mov ax,150
	push ax
	mov ax,20
	push ax
	call circle	
	
	;corpo boneco 1
	mov ax,200
	push ax
	mov ax,95
	push ax
	mov ax,200
	push ax
	mov		ax,130
	push ax
	call line		
	
	;perna boneco 1
	mov ax,200
	push ax
	mov ax,95
	push ax
	mov ax,190
	push ax
	mov		ax,75
	push ax
	call line		
	
	;perna boneco 1
	mov ax,200
	push ax
	mov ax,95
	push ax
	mov ax,210
	push ax
	mov		ax,75
	push ax
	call line		
	
	;braco boneco 1
	mov ax,200
	push ax
	mov ax,115
	push ax
	mov ax,190
	push ax
	mov		ax,95
	push ax
	call line		
	
	;braco boneco 1
	mov ax,200
	push ax
	mov ax,115
	push ax
	mov ax,210
	push ax
	mov		ax,95
	push ax
	call line		
	
; desenhando o boneco 2	;cabeça
	mov		ax,300
	push		ax
	mov		ax,150
	push		ax
	mov		ax,20
	push		ax
	call circle	
	
	;corpo boneco 2
	mov ax,300
	push ax
	mov ax,95
	push ax
	mov ax,300
	push ax
	mov		ax,130
	push ax
	call line		
	
	;perna boneco 2
	mov ax,300
	push ax
	mov ax,95
	push ax
	mov ax,290
	push ax
	mov		ax,75
	push ax
	call line		
	
	;perna boneco 2
	mov ax,300
	push ax
	mov ax,95
	push ax
	mov ax,310
	push ax
	mov		ax,75
	push ax
	call line		
	
	;braco boneco 2
	mov ax,300
	push ax
	mov ax,115
	push ax
	mov ax,290
	push ax
	mov		ax,95
	push ax
	call line		
	
	;braco boneco 2
	mov ax,300
	push ax
	mov ax,115
	push ax
	mov ax,310
	push ax
	mov		ax,95
	push ax
	call line			

; desenhando o boneco 3	;cabeça
	mov		ax,400
	push		ax
	mov		ax,150
	push		ax
	mov		ax,20
	push		ax
	call circle	
	
	;corpo boneco 3
	mov ax,400
	push ax
	mov ax,95
	push ax
	mov ax,400
	push ax
	mov		ax,130
	push ax
	call line		
	
	;perna boneco 3
	mov ax,400
	push ax
	mov ax,95
	push ax
	mov ax,390
	push ax
	mov		ax,75
	push ax
	call line		
	
	;perna boneco 3
	mov ax,400
	push ax
	mov ax,95
	push ax
	mov ax,410
	push ax
	mov		ax,75
	push ax
	call line		
	
	;braco boneco 3
	mov ax,400
	push ax
	mov ax,115
	push ax
	mov ax,390
	push ax
	mov		ax,95
	push ax
	call line		
	
	;braco boneco 3
	mov ax,400
	push ax
	mov ax,115
	push ax
	mov ax,410
	push ax
	mov		ax,95
	push ax
	call line	
	
	mov byte[cor],amarelo		
	;Escreve nome Junim
	mov     cx,17 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,26 ;linha 0-29
    mov     dl,30 ;coluna 0-79
	escrevendo_junim:
	call cursor
    mov     al,[bx+junim]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_junim
	
	;Escreve nome Patcha
	mov     cx,13 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,27 ;linha 0-29
    mov     dl,32 ;coluna 0-79
	escrevendo_patcha:
	call cursor
    mov     al,[bx+patcha]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_patcha
	
	;Escreve nome Leticia
	mov     cx,11 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,28 ;linha 0-29
    mov     dl,33 ;coluna 0-79
	escrevendo_leticia:
	call cursor
    mov     al,[bx+leticia]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_leticia
	
	;Escreve materia
	mov     cx,30 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,2 ;linha 0-29
    mov     dl,5 ;coluna 0-79
	escrevendo_materia:
	call cursor
    mov     al,[bx+materia]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_materia
	
	;Escreve nome Professor
	mov     cx,25 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,2 ;linha 0-29
    mov     dl,44 ;coluna 0-79
	escrevendo_prof:
	call cursor
    mov     al,[bx+prof]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_prof
	
	;Escreve estado
	mov     cx,7 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,6 ;linha 0-29
    mov     dl,16 ;coluna 0-79
	escrevendo_estado:
	call cursor
    mov     al,[bx+estado]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_estado
	
	
	;Escreve Andar
	mov     cx,6 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,9 ;linha 0-29
    mov     dl,16 ;coluna 0-79
	escrevendo_andar:
	call cursor
    mov     al,[bx+andar]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_andar
	
	;Escreve chamadas internas
	mov     cx,18 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,11 ;linha 0-29
    mov     dl,16 ;coluna 0-79
	escrevendo_chamadas_int:
	call cursor
    mov     al,[bx+chamadas_int]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_chamadas_int
	
	;Escreve chamadas externas
	mov     cx,18 ; tamanho da string
    mov     bx,0  ; zerando bx
    mov     dh,14 ;linha 0-29
    mov     dl,16 ;coluna 0-79
	escrevendo_chamadas_ext:
	call cursor
    mov     al,[bx+chamadas_ext]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_chamadas_ext	
	
		
	pop dx
	pop cx
	pop bx
	pop ax
	ret

desenha_interface_dinamica:
	push ax
	push bx
	push cx
	push dx

	; atualiza o valor do andar do elevador
	mov dh,9 ; linha 0-29
	mov dl,23; coluna 0-79
	call cursor
	mov al,byte[andar_elevador]
	add al,30h
	call caracter	
	
	; verificando se ta em emergencia. Se for,ele coloca emergencia no estado
	cmp byte[emergencia],0
	jne att_emerg
	
	;atualiza o estado do elevador
	cmp byte[estado_elevador],1
	je att_subindo
	
	cmp byte[estado_elevador],2
	je att_descendo
	
	cmp byte[estado_elevador],0
	je att_parado
	
	
	att_descendo:
		call escreve_subindo
		call escreve_parado
		mov byte[cor],vermelho
		call escreve_descendo
		mov byte[cor],amarelo
		call escreve_emergencia
		jmp continua_dinamico
	att_parado:
		call escreve_subindo
		mov byte[cor],vermelho
		call escreve_parado
		mov byte[cor],amarelo
		call escreve_descendo
		call escreve_emergencia
		jmp continua_dinamico
	att_subindo:
		mov byte[cor],vermelho
		call escreve_subindo
		mov byte[cor],amarelo
		call escreve_parado
		call escreve_descendo
		call escreve_emergencia		
		jmp continua_dinamico
	att_emerg:
		call escreve_subindo
		call escreve_parado
		call escreve_descendo
		mov byte[cor],vermelho
		call escreve_emergencia
		mov byte[cor],amarelo
		jmp continua_dinamico
		
	continua_dinamico:
	
	call escreve_chamada_int1
	call escreve_chamada_int2
	call escreve_chamada_int3
	call escreve_chamada_int4
	call escreve_chamada_ext1
	call escreve_chamada_ext2
	call escreve_chamada_ext3
	call escreve_chamada_ext4
  
	mov byte[cor],amarelo
		
	pop dx
	pop cx
	pop bx
	pop ax
	ret	

escreve_subindo:
	push ax
	push bx
	push cx
	push dx

	mov cx,7 ; tamanho da string
	mov bx,0  ; zerando bx
	mov dh,7 ;linha 0-29
	mov dl,34 ;coluna 0-79
	escrevendo_sub:
	call cursor
    mov     al,[bx+subindo_str]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_sub
		
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
escreve_descendo:
	push ax
	push bx
	push cx
	push dx	
	
	mov cx,8 ; tamanho da string
	mov bx,0  ; zerando bx
	mov dh,7 ;linha 0-29
	mov dl,16 ;coluna 0-79	
	escrevendo_desc:
	call cursor
    mov     al,[bx+descendo_str]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_desc

	pop dx
	pop cx
	pop bx
	pop ax
	ret	
	
escreve_parado:
	push ax
	push bx
	push cx
	push dx

	mov cx,6 ; tamanho da string
	mov bx,0  ; zerando bx
	mov dh,7 ;linha 0-29
	mov dl,26 ;coluna 0-79	
	escrevendo_parado:
	call cursor
    mov     al,[bx+parado_str]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_parado
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret	
		
escreve_emergencia:
	push ax	
	push bx
	push cx
	push dx
	
	mov cx,10 ; tamanho da string
	mov bx,0  ; zerando bx
	mov dh,7 ;linha 0-29
	mov dl,43 ;coluna 0-79	
	escrevendo_emerg:
	call cursor
    mov     al,[bx+emerg]
	call caracter
    inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
    loop    escrevendo_emerg	
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret		
	
escreve_chamada_int1:
	push ax
	push dx
	
	mov byte[cor],amarelo
	cmp byte[chamadas_internas],1
	jne  c1a	
	mov byte[cor],vermelho
	
	c1a:
	mov     dh,12 ;linha 0-29
    mov     dl,22 ;coluna 0-79
	call cursor
	mov		al,1
	add		al,30h
	call caracter		
	
	pop dx
	pop		ax
	ret

escreve_chamada_int2:
	push    ax
	push dx
	
	mov byte[cor],amarelo
	cmp byte[chamadas_internas+1],1
	jne  c2a	
	mov byte[cor],vermelho
	
	c2a:
	mov     dh,12 ;linha 0-29
    mov     dl,20 ;coluna 0-79
	call cursor
	mov		al,2
	add		al,30h
	call caracter
	
	pop		dx
	pop		ax
	ret
	
escreve_chamada_int3:
	push ax
	push dx
	
	mov byte[cor],amarelo
	cmp byte[chamadas_internas+2],1
	jne  c3a	
	mov byte[cor],vermelho
	
	c3a:
	mov     dh,12 ;linha 0-29
    mov     dl,18 ;coluna 0-79
	call cursor
	mov		al,3
	add		al,30h
	call caracter
	
	pop dx
	pop		ax
	ret
	
escreve_chamada_int4:	
	push ax
	push dx
	
	mov byte[cor],amarelo
	cmp byte[chamadas_internas+3],1
	jne  c4a	
	mov byte[cor],vermelho
	
	c4a:
	mov     dh,12 ;linha 0-29
    mov     dl,16 ;coluna 0-79
	call cursor
	mov		al,4
	add		al,30h
	call caracter
	
	pop		dx
	pop		ax
	ret
  
escreve_chamada_ext1:
	push ax
	push dx
	
	mov byte[cor],amarelo
  mov al,byte[botoes]
  and al,byte[botao_subida]
  cmp al,0
  je c1exta
	mov byte[cor],vermelho
	
	c1exta:
	mov     dh,15 ;linha 0-29
    mov     dl,22 ;coluna 0-79
	call cursor
	mov		al,1
	add		al,30h
	call caracter		
	
	pop dx
	pop		ax
	ret
  
escreve_chamada_ext2:
	push ax
	push dx
	
	mov byte[cor],amarelo
  mov al,byte[botoes]
  and al,byte[botao_subida+1]
  cmp al,0
  je c2extdescida
	mov byte[cor],vermelho
  jmp c2exta
	
  c2extdescida:
  mov al,byte[botoes]
  and al,byte[botao_descida+1]
  cmp al,0
  je c2exta
  mov byte[cor],vermelho
  
	c2exta:
	mov     dh,15 ;linha 0-29
    mov     dl,20 ;coluna 0-79
	call cursor
	mov		al,2
	add		al,30h
	call caracter		
	
	pop dx
	pop		ax
	ret
	
escreve_chamada_ext3:
	push ax
	push dx
	
	mov byte[cor],amarelo
  mov al,byte[botoes]
  and al,byte[botao_subida+2]
  cmp al,0
  je c3extdescida
	mov byte[cor],vermelho
  jmp c3exta
	
  c3extdescida:
  mov al,byte[botoes]
  and al,byte[botao_descida+2]
  cmp al,0
  je c3exta
  mov byte[cor],vermelho
  
	c3exta:
	mov     dh,15 ;linha 0-29
    mov     dl,18 ;coluna 0-79
	call cursor
	mov		al,3
	add		al,30h
	call caracter		
	
	pop dx
	pop		ax
	ret
  
escreve_chamada_ext4:
	push ax
	push dx
	
	mov byte[cor],amarelo
  mov al,byte[botoes]
  and al,byte[botao_descida+3]
  cmp al,0
  je c4exta
	mov byte[cor],vermelho
	
	c4exta:
	mov     dh,15 ;linha 0-29
    mov     dl,16 ;coluna 0-79
	call cursor
	mov		al,4
	add		al,30h
	call caracter		
	
	pop dx
	pop		ax
	ret
  
verifica_chamada_andar_atual:
		push bx
		push cx
		
		xor bx,bx
		mov bl,byte[andar_elevador]
		dec bl
		mov bl,byte[botao_subida+bx]
		mov al,byte[botoes]
		and al,bl
		cmp al,0
		jne atual_chamou
		mov bl,byte[andar_elevador]
		dec bl
		mov bl,byte[botao_descida+bx]
		mov al,byte[botoes]
		and al,bl
		cmp al,0
		jne atual_chamou
		mov ax,0
		jmp fim_atual
		
		atual_chamou:
		mov ax,1
		
		fim_atual:
		pop cx
		pop bx
    ret
		
verifica_chamadas_acima:
	push bx
	push cx
	
	xor bx,bx
	mov bl,byte[andar_elevador]
	dec bx
	mov al,byte[descarta_abaixo+bx]
	mov bl,byte[botoes]
	and bl,al
	cmp bl,0
	je sem_chamadas_externas_acima
	mov ax,1
	jmp fim_verif_acima
	
	sem_chamadas_externas_acima:
	mov bx,4
	loop_testa_botoes_acima:
		cmp bl,byte[andar_elevador]
		je fim_loop_testa_botoes_acima
		dec bx
		cmp byte[chamadas_internas+bx],1
		je loop_testa_botoes_acima_com_chamada
		jmp loop_testa_botoes_acima
		
		loop_testa_botoes_acima_com_chamada:
		mov ax,1
		jmp fim_verif_acima
	
	fim_loop_testa_botoes_acima:
	mov ax,0
	
	fim_verif_acima:
	pop cx
	pop bx
	ret
	
verifica_chamadas_abaixo:
	push bx
	push cx
	
	xor bx,bx
	mov bl,byte[andar_elevador]
	dec bx
	mov al,byte[descarta_acima+bx]
	mov bl,byte[botoes]
	and bl,al
	cmp bl,0
	je sem_chamadas_externas_abaixo
	mov ax,1
	jmp fim_verif_abaixo
	
	sem_chamadas_externas_abaixo:
	mov bx,1
	loop_testa_botoes_abaixo:
		cmp bl,byte[andar_elevador]
		je fim_loop_testa_botoes_abaixo
		dec bx
		cmp byte[chamadas_internas+bx],1
		je loop_testa_botoes_abaixo_com_chamada
		inc bx
		inc bx
		jmp loop_testa_botoes_abaixo
		
		loop_testa_botoes_abaixo_com_chamada:
		mov ax,1
		jmp fim_verif_abaixo
		
	
	fim_loop_testa_botoes_abaixo:
	mov ax,0
	
	fim_verif_abaixo:
	pop cx
	pop bx
	ret
	
sair:
	;Zera a saída da 318h:
	mov al,0
	mov dx,318h
	out dx,al
	
	;Zera a saída da 319h:
	mov dx,319h
	out dx,al
	
	call desinstala_interrupcoes
	call sai_modo_grafico
	
	;Sair do programa:
	mov ah,4ch
	int 21h

ajuste_inicial:
	push ax
	push bx
	push cx
	push dx
	
	;Faz o motor subir:
	mov al,10000000b
	mov dx,318h
	out dx,al
	
	;Exibe a mensagem inicial:
	mov dx,msg_ajuste_inicial
	mov ah,09h
	int 21h
	
	;Aguarda o pressionamento da tecla de inicio:
	loop_ajuste_inicial:
		cmp byte[apertou_inicio],0
		je loop_ajuste_inicial
	
	;Para o motor:
	mov dx,318h
	mov al,0
	out dx,al
	
	;Posiciona o elevador no quarto andar:
	call desce1andar
	
	;Define a variável do andar atual:
	mov byte[andar_elevador],4
	mov byte[estado_elevador],PARADO
	
	call inicia_modo_grafico
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

inicia_modo_grafico:
	push ax
	push bx
	push cx
	push dx
	
	mov ah,0Fh
	int 10h
	mov byte[modo_anterior],al
	mov al,12h
	mov ah,0
	int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

sai_modo_grafico:
	push ax
	push bx 
	push cx
	push dx
	
	mov ah,0
	mov al,byte[modo_anterior]
	int 10h
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
instala_interrupcoes:
	push ax
	xor ax,ax
	mov es,ax
	mov ax,[es:9h*4]
	mov word[offset_dos],ax
	mov ax,[es:9h*4+2]
	mov word[cs_dos],ax
	cli
	mov word[es:9h*4+2],cs
	mov word[es:9h*4],int_teclado
	sti
	pop ax
	ret
	
desinstala_interrupcoes:
	push ax
	cli
	mov ax,word[offset_dos]
	mov word[es:9h*4],ax
	mov ax,word[cs_dos]
	mov word[es:9h*4+2],ax
	sti
	pop ax
	ret
	
;Desce um andar:	
desce1andar:
	push ax
	mov ax,1
	call move1andar
	cmp byte[ultima_operacao],1
	jne cont_desce
	call move1andar
	cont_desce:
	dec byte[andar_elevador]
	;call verifica_parada
	mov byte[ultima_operacao],0
	pop ax
	ret

;Sobre um andar:
sobe1andar:
	push ax
	mov ax,2
	call move1andar
	cmp byte[ultima_operacao],0
	jne cont_sobe
	call move1andar
	cont_sobe:
	inc byte[andar_elevador]
	;call verifica_parada
	mov byte[ultima_operacao],1
	pop ax
	ret

verifica_parada:
	push ax
	push bx
	push cx
	push dx
	
	cmp byte[estado_elevador],SUBINDO
	je verifica_parada_subindo
	cmp byte[estado_elevador],DESCENDO
	je verifica_parada_descendo
	jmp verifica_parada_sair
	
	verifica_parada_subindo:
		xor bx,bx
		mov bl,byte[andar_elevador]
		dec bl
		cmp byte[chamadas_internas+bx],1
		jne sem_interna_subindo
		mov byte[chamadas_internas+bx],0
		mov bl,byte[botao_subida+bx]
		mov al,byte[botoes]
		and al,bl
		not al
		and byte[botoes],al
		mov al,byte[saida318]
		and al,11000000b
		or al,byte[botoes]
		mov dx,318h
		out dx,al
		mov byte[saida318],al
		call parado
		jmp verifica_parada_sair
		
		sem_interna_subindo:
		mov bl,byte[andar_elevador]
		dec bl
		mov bl,byte[botao_subida+bx]
		mov al,byte[botoes]
		and al,bl
		cmp al,0
		je verifica_parada_sair
		not al
		and byte[botoes],al
		mov al,byte[saida318]
		and al,11000000b
		or al,byte[botoes]
		mov dx,318h
		out dx,al
		mov byte[saida318],al
		call parado
		jmp verifica_parada_sair
	
	verifica_parada_descendo:
		xor bx,bx
		mov bl,byte[andar_elevador]
		dec bl
		cmp byte[chamadas_internas+bx],1
		jne sem_interna_descendo
		mov byte[chamadas_internas+bx],0
		mov bl,byte[botao_descida+bx]
		mov al,byte[botoes]
		and al,bl
		not al
		and byte[botoes],al
		mov al,byte[saida318]
		and al,11000000b
		or al,byte[botoes]
		mov dx,318h
		out dx,al
		mov byte[saida318],al
		call parado
		jmp verifica_parada_sair
		
		verifica_parada_sair
		pop dx
		pop cx
		pop bx
		pop ax
		ret
		
		sem_interna_descendo:
		mov bl,byte[andar_elevador]
		dec bl
		mov bl,byte[botao_descida+bx]
		mov al,byte[botoes]
		and al,bl
		cmp al,0
		je verifica_parada_sair
		not al
		and byte[botoes],al
		mov al,byte[saida318]
		and al,11000000b
		or al,byte[botoes]
		mov dx,318h
		out dx,al
		mov byte[saida318],al
		call parado
		jmp verifica_parada_sair
	
;Move um andar.
;Se AX = 1,desce
;Se AX = 2,sobe
move1andar:
	push ax
	push bx
	push cx
	push dx
	
	;Coloca em 318h o comando para o motor:
	shl al,6
	and byte[saida318],00111111b
	or byte[saida318],al
	mov al,byte[saida318]
	mov dx,318h
	out dx,al
	mov byte[saida318],al
	
	call espera_buraco
	
	;Para o motor:
	and byte[saida318],00111111b
	mov al,byte[saida318]
	out dx,al
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

espera_buraco:
	push ax
	push dx
	
	loop_espera_nao_buraco:
		call testa_botoes
		mov dx,319h
		in al,dx
		and al,01000000b
		cmp al,0
		je loop_espera_nao_buraco
		
	;Leu um não buraco,vamos fazer debounce
	call delay
	
	in al,dx
	and al,01000000b
	cmp al,0
	je loop_espera_nao_buraco
	
	loop_espera_buraco:
		call testa_botoes
		mov dx,319h
		in al,dx
		and al,01000000b
		cmp al,0
		jne loop_espera_buraco
	
	;Leu um buraco,vamos fazer debounce
	call delay
	
	in al,dx
	and al,01000000b
	cmp al,0
	jne loop_espera_buraco
	
	loop_espera_nao_buraco2:
		call testa_botoes
		mov dx,319h
		in al,dx
		and al,01000000b
		cmp al,0
		je loop_espera_nao_buraco2
		
	;Leu um não buraco,vamos fazer debounce
	call delay
	
	in al,dx
	and al,01000000b
	cmp al,0
	je loop_espera_nao_buraco2
	
	pop dx
	pop ax
	ret

parado:
	push ax
	push dx
	mov dx,319h
	mov ax,1
	out dx,al
	call delay_andar
	mov ax,0
	out dx,al
	pop dx
	pop ax
	ret
	
testa_botoes:
	push ax
	push bx
	push cx
	push dx
	
  call desenha_interface_dinamica
  
	cmp byte[apertou_sair],1
	jne testa_emerg
	call sair
	
	testa_emerg:
	cmp byte[emergencia],0
	je continua_botoes
	call para_tudo
	
	continua_botoes:
	;Zerar AX e BX
	xor ax,ax
	xor bx,bx
	
	loop_debounce_botoes:
		;Primeira leitura:
		mov dx,319h
		in al,dx
		and al,00111111b
		mov bx,ax
		call delay
		
		;Segunda leitura,para verificar se é igual à primeira:
		mov dx,319h
		in al,dx
		and al,00111111b
		cmp bx,ax
		
		;Se for diferente,pode ser algum ruído,testamos de novo:
		jne loop_debounce_botoes
	
	;Temos uma leitura estável dos botões,vamos adicionar os botões apertados à variável 'botoes':
	not al
	and al,00111111b
	or byte[botoes],al
	
	;Atualizar os LEDs:
	mov al,byte[saida318]
	and al,11000000b
	or al,byte[botoes]
	mov dx,318h
	out dx,al
	mov byte[saida318],al
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

para_tudo:
	push ax
	push dx
	
	mov al,byte[saida318]
	and al,00111111b
	mov dx,318h
	out dx,al
	
	call desenha_interface_dinamica
	
	loop_para_tudo:
		cmp byte[emergencia],0
		jne loop_para_tudo
	
	mov al,byte[saida318]
	out dx,al
	
	call desenha_interface_dinamica	
	
	pop dx
	pop ax
	ret

int_teclado:
	push ax
	
	;Ler o valor digitado no teclado:
	in al,60h
	mov byte[tecla],al
	cmp byte[tecla],82h
	jne testa_2
	mov byte[chamadas_internas],1
	jmp fim_testa
	
	testa_2:
	cmp byte[tecla],83h
	jne testa_3
	mov byte[chamadas_internas+1],1
	jmp fim_testa
	
	testa_3:
	cmp byte[tecla],84h
	jne testa_4
	mov byte[chamadas_internas+2],1
	jmp fim_testa
	
	testa_4:
	cmp byte[tecla],85h
	jne testa_s
	mov byte[chamadas_internas+3],1
	jmp fim_testa
	
	testa_s:
	cmp byte[tecla],9fh
	jne testa_esc_make
	mov byte[apertou_sair],1
	jmp fim_testa
	
	testa_esc_make:
	cmp byte[tecla],1
	jne testa_esc_break
	cmp byte[emergencia],0
	jne testa_emergencia_2
	mov byte[emergencia],1
	jmp fim_testa
	
	testa_emergencia_2:
	cmp byte[emergencia],2
	jne fim_testa;
	mov byte[emergencia],0
	jmp fim_testa
	
	testa_esc_break:
	cmp byte[tecla],81h
	jne testa_inicio
	cmp byte[emergencia],1
	jne fim_testa
	mov byte[emergencia],2
	jmp fim_testa
	
	testa_inicio:
	cmp byte[tecla],97h
	jne fim_testa
	mov byte[apertou_inicio],1
	jmp fim_testa
	
	fim_testa:
	
	;Comunicação com o teclado:
	in al,61h
	or al,0x80
	out 61h,al
	and al,0x7f
	out 61h,al
	
	;Avisa o fim do tratamento de interrupção:
	mov al,20h
	out 20h,al
	
	pop ax
	iret

delay:
	push cx
	mov cx,1000
	del1:
		push cx
		mov cx,1000
		del2:
			loop del2
		pop cx
		loop del1
	pop cx
	ret
	
	

;Funções do modo gráfico:
cursor:
	pushf
	pusha
	mov ah,2
	mov bh,0
	int 10h
	popa
	popf
	ret

;_____________________________________________________________________________
;    função circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
	push bp
	mov	 bp,sp
	pushf                        ;coloca os flags na pilha
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov dx,bx	
	add		dx,cx       ;ponto extremo superior
	push    ax			
	push dx
	call plot_xy
	
	mov		dx,bx
	sub		dx,cx       ;ponto extremo inferior
	push    ax			
	push dx
	call plot_xy
	
	mov dx,ax	
	add		dx,cx       ;ponto extremo direita
	push    dx			
	push bx
	call plot_xy
	
	mov		dx,ax
	sub		dx,cx       ;ponto extremo esquerda
	push    dx			
	push bx
	call plot_xy
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  ;dx será a variável x. cx é a variavel y
	
;aqui em cima a lógica foi invertida,1-r => r-1
;e as comparações passaram a ser jl => jg,assim garante 
;valores positivos para d

stay:				;loop
	mov		si,di
	cmp		si,0
	jg		inf       ;caso d for menor que 0,seleciona pixel superior (não  salta)
	mov		si,dx		;o jl é importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx  ;faz x - y (dx-cx),e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar:	
	mov		si,dx
	add		si,ax
	push    si			;coloca a abcisa x+xc na pilha
	mov		si,cx
	add		si,bx
	push    si			;coloca a ordenada y+yc na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,dx
	push    si			;coloca a abcisa xc+x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do sétimo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc+x na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do oitavo octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	add		si,cx
	push    si			;coloca a ordenada yc+y na pilha
	call plot_xy		;toma conta do terceiro octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do sexto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quinto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quarto octante
	
	cmp		cx,dx
	jb		fim_circle  ;se cx (y) está abaixo de dx (x),termina     
	jmp		stay		;se cx (y) está acima de dx (x),continua no loop
	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
	
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push ax
		push bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar módulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx
		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5
	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx
		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8

	
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push ax
		push bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     ah,0ch
	    mov     al,[cor]
	    mov     bh,0
	    mov     dx,479
		sub		dx,[bp+4]
	    mov     cx,[bp+6]
	    int     10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
	
	
	
	
caracter:
	pushf
	pusha
	mov ah,9
	mov bh,0
	mov cx,1
	mov bl,byte[cor];cor
	int 10h
	popa
	popf
	ret
	
imprime_str:
	push bp
	mov bp,sp
	pushf
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov ax,0
	mov bx,word[bp+4]
	imprime:
		mov al,byte[bx]
		cmp al,0
		jz fim_imprime
		call cursor
		call caracter
		inc bx
		inc dl
		jmp imprime
		
	fim_imprime:
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		popf
		pop bp
		ret 2

		
delay_andar:
	push cx
	mov cx,300
	del11:
		call testa_botoes
		push cx
		mov cx,100
		del22:
			loop del22
		pop cx
		loop del11
	pop cx
	ret

segment data
SUBINDO equ 1
DESCENDO equ 2
PARADO equ 0

descarta_abaixo db 00111110b,00110100b,00100000b,0
descarta_acima db 0,00000001b,00001011b,00011111b
botao_subida db 00000001b,0000010b,00000100b,00000000b
botao_descida db 00000000b,00001000b,00010000b,00100000b

saida318 db 0
botoes db 0
offset_dos dw 1
cs_dos dw 1
tecla db 0
apertou_sair db 0
apertou_inicio db 0
emergencia db 0
chamadas_internas db 0,0,0,0
estado_elevador db 0
andar_elevador db 0
modo_anterior db 0
ultima_operacao db 0
msg_ajuste_inicial db "Ajuste inicial. Pressione I para iniciar o programa...$"
junim			db	   "Guilherme Tebaldi$"
patcha          db     "Andre Pacheco"
leticia	        db	   "Leticia Ruy$"
materia    db "Sistemas Embarcados I - 2013/2"
prof			db "Professor: Evandro Ottoni"
estado			db "Estado:"
andar			db "Andar:"
chamadas_int db "Chamadas Internas:"
chamadas_ext db "Chamadas Externas:"
emerg 	db		"Emergencia";10
subindo_str		db  "Subindo"    
descendo_str db  "Descendo"
parado_str		db  "Parado"
deltax			dw		0
deltay			dw		0	
cor				db		cinza
azul			equ		9
cyan			equ		3
vermelho		equ		4
branco			equ		7
cinza			equ		8
amarelo			equ		14
branco_intenso equ		15

segment stack stack
resb 100h
top: