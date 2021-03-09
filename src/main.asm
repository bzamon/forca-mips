.data
	#Descrição do programa: Jogo da Forca, o usuário tenta advinhar a palavra escolhida de uma lista (onde mais palavras podem ser adicionadas!).
	#Autor: Breno Mozan Santos Vale
	entrada: .space 1
	numAcertos: .word 0
	numErros: .word 6			#pode se mudar aqui a quantidade de chances que o usuário pode ter de errar. padrão: 6
	tamPalavra:	.word 0
	palavra: .asciiz "                               "
	letrasCertas: .asciiz "                               "
	letrasChutadas: .asciiz "                                  "
	
	.macro 	print_str (%str) #macro para imprimir certos textos e não precisar repetir código desnecessário
		.data
		string:	.asciiz %str
		.text
		li $v0, 4
		la $a0, string
		syscall
	.end_macro
.text
	main:	
		#carrega os valores iniciasis do jogo
		la $t0, palavra		#carrega em $t0 o valor de palavra atual
		la $t1, letrasCertas	#carrega o campo vazio em letras certas (para encher de -)
		la $t4, letrasChutadas
		li $t7, ' ' #$t7 é utilizado como caracter vazio no código inteiro
				
		
	#caso os registradores não estejam em branco, esses 3 loops vão fazer isso com um código semelhante. (necessário para poder jogar o jogo várias vezes)
	resetPalavra:
		lb $a0, ($t0) #carrega o caracter de $t0
		beq $a0, $t7, resetLetrasChutadas #se estiver em branco pula pro próximo reset
		sb $t7, ($t0)	#caso não esteja, agora está!
		addi $t0, $t0, 1
		bne $a0, $t7, resetPalavra #checa o próximo caracter p ver se está em branco
		
	resetLetrasChutadas: #coloca somente espaços em branco dentro do registrador letrasChutadas
		lb $a0, ($t4)
		beq $a0, $t7, resetLetrasCertas #se estiver em branco pula pro próximo reset
		sb $t7, ($t4)
		addi $t4, $t4, 1
		bne $a0, $t7, resetLetrasChutadas #checa o próximo caracter p ver se está em branco
		
	resetLetrasCertas: #coloca somente espaços em branco dentro do registrador letrasCertas
		lb $a0, ($t1)
		beq $a0, $t7, inicio #se estiver em branco pula para o inicio do jogo
		sb $t7, ($t1)
		addi $t1, $t1, 1
		bne $a0, $t7, resetLetrasCertas #checa o próximo caracter p ver se está em branco
		
	inicio:
		#reseta os valores dos registradores necessários pro jogo
		.include "dicionario.asm" #coloca uma palavra nova em $t0
		li $t9, 0			
		sw $t9, numAcertos #limpa o número de acertos
		sw $t9, tamPalavra #limpa o tamanho da palavra
		li $t9, 6
		sw $t9, numErros	#limpa o número de erros
				
	setup:
		la $t0, palavra #carrega a palavra
		la $t1, letrasCertas #carrega as letrasCertas (no inicio são somente traços e conforme os acertos vai mudando) ex: "----" vira "agua"
		
		li $t8, '-' #necessário para 'codificar' as letras certas em hífens
		
	setupLoop:
		lb $a0, ($t0)
		beq $a0, $t7, prejogo #se for igual ao ' ', já pula logo para nao contar errado ex: agua como 5 letras
		sb $t8, ($t1)
		jal contaLetra #adiciona +1 no contador do tamanho da palavra
		addi $t0, $t0, 1 #pula para próxima posição na string
		addi $t1, $t1, 1
		bne $a0, $t7, setupLoop #quando chegar no ' ' o programa para de contar // dá para usar outros caracteres de parada
		
	prejogo:
		la $t1, letrasCertas #Reseta o index das letras certas
	jogo:	
		print_str("==========================\n")
		print_str("A palavra tem ") #imprime o tamanho da palavra
		lw $a0, tamPalavra   
  		li $v0, 1  
 		syscall			
		print_str(" letras\n")
		li $v0, 4
		la $a0, letrasCertas
		syscall
		print_str("\nNumero de erros restantes: ")
		lw $a0, numErros   
  		li $v0, 1  
 		syscall
 		print_str("\n")
		
		#checa as condições de derrota ou vitoria do jogo
		lw $t2, numErros
		beq $t2, 0, derrota #quando errar X vezes, derrota
		
		lw $t5, tamPalavra
		lw $t6, numAcertos   
		beq $t5, $t6, vitoria #quando o numero de acertos for igual ao tamanho da palavra o jogo termina
		
		
		print_str("\nSua entrada? ")
		li   $v0, 12       
  		syscall

		move $t3, $v0 #salva o conteudo da entrada no $t3
		
	checaRepetidaSetup:
		la $t4, letrasChutadas #pega as letras chutadas e coloca em $t4
		
	checaRepetidaLoop:
		lb $a1, ($t4)
		beq $a1, $t7, checaCertaSetup #se for campo vazio pula logo
		beq $a1, $t3, repetida #se existir letra faz comparação e repete ou não o codigo
		addi $t4, $t4, 1
		bne $a1, $t7, checaRepetidaLoop
		
	checaCertaSetup:
		sb $t3, ($t4) #salva a letra nas letras chutadas
		addi $t4, $t4, 1
		
		move  $t2, $t6 #salva o valor anterior de acertos antes de mudarem
		
		la $t1, letrasCertas #Reseta o index das letras certas
		la $t0, palavra
		
	checaCertaLoop:
		#fazer um se aqui vendo se tá certa ou não
		lb $a2,($t0) #recebe uma letra certa da palavra
		beq $a2, $t7, checaCertaErro #se chegar ao fim da palavra e não tiver uma l
		beq $a2, $t3, checaCertaAcerto #se forem iguais, é um acerto
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		bne $a2, $t7, checaCertaLoop
		
	checaCertaAcerto:
		sb $t3, ($t1) #salva a letra nas letras certas	
		
		addi $t6, $t6, 1 #adiciona um acerto na contagem
		sw $t6, numAcertos 
 		
 		addi $t0, $t0, 1
		addi $t1, $t1, 1
		
		bne $a2, $t7, checaCertaLoop
		
	checaCertaErro:
		print_str("\n")
		bne $t2, $t6, jogo #se houver mudanças no valor de acertos, repete-se o código. Caso contrário, ele conta + um erro (se não acertou é pq errou)
		lw $t2, numErros
		addi $t2, $t2, -1
		sw $t2, numErros
		print_str("\nTa errado!\n")
		j jogo
		
	repetida:
		print_str("\nOpa, letra inserida anteriormente!\n")
		j jogo
		
	acerto:
		lw $s1, numAcertos #carrega o tamanho atual
		addi $s1, $s1, 1 #soma +1 no tamanho atual
		sw $s1, numAcertos #salva o novo tamanho
		j jogo
		
	erro:
		lw $s1, numErros #carrega o tamanho atual
		addi $s1, $s1, 1 #soma +1 no tamanho atual
		sw $s1, numErros #salva o novo tamanho
		beq $s1, 3, derrota
		j jogo
		
	contaLetra:
		lw $s1, tamPalavra #carrega o tamanho atual
		addi $s1, $s1, 1 #soma +1 no tamanho atual
		sw $s1, tamPalavra #salva o novo tamanho
		jr $ra
	
	vitoria:
		print_str("\n\nParabens pela vitoria!")
		j exit
	derrota:
		print_str("\n\nMais sorte da proxima vez!")
		j exit
	exit:
		li $t9, 's'
		print_str("\n\nJogar novamente? (s/n)\n")
		
		li   $v0, 12       
  		syscall
		move $t3, $v0
		
		beq $t3, $t9, main
		
  		li $v0, 10
		syscall
	

			
	
