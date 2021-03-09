
.data
	arquivo: .asciiz "data/dicionario.txt"      # nome do arquivo
	buffer: .space 500

.text
import:
	#abrindo o arquivo
	li   $v0, 13       # system call para abrir arquivos
	la   $a0, arquivo  # carrega o nome do arquivo
	li   $a1, 0        # leitura
	li   $a2, 0
	syscall            
	move $s6, $v0      

	#lendo do arquivo
	li   $v0, 14       # system call para ler do arquivo
	move $a0, $s6      
	la   $a1, buffer   
	li   $a2, 500   	 
	syscall            # lê o arquivo

	# Close the file
	li   $v0, 16       # system call para fechar o arquivo
	move $a0, $s6      
	syscall            # fecha o arquivo

	li $v0, 42
	li $a0, 0
	li $a1, 500
	syscall

	addi $t0, $a0, 0x10010030
	li $s1, '\n'
	li $s2, '\r'

	add $a0, $t0, $zero

findNextWord:
	lb $t1, ($t0)
	addi $t0, $t0, 1
	beq $t1, $s1, findWordEnd	#quando encontra um \n, a palvra chegou no fim
	j findNextWord

findWordEnd:
	la $s3, palavra
findEndLoop:
	lb $t1, ($t0)
	addi $t0, $t0, 1
	beq $t1, $s2, newWordFound	#se for o fim do arquivo, ele sai do loop
	sb $t1, ($s3)
	addi $s3, $s3, 1		#se o fim da palavra não for encontrado, ele adiciona para $t1 
	j findEndLoop			#se repete isso até encontrar o fim do arquivo

newWordFound:

	addi $t0, $t0, 1
	li $v0, 4
	la $a0, palavra
	syscall				#se quiser saber qual palavra está sendo utilizada, é só tirar do comentário esse código
	print_str("\n")
