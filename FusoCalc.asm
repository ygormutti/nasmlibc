%include "macros.i"
%include "linux.i"
%include "stdio.i"
%include "FusoCommon.i"

section .data
    nome_programa    char "cálculos",0
    msg_nome_arquivo char LN,"Arquivo de cidades ou ENTER para encerrar      : ",0
    msg_nome_cidade  char "Nome da cidade local ou ENTER para encerrar    : ",0
    msg_horario      char "Horário real: ENTER; Simulado: horas e minutos : ",0
    msg_sucesso      char LN,">>> Fim da execução <<<",0
    msg_greenwich	 char "Horário de Greenwich:   ",0
    ui_cabecalho	 char LN,"Cidade               Longitude Zona H.Terra H.Legal Observações",LN,0
    msg_erro_arquivo char "Erro ao abrir o arquivo especificado.",0
    msg_amanha		 char " amanhã   ",0
    msg_ontem		 char " ontem    ",0
    ui_hoje			 char "          ",0
    msg_verao		 char "horário de verão",0
    msg_inverno		 char "horário de inverno",0
    simulado		 char false

section .bss
	local		resb 	cidade_t_size
	utc			resint 	1

section .text
    global _start
    extern exit, puts, imprimir_cabecalho, ler_info, open, read, close, print
    extern ler_nome, ler_longitude, ler_especial, ler_info, putchar, memcpy
    extern strlen, strchr, atoi, ltrim, time, mktimespan, getdatepart
    extern gettimepart, ctimeonly, itoa, strpadr, formati, strcpy, ctime
    extern strpadl, gethours, getminutes, mklocal
    ; Variáveis globais
    extern cidade, buffer, fd, msg_entrada_invalida  

; arg(0) - graus
; arg(1) - minutos
; arg(2) - orientação
; retorna um inteiro com sinal representando a longitude em minutos
mklongitude:
	prologue
	zero nax
	mov al, arg(0)
	mov nbx, 60
	mul nbx
	zero nbx
	mov bl, arg(1)
	add nax, nbx
	cmp CHAR_SIZE arg(2), 'W'
	jne .fim
	neg nax
.fim:
	epilogue
	
; arg(0) - inteiro com sinal representando a longitude em minutos
; a cada 1' o horário muda 4s
mkhterrestre:
	prologue
	mov eax, arg(0)
	mov ecx, 4
	imul ecx ; obtém em eax a qtd de segundos
	add eax, [utc]
	epilogue

; arg(0) - horário especial ('V'-verão, 'I'-inverno, ' '-nenhum)
; retorna -1 para 'I', 0 para ' ' e '1' para verão
mkespecial:
	prologue
	mov bl, arg(0)
	zero nax
	cmp bl, 'V'
	je .verao
	cmp bl, 'I'
	jne .fim
	dec nax
	jmp .fim
.verao:
	inc nax
.fim:
	epilogue

; arg(0) - inteiro com sinal representando a longitude em minutos
; arg(1) - horário especial ('V'-verão, 'I'-inverno, ' '-nenhum)
; retorna um inteiro com sinal representando a zona horária
mkzona:
	prologue
	mov nax, arg(0)
	mov nbx, nax ; nbx guarda o sinal da longitude
	cmp nax, 0
	jge .nao_negativa
	neg nax 
.nao_negativa:
	sub nax, 450 ; a zona 0 vai de -450 a 450 minutos
	cmp nax, 0
	jg .calcular
	zero nax ; retval 0
	jmp .especial
.calcular:
	add nax, 450
	mov ncx, 900 ; uma zona possui 900 minutos de longitude
	zero ndx
	div ncx
	cmp ndx, 450
	jb .sinal
	inc nax ; "arredonda" a zona
.sinal:
    cmp nbx, 0
	jge .especial
	neg nax
.especial:
	mov nbx, nax
	call mkespecial, arg(1)
	add nbx, nax
.fim:
	retval nbx
	epilogue

ler_horario:
    prologue
.loop_validacao:
    call ler_info, msg_horario
    mov nsi, buffer
    call strlen, nsi
	cmp nax, 0
	je .fim
	call atoi, nsi
	cmp nax, 23
	ja .erro
	mov nbx, nax ; guarda as horas em nbx
	call strchr, nsi, ' ' ; acha o espaço
	cmp nax, NULL
	je .erro
	mov nsi, nax
	call ltrim, nsi
	call strlen, nsi
	cmp nax, 0
	je .erro
	call atoi, nsi
	cmp nax, 59
	ja .erro
	;mov ndi, nax ; guarda os minutos em ndi
	;call calcular_utc, nbx, ndi
	mov CHAR_SIZE [simulado], true
	call mktimespan, 0, nbx, nax, 0
	jmp .fim
.erro:
	call puts, msg_entrada_invalida
	jmp .loop_validacao
;.sistema:
	;call time, NULL
	;mov [utc], eax
.fim:
    epilogue
    
; arg(0) - timespan da hora local
calcular_utc:
	prologue
	mov al, [simulado]
	cmp al, true
	jne .sistema
	mov nbx, arg(0)
	call mklongitude, [cidade+graus], [cidade+minutos], [cidade+orientacao]
	call mkzona, nax, [cidade+especial]
	neg nax
	call mktimespan, 0, nax, 0, 0 ; dias, horas, minutos, segundos
	add nbx, nax
	call time, NULL
	call getdatepart, nax
	add nax, nbx ; soma a parte da data UTC com o timespan
	jmp .fim
.sistema:
	call time, NULL
.fim:
	mov [utc], eax
	epilogue

; arg(0) - struct contendo os dados da cidade
imprimir_dados_cidade:
    prologue
    mov nsi, arg(0)
    mov nbx, buffer
    call memcpy, buffer, nsi+nome, LEN_NOME
    add nbx, LEN_NOME
    mov CHAR_SIZE [nbx], 0
    call strpadr, buffer, ' ', LEN_NOME + 1
    call print, buffer ; imprime o nome
    zero nax
    mov al, [nsi+graus]
    call itoa, nax, buffer
    call formati, buffer, FMT_SPACE, 4, NULL, NULL
    call print, buffer ; imprime os graus
    call putchar, '.'
    zero nax
    mov al, [nsi+minutos]
    call itoa, nax, buffer
    call formati, buffer, FMT_ZERO, 2, NULL, NULL
    call print, buffer ; imprime os minutos
    call putchar, "'"
    zero nax
    mov al, [nsi+orientacao]
    call putchar, nax ; imprime a orientação
    call mklongitude, [nsi+graus], [nsi+minutos], [nsi+orientacao]
    mov nbx, nax ; salva a longitude
    call mkzona, nax, [nsi+especial]
    call itoa, nax, buffer
    call formati, buffer, FMT_SPACE, 5, NULL, NULL
    call print, buffer ; imprime a zona
    call mkhterrestre, nbx
    call ctimeonly, nax
    call strcpy, buffer, nax
    call strpadl, buffer, ' ', 8
    call print, buffer ; imprime a hora terrestre
    call mkzona, nbx, [nsi+especial]
    call mklocal, [utc], nax
    mov nbx, nax
    call ctimeonly, nax
    call strcpy, buffer, nax
    call strpadl, buffer, ' ', 8
    call print, buffer ; imprime a hora local
    call getdatepart, nbx
    mov nbx, nax ; nbx contém a data local
    call time, NULL
    call getdatepart, nax
    cmp nbx, nax
    jb .ontem
    ja .amanha
    mov nax, ui_hoje
    jmp .especial
.ontem:
	mov nax, msg_ontem
	jmp .especial
.amanha:
	mov nax, msg_amanha
.especial:
	call print, nax ; imprime se é ontem ou amanhã
	mov al, [nsi+especial]
	cmp al, 'V'
	je .verao
	cmp al, 'I'
	jne .fim
	call print, msg_inverno ; imprime se for inverno
	jmp .fim
.verao:
	call print, msg_verao  ; imprime se for verão
.fim:
    call putchar, LN
    epilogue

_start:
    prologue
    call imprimir_cabecalho, nome_programa
    call ler_nome, msg_nome_cidade
    cmp nax, 0
    je .end
    call ler_longitude
    call ler_horario
    mov nbx, nax
    call ler_especial
    call calcular_utc, nbx
    call memcpy, local, cidade, cidade_t_size
.abrir_arquivo:
    call ler_info, msg_nome_arquivo
    cmp nax, 0
    je .end
    call open, buffer, O_RDONLY, NULL
    cmp eax, 0 ; open retorna valores menores que -1 em caso de erro
    jge .aberto
    call puts, msg_erro_arquivo
    jmp .abrir_arquivo
.aberto:
    mov [fd], eax
    call imprimir_cabecalho, nome_programa
    call print, msg_greenwich
    mov nax, [utc]
    call ctimeonly, nax, 0
    call puts, nax
    call puts, ui_cabecalho
    call imprimir_dados_cidade, local
    call putchar, LN
.imprimir_cidades:
	zero nax
	mov eax, [fd]
	call read, eax, cidade, cidade_t_size
	cmp nax, cidade_t_size
	jl .eof
    call imprimir_dados_cidade, cidade
    jmp .imprimir_cidades
.eof:
    zero nax
    mov eax, [fd]
    call close, nax
    jmp .abrir_arquivo
.end:
	call puts, msg_sucesso
    call exit, nax
    epilogue
