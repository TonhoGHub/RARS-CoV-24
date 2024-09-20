# Projeto Aplicativo - RARSCOV24 - ISC 2024.1 #
# Alunos: Antonio Coelho, Leonardo Mileo e Rafael Medeiros #

.include "MACROSv21.s"

.data
	.include "MAPA.data"
	.include "MAPA2.data"
	.include "leandrov2.data"
	.include "musica.data"
	.include "nextlevel.data"
	.include "loadscreen.data"
	.include "endscreen.data"
	.include "musicaloadscr.data"
	BUFFER: .space 4
	FASE: .word 1

.text
LOADSCREEN:
		li t1,0xFF000000	# Endere�o inicial da Mem�ria VGA - Frame 0
		li t2,0xFF012C00	# Endereco final da Mem�ria VGA
		la s1, loadscreen
		addi s1, s1 , 8
		
		PRINTLOADSCREEN:
		beq t1, t2, LOADSCREENMUS
		lw t3,0(s1)
		sw t3,0(t1)			# Escreve os pixels na mem�ria VGA
		addi t1,t1,4			# Incrementa o endere�o de mem�ria de destino
		addi s1,s1,4			# Incrementa o endere�o de mem�ria de origem
		j PRINTLOADSCREEN		# Repete o loop para o pr�ximo conjunto de pixels

LOADSCREENMUS:
		la s0, NUMSCR       # define o endere�o do n�mero de notas
	    	lw s1, 0(s0)     # le o numero de notas
	    	la s0, NOTASSCR     # define o endere�o das notas
	    	li t0, 0         # zera o contador de notas
	
	    	la s2, NUM2SCR      # define o endere�o do n�mero de notas2
	    	lw s3, 0(s2)     # le o numero de notas2
	    	la s2, NOTAS2SCR    # define o endere�o de notas2
	    	li t1, 0         # zera o contador de notas2
	
	    	li a2, 32        # define o instrumento para notas
	    	li a4, 87       # define o instrumento para notas2
	    	li a3, 100       # define o volume para notas
	    	li s4, 0	     # 16 para contagem de notas2
	    
	INST_DOISSCR: 
	    	lw a6, 0(s2)     # le o valor da segunda nota
	    	lw a7, 4(s2)     # le a duracao da segunda nota
	    	mv a0, a6        # move valor da segunda nota para a0
	    	mv a1, a7        # move duracao da segunda nota para a1
	    	li a7, 31        # define a chamada de syscall para tocar nota
	    	ecall            # toca a segunda nota
	
	    	addi s4, s4, 8   # zera o contador de notas2
	    	addi s2, s2, 8   # incrementa para o endere�o da pr�xima nota
	    	addi t1, t1, 1   # incrementa o contador de notas
	
	LOOP_MUSICASCR:  
	  	 
	    	beq t0, s1, FIMSCR     # se o contador chegou no final, v� para REINICIA
	    	beq t0, s4, INST_DOISSCR    # se o contador2 chegou em 16, v� para DOIS
	    
	    	lw a0, 0(s0)        # le o valor da nota
	    	lw a1, 4(s0)        # le a duracao da nota
	    	li a7, 31           # define a chamada de syscall para tocar nota
	    	ecall               # toca a nota
	
	    	addi a1, a1, -5	    # reduzir a pausa pra evitar pausa abrupta nas notas
	    	mv a0, a1           # move duracao da nota para a pausa
	    	li a7, 32           # define a chamada de syscal para pausa
	    	ecall               # realiza uma pausa de a0 ms
	
	    	addi s0, s0, 8      # incrementa para o endere�o da pr�xima nota
	    	addi t0, t0, 1      # incrementa o contador de notas
	
	    	j LOOP_MUSICASCR      # volta ao loop
	
	FIMSCR:
		j GAME			# volta ao inicio

		
GAME:		li s11,0xFF00A58C 	# Inicializador frames do m�dico (N�O MEXER DE LUGAR)
		li t1,0xFF000000	# Endere�o inicial da Mem�ria VGA - Frame 0
		li t2,0xFF012C00	# Endereco final da Mem�ria VGA
LOADMAPA:		
		la t3, MAPAJOGADO	# Carrega endere�o do label MAPAJOGADO
		lw t0, 0(t3)	# Carrega conteudo de MAPAJOGADO para a mem�ria
		beqz t0, MAPAINIT # Se for 0, pula pra MAPINIT
		
		la s1, MAPA2	# Se diferente de 0, carrega o mapa 2
		addi s1, s1 8		# Ajusta o endere�o para o primeiro pixel ap�s os metadados
		j MUSICARESET		# Pula MAPAINIT e segue o c�digo
		
MAPAINIT:
		la s1, MAPA	# Carrega o endere�o dos dados do mapa de moedas
		addi s1,s1,8		# Ajusta o endere�o para o primeiro pixel ap�s os metadados
		
# Reinicia a m�sica quando todas as notas foram tocadas
# Retorna ao in�cio da sequ�ncia de notas e reinicia o contador de notas tocadas
MUSICARESET:	
			li s9, 0         # Reinicia o contador de notas (s9) para o in�cio
			la t3, NUM       # Carrega o endere�o que armazena o n�mero total de notas
		    	lw t4, 0(t3)	 # Carrega o n�mero total de notas na m�sica em t4
		    	
		    	la t3, NOTAS		# Carrega o endere�o da sequ�ncia de notas iniciais
		    	la t6, ENDENOTAS	# Carrega o endere�o onde o ponteiro atual da nota � armazenado
	    		sw t3, 0(t6)		# Redefine o ponteiro de notas para o in�cio da sequ�ncia de notas
	    		
	    		li t3, 0		# Inicializa o registrador t3 para 0
	    		la t0, CONTNOTAS	# Carrega o endere�o onde o contador de notas � armazenado
	    		sw t3, 0(t0)		# Reinicia o contador de notas tocadas (armazena 0 no endere�o de CONTNOTAS)
	    		
		    	j MUSICALOOP	# Salta para o in�cio do loop principal da m�sica para come�ar a tocar novamente
		
	#DISPLAY (1/2)
		
DISPLAYSTR:	
		li t1,0xFF000000	# Carrega o endere�o incial da mem�ria VGA (Frame 0) em t1
		li t2,0xFF012C00	# Carrega o endere�o final da mem�ria VGA em t2
		la t3, MAPAJOGADO	# Carrega o endere�o de MAPAJOGADO para t3
		lw t0, 0(t3)	# Carrega o dado de MAPAJOGADO para t0
		bnez t0, MUDAMAPA	# Se MAPAJOGADO diferente de zero, v� para MUDAMAPA
		
		la s1, MAPA		# Carrega o endere�o base dos dados da tela (mapa) na mem�ria para o registrador s1
		addi s1,s1,8		# Ajusta o ponteiro para ignorar as informa��es de nlin e ncol (primeiro dado �til)
		j DISPLAYSTRP2
		
		MUDAMAPA:
		la s1, MAPA2	# Carrega o endere�o base dos dados da tela (mapa) na mem�ria para o registrador s1
		addi s1, s1, 8		# Ajusta o ponteiro para ignorar as informa��es de nlin e ncol (primeiro dado �til)
		
		DISPLAYSTRP2:	
		li t5, 6		# Carrega o valor 4 em t5 para compara��o
		bne s9, t5, DISPLAYPRINTMAPA	# Verifica se o valor em s9 � diferente de 4; se for, salta para DISPLAYPRINTMAPA	
			
	#MUSICA
	
# Controle da m�sica: s9 � o contador de notas, t3 armazena o endere�o da pr�xima nota
MUSICASTR:
		li s9, 0			# Reseta o contador de notas
		la t3, NUM       		# Carrega o endere�o do n�mero de notas
		lw t4, 0(t3)     		# L� o n�mero de notas para t4
	    	la t5, CONTNOTAS		# Carrega o endere�o do contador de notas
	    	lw t0, 0(t5)			# L� o contador de notas atual
	    	beq t0, t4, MUSICARESET    	# Se todas as notas foram tocadas, reseta a m�sica
	    
# Toca a nota atual a partir da sequ�ncia em NOTAS
MUSICALOOP:
	    	la t5, CONTNOTAS	# Carrega o endere�o do contador de notas tocadas em t5
	    	lw t0, 0(t5)		# Carrega o contador de notas tocadas em t0
	    	
	    	la t4, ENDENOTAS	# Carrega o endere�o do ponteiro para a nota atual em t4
	    	lw t3, 0(t4)     	# Carrega o ponteiro para a nota atual em t3
	    	
	    	lw a0, 0(t3)        	# Carrega o valor da nota atual em a0
	    	lw a1, 4(t3)      	# Carrega a dura��o da nota atual em a1
	    	
	    	li a2, 32        	# Define o instrumento (32) em a2
	    	li a3, 60       	# Define o volume m�ximo (127) em a3
	    	li a7, 31           	# Carrega o c�digo de syscall para tocar a nota em a7
	    	ecall               	# Executa a syscall para tocar a nota com os par�metros dados
	
	    	# Incrementa os contadores e ponteiros para a pr�xima nota
	    	addi t3, t3, 8      # Move o ponteiro para o pr�ximo par nota/dura��o
	    	addi t0, t0, 1      # Incrementa o contador de notas tocadas
	    	
	    	# Salva os contadores e ponteiros atualizados
	    	#la t4, ENDENOTAS	# Carrega o endere�o do ponteiro para a nota atual em t6
	    	sw t3, 0(t4)		# Salva o ponteiro atualizado para a pr�xima nota
	    	
	    	#la t5, CONTNOTAS	# Carrega o endere�o do contador de notas tocadas em t5 
	    	sw t0, 0(t5)		# Salva o contador de notas tocadas atualizado
    		
    #DISPLAY (2/2)
	
# Loop para desenhar o mapa na tela
DISPLAYPRINTMAPA: 
			la s3, INIT
			lw s3, 0(s3)
			bnez s3, DISPLAYSCORE	
			beq t1,t2,DISPLAYSCORE	# Se alcan�ou o endere�o final, v� para a pr�xima se��o de display
			lw t3,0(s1)
			sw t3,0(t1)			# Escreve os pixels na mem�ria VGA
			addi t1,t1,4			# Incrementa o endere�o de mem�ria de destino
			addi s1,s1,4			# Incrementa o endere�o de mem�ria de origem
			j DISPLAYPRINTMAPA		# Repete o loop para o pr�ximo conjunto de pixels

			
DISPLAYSCORE:	# Carrega o score e printa na tela
			la t6, SCORECONT
			lw a0, 0(t6)
			li a7, 101
			li a1, 260
			li a2, 40
			li a3, 0xFF00
			li a4, 0
			ecall
			

DISPLAYSTRMEDICO:		
			mv t1, s11	# Move o valor de s11 para t1 (in�cio do display na mem�ria)
				
			# Sele��o de Sprite baseada no valor de s9
			li t5, 3		# Define o valor limite (3) para sele��o de sprite em t5
			bgt s9, t5, SPRITE1	# Se s9 for maior que 3, pula para o r�tulo SPRITE1 para selecionar o sprite 1
			la s1, leandro2		# Caso contr�rio, carrega o endere�o de 'medico_2' em s1 (seleciona o sprite 2)
			j AFTERSPRITE		# Pula para o r�tulo AFTERSPRITE para continuar a execu��o
			
	SPRITE1:	
			la s1, leandro1		# Carrega o endere�o de 'medico_1' em s1 (seleciona o sprite 1)
			
	AFTERSPRITE:	
			addi s1, s1, 8		# Ajusta o ponteiro s1 para ignorar os primeiros 8 bytes de metadados	
			li t4, 0		# Incializa o contador de linha j (t4) para a exibi��o	
			li t5, 0		# Incializa o contador de coluna i (t5) para a exibi��o	
			li t6, 16		# Carrega o "n�mero m�gico" 12 em t6 (possivelmente o n�mero de sprites ou linhas)
				
			# Verifica se deve tocar a m�sica	
			li s8, 6		# Carrega o valor de 4 em s8
			beq s9, s8, MUSICASTR	# Se s9 for igual a 4, pula para o r�tulo MUSICASTR para iniciar a m�sica 
		
DISPLAYPRINTMEDICO:	
			beq t5, t6, DISPLAYPULALINHA	# Se o contador de colunas (t5) atingir o valor limite (t6), pula para o r�tulo DISPLAYLINHA para iniciar uma nova linha
			beq t4, t6, KEY2	# Se o contador de linhas (t4) atingir o valor limite (t6), pula para o r�tulo KEY2 para exibir o pr�ximo sprite ou elemento	
		
			lw t3, 0(s1)		# Carrega um pixel ou grupo de pixels do endere�o atual da sprite (s1) para t3
			sw t3, 0(t1)		# Armazena o valor de t3 na posi��o atual da mem�ria VGA (t1) para exibir o pixel
			addi t1, t1, 4		# Incrementa o endere�o de destino (t1) em 4 bytes para apontar para o pr�ximo pixel na mem�ria VGA
			addi s1, s1, 4		# Incrementa o endere�o de origem (s1) em 4 bytes para apontar para o pr�ximo pixel na sprite
			addi t5, t5, 4		# Incrementa o contador de colunas (t5) em 4 para avan�ar para a pr�xima coluna
			j DISPLAYPRINTMEDICO	# Salta de volta para DISPLAYPRINTMEDICO para continuar exibindo a linha atual
		
DISPLAYPULALINHA:	
			addi t1, t1, 304	# Incrementa o endere�o de destino na mem�ria VGA (t1) para a pr�xima linha na tela (largura da tela em pixels)
			addi t4, t4, 1		# Incrementa o contador de linhas (t4) para rastrear a nova linha que est� sendo desenhada
			addi, t5, zero, 0	# Reinicia o contador de colunas (t5) para zero, come�ando uma nova linha da primeira coluna
			j DISPLAYPRINTMEDICO	# Salta de volta para DISPLAYPRINTMEDICO para continuar desenhando a partir da nova linha
			
			
	# KEYPOLL: Rotina para verificar e armazenar teclas pressionadas (WASD)
KEY2:	
	li t1, 0xFF200000		# Carrega o endere�o de controle do teclado na vari�vel t1 (KDMMIO) 
	lw t0, 0(t1)			# L� o bit de controle do teclado em t0
	andi t0, t0, 0x0001		# Mascara o bit menos significativo para verificar se uma tecla foi pressionada
   	beq t0, zero, KEYPOLLEND  	# Se n�o h� tecla pressionada (bit � 0), vai para KEYPOLLEND
  	lw t2, 4(t1)  			# L� o valor da tecla pressionada no registrador t2	
  	
  	# Verifica se a tecla pressionada � uma das teclas WASD
	li t0, 'w'			# Carrega o valor ASCII de 'w' em t0
	beq t2, t0, STOREKEYPOLL	# Se a tecla pressionada � 'w', vai para STOREKEYPOLL
	li t0, 'a'			# Carrega o valor ASCII de 'a' em t0
  	beq t2, t0, STOREKEYPOLL	# Se a tecla pressionada � 'a', vai para STOREKEYPOLL
 	li t0, 's'			# Carrega o valor ASCII de 's' em t0
	beq t2, t0, STOREKEYPOLL	# Se a tecla pressionada � 's', vai para STOREKEYPOLL
	li t0, 'd'			# Carrega o valor ASCII de 'd' em t0
	beq t2, t0, STOREKEYPOLL	# Se a tecla pressionada � 'd', vai para STOREKEYPOLL
	li t0, 'm'			# Carrega o valor ASCII de 'm' em t0
	beq t2, t0, SKIPLEVEL		# Se a tecla pressionada � 'm', vai para SKIPLEVEL
	li t0, 'n'
	beq t2, t0, BACKLEVEL
	
	j KEYPOLLEND	# Se nenhuma das teclas WASD foi pressionada, vai para KEYPOLLEND
  	
STOREKEYPOLL:  					
		mv s10, t2	# Salva o valor da tecla pressionada no registrador s10 (utilizado para armazenar a tecla atualmente pressionada em KEYPRESS)

KEYPOLLEND:
	
	# Verifica qual tecla foi pressionada para determinar a dire��o do movimento
	# As teclas v�lidas s�o 'W', 'A', 'S', 'D'
	POSSTR:	
		li s7, 0 	#flag
				
		li t1, 'w'
		li t2, 's'
		li t3, 'a'
		li t4, 'd'
		
		beq s10, t1, POSATTCIMA		# Se a tecla � 'W', move para cima
		beq s10, t2, POSATTBAIXO	# Se a tecla � 'S', move para baixo
		beq s10, t3, POSATTESQUERDA	# Se a tecla � 'A', move para a esquerda
		beq s10, t4, POSATTDIREITA	# Se a tecla � 'D', move para a direita
		j POSEND			# Se nenhuma tecla v�lida foi pressionada, termina a verifica��o
		
	# Move o sprite do m�dico para cima na tela
	# Primeiro, verifica se h� colis�es com base nos pixels acima do sprite atual
	# Se n�o houver colis�es, atualiza a posi��o do sprite
	POSATTCIMA: 	
		# Verifica o pixel na posi��o (0, -1) em rela��o ao sprite
		li t0, 0		# Inicializa t0 com 0 para reiniciar o valor de verifica��o
		addi t0, s11, -320	# Calcula o endere�o do pixel acima � esquerda do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria
		li t3, 82
		beq t0, t3, COINCIMA
		li t3, 91
		beq t0, t3, COINCIMA
		li t3, 116
		beq t0, t3, COINCIMA
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (colis�o), n�o atualiza a posi��o e vai para POSEND
		
		# Verifica o pixel na posi��o (7, -1) em rela��o ao sprite
		li t0, 0		# Reinicializa t0 para verificar o pr�ximo pixel
		addi t0, s11, -312	# Calcula o endere�o do pixel acima ao centro do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria
		li t3, 82
		beq t0, t3, COINCIMA
		li t3, 91
		beq t0, t3, COINCIMA
		li t3, 116
		beq t0, t3, COINCIMA
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (colis�o), n�o atualiza a posi��o e vai para POSEND
			
		# Verifica o pixel na posi��o (9, -1) em rela��o ao sprite
		li t0, 0		# Reinicializa t0 para verificar o pr�ximo pixel
		addi t0, s11, -305	# Calcula o endere�o do pixel acima � direita do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria
		li t3, 82
		beq t0, t3, COINCIMA
		li t3, 91
		beq t0, t3, COINCIMA
		li t3, 116
		beq t0, t3, COINCIMA
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (colis�o), n�o atualiza a posi��o e vai para POSEND
		
CIMAEND:	# Atualiza a posi��o do sprite para cima
		addi s11, s11, -320	# Move o sprite para cima ajustando sua coordenada vertical
		la t1, BUFFER
		sw s10, 0(t1)
		li s7, 1
		j POSEND		# Finaliza o movimento e vai para POSEND
		
		COINCIMA:
			la t6, SCORECONT
			lw t0, 0(t6)
			addi t0, t0, 1
			
			li a7, 31
			li a0, 60
			li a1, 200
			li a2, 98
			ecall
			
			li t4, 200
			beq t0, t4, SKIPLEVEL
			sw t0, 0(t6)
			j CIMAEND
			
		
	POSATTBAIXO:	
		# Verifica o pixel na posi��o (0, 11+1) em rela��o ao sprite
		li t5, 5120	# Carrega o deslocamento para acessar o pixel abaixo do canto esquerdo do sprite
		li t0, 0		# Inicializa t0 com 0 para resetar antes da opera��o de endere�o
		add t0, s11, t5		# Calcula o endere�o do pixel abaixo do canto esquerdo do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria
		li t3, 82
		beq t0, t3, COINBAIXO
		li t3, 91
		beq t0, t3, COINBAIXO
		li t3, 116
		beq t0, t3, COINBAIXO
		
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Verifica o pixel na posi��o (5, 11+2) em rela��o ao sprite
		li t5, 5128		# Carrega o deslocamento para acessar o pixel abaixo do centro do sprite
		li t0, 0		# Reinicializa t0 para a pr�xima opera��o de endere�o
		add t0, s11, t5		# Calcula o endere�o do pixel abaixo do centro do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria
		li t3, 82
		beq t0, t3, COINBAIXO
		li t3, 91
		beq t0, t3, COINBAIXO
		li t3, 116
		beq t0, t3, COINBAIXO
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Verifica o pixel na posi��o (11, 11+1) em rela��o ao sprite
		li t5, 5135		# Carrega o deslocamento para acessar o pixel abaixo do canto direito do sprite
		li t0, 0		# Reinicializa t0 para a pr�xima opera��o de endere�o
		add t0, s11, t5		# Calcula o endere�o do pixel abaixo do canto direito do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria
		li t3, 82
		beq t0, t3, COINBAIXO
		li t3, 91
		beq t0, t3, COINBAIXO
		li t3, 116
		beq t0, t3, COINBAIXO
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
		
BAIXOEND:	# Atualiza a posi��o do sprite para baixo	
		addi s11, s11, 320	# Move o sprite para baixo ajustando sua coordenada vertical
		la t1, BUFFER
		sw s10, 0(t1)
		li s7, 1
		j POSEND		# Finaliza o movimento e vai para POSEND
		
		COINBAIXO:
			la t6, SCORECONT
			lw t0, 0(t6)
			addi t0, t0, 1
			
			li a7, 31
			li a0, 60
			li a1, 200
			li a2, 98
			ecall
			
			li t4, 200
			beq t0, t4, SKIPLEVEL
			sw t0, 0(t6)
			j BAIXOEND

	POSATTESQUERDA: 	
		# Verifica o pixel na posi��o (-1, 0) � esquerda do sprite
		li t0, 0		# Inicializa t0 com 0 antes da opera��o de endere�o
		addi t0, s11, -1	# Calcula o endere�o do pixel � esquerda do canto superior do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel na posi��o calculada
		li t5, 82		# Carrega o valor que representa um estado "moeda"
		beq t0, t5, COINESQ	
		li t5, 91
		beq t0, t5, COINESQ
		li t5, 116
		beq t0, t5, COINESQ	
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Verifica o pixel na posi��o (-1, 11) � esquerda do sprite
		li t0, 0		# Reinicializa t0 para a pr�xima opera��o de endere�o
		li t5, 4799		# Carrega o deslocamento para acessar o pixel � esquerda do canto inferior do sprite
		add t0, s11, t5		# Calcula o endere�o do pixel � esquerda do canto inferior do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel na posi��o calculada	
		li t5, 82		# Carrega o valor que representa um estado "moeda"
		beq t0, t5, COINESQ	
		li t5, 91
		beq t0, t5, COINESQ
		li t5, 116
		beq t0, t5, COINESQ		
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Verifica o pixel na posi��o (-1, 4) � esquerda do sprite
		li t0, 0		# Reinicializa t0 para a pr�xima opera��o de endere�o
		li t5, 2559		# Carrega o deslocamento para acessar o pixel � esquerda do meio do sprite
		add t0, s11, t5		# Calcula o endere�o do pixel � esquerda do meio do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel na posi��o calculada
		li t5, 82		# Carrega o valor que representa um estado "moeda"
		beq t0, t5, COINESQ	
		li t5, 91
		beq t0, t5, COINESQ
		li t5, 116
		beq t0, t5, COINESQ
			
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Atualiza a posi��o do sprite para a esquerda
ESQEND:	addi s11, s11, -1	# Move o sprite uma unidade para a esquerda
		la t1, BUFFER
		sw s10, 0(t1)
		li s7, 1
		j POSEND		# Finaliza o movimento e vai para POSEND
		
		COINESQ:
			la t6, SCORECONT
			lw t0, 0(t6)
			addi t0, t0, 1
			
			li a7, 31
			li a0, 60
			li a1, 200
			li a2, 98
			ecall
			
			li t4, 200
			beq t0, t4, SKIPLEVEL
			sw t0, 0(t6)
			j ESQEND
			
	POSATTDIREITA: 
		# Verifica o pixel na posi��o (11+1, 0) � direita do sprite
		li t0, 0		# Inicializa t0 com 0 antes da opera��o de endere�o
		addi t0, s11, 16	# Calcula o endere�o do pixel � direita do canto superior do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria para verificar colis�o
		li t5, 82		# Carrega o valor que representa um estado "moeda"
		beq t0, t5, COINDIR	
		li t5, 91
		beq t0, t5, COINDIR
		li t5, 116
		beq t0, t5, COINDIR
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Verifica o pixel na posi��o (11+1, 11+1) � direita do sprite
		li t0, 0		# Reinicializa t0 para a pr�xima opera��o de endere�o
		li t5, 4816		# Carrega o deslocamento para acessar o pixel � direita do canto inferior do sprite
		add t0, s11, t5		# Calcula o endere�o do pixel � direita do canto inferior do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria para verificar colis�o
		li t5, 82		# Carrega o valor que representa um estado "moeda"
		beq t0, t5, COINDIR	
		li t5, 91
		beq t0, t5, COINDIR
		li t5, 116
		beq t0, t5, COINDIR
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Verifica o pixel na posi��o (11+1, 4) � direita do sprite
		li t0, 0		# Reinicializa t0 para a pr�xima opera��o de endere�o
		li t5, 2576		# Carrega o deslocamento para acessar o pixel � direita do meio superior do sprite
		add t0, s11, t5		# Calcula o endere�o do pixel � direita do meio superior do sprite
		lb t0, 0(t0)		# Carrega o valor do pixel da mem�ria para verificar colis�o
		li t5, 82		# Carrega o valor que representa um estado "moeda"
		beq t0, t5, COINDIR	
		li t5, 91
		beq t0, t5, COINDIR
		li t5, 116
		beq t0, t5, COINDIR
		bnez t0, POSEND		# Se o pixel n�o estiver vazio (indica colis�o), salta para POSEND para interromper o movimento
			
		# Atualiza a posi��o do sprite para a direita
DIREND:	addi s11, s11, 1	# Move o sprite uma unidade para a direita
		la t1, BUFFER
		sw s10, 0(t1)
		li s7, 1
		j POSEND		# Finaliza o movimento e vai para POSEND	
		
		COINDIR:
			la t6, SCORECONT
			lw t5, 0(t6)
			addi t5, t5, 1
			
			li a7, 31
			li a0, 60
			li a1, 200
			li a2, 98
			ecall
			
			li t4, 200
			beq t5, t4, SKIPLEVEL
			sw t5, 0(t6)
			j DIREND
	
				
	POSEND: 
		addi s9, s9, 1	# Incrementa o contador `s9` em 1; usado para contar o n�mero de movimentos ou a��es realizadas.
		#bnez s7, POSEND2
		#la t0, BUFFER
		#lw s10, 0(t0)
		#j POSSTR
	POSEND2:	
		li a7, 32	# Carrega o valor 32 no registrador `a7`; Syscall de timesleep;
		li a0, 35	# Carrega o valor 35 no registrador `a0`; Tempo de timesleep
		ecall		# Chama a syscall do timesleep
		la s7, INIT
		li t0, 1
		sw t0, 0(s7)
		j DISPLAYSTR	# Salta para o r�tulo `DISPLAYSTR` para continuar a execu��o do programa. 
		
FIM:	
	li a7, 32		# Carrega o valor 32 no registrador `a7`; este valor indica a syscall espec�fica que ser� chamada.	
	li a0, 100		# Carrega o valor 100 no registrador `a0`; este valor � passado como um argumento para a syscall. Pode representar uma quantidade de tempo para esperar ou outra fun��o espec�fica.
	j DISPLAYSTRMEDICO	# Salta para o r�tulo `DISPLAYSTRMEDICO` para continuar a execu��o do programa. Isso sugere que, ap�s o t�rmino desta rotina, o controle � passado para a l�gica de exibi��o relacionada ao m�dico.
	
SKIPLEVEL: 	la t6, SCORECONT
		sw zero, 0(t6)
		
		la t0, FASE
		lw t1, 0(t0)
		addi t1, t1, 1
		sw t1, 0(t0)
		
		la t0, FASE
		lw t1, 0(t0)
		li t0, 3
		beq t1, t0, ENDING

		li t1,0xFF000000	# Carrega o endere�o incial da mem�ria VGA (Frame 0) em t1
		li t2,0xFF012C00	# Carrega o endere�o final da mem�ria VGA em t2
		la s7, nextlevel
		addi s7, s7, 8
		PRINTNXTLEVEL: 
		beq t1, t2, TROCAMAPA#SFX
		lw t0, 0(s7)
		sw t0, 0(t1)			# Escreve os pixels na mem�ria VGA
		addi t1,t1,4			# Incrementa o endere�o de mem�ria de destino
		addi s7,s7,4			# Incrementa o endere�o de mem�ria de origem
		j PRINTNXTLEVEL		# Repete o loop para o pr�ximo conjunto de pixels

		TROCAMAPA:
		# Set MAPAJOGADO para 1
		li a7, 32
		li a0, 2000
		ecall
		li s7, 1
		la t0, MAPAJOGADO
		sw s7, 0(t0)
		la s7, INIT
		sw zero, 0(s7)
		j GAME	#Volta pro inicio do jogo
		
BACKLEVEL:	li a7, 32
		li a0, 2000
		ecall
		li s7, 0
		la t0, MAPAJOGADO
		sw s7, 0(t0)
		la s7, INIT
		sw zero, 0(s7)
		j GAME	#Volta pro inicio do jogo	
		
ENDING: 	li t1,0xFF000000	# Endere�o inicial da Mem�ria VGA - Frame 0
		li t2,0xFF012C00	# Endereco final da Mem�ria VGA
		la s1, endscreen
		addi s1, s1 , 8
		
		PRINTENDSCREEN:
		beq t1, t2, CABOU
		lw t3,0(s1)
		sw t3,0(t1)			# Escreve os pixels na mem�ria VGA
		addi t1,t1,4			# Incrementa o endere�o de mem�ria de destino
		addi s1,s1,4			# Incrementa o endere�o de mem�ria de origem
		j PRINTENDSCREEN		# Repete o loop para o pr�ximo conjunto de pixels
		
CABOU: 	li a7, 32
		li a0, 4000
		ecall
		li a7, 10
		ecall
	
				
.include "SYSTEMv21.s"
			

