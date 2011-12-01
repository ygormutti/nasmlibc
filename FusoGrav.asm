%include "macros.i"
%include "linux.i"
%include "stdio.i"
%include "FusoCommon.i"

section .data
    nome_programa    char "gravação",0
    msg_nome_arquivo char "Arquivo para gravação ou <ENTER> para encerrar : ",0
    msg_nome_cidade  char "Nome de cidade ou <ENTER> para encerrar        : ",0
    msg_sucesso      char LN,"Arquivo gravado com sucesso",0

section .text
    global _start
    extern exit, puts, imprimir_cabecalho, ler_info, open, write, close
    extern ler_nome, ler_longitude, ler_especial, putchar
    ; Variáveis globais
    extern cidade, buffer, fd    

ler_cidade:
    prologue
    call putchar, LN
    call ler_nome, msg_nome_cidade
    cmp nax, 0
    je .encerrar
    call ler_longitude
    call ler_especial
    zero nax
    mov eax, [fd]
    call write, eax, cidade, cidade_t_size
    retval true
    jmp .fim
.encerrar:
    zero nax ; retval false
.fim:
    epilogue

_start:
    prologue
    call imprimir_cabecalho, nome_programa
    call ler_info, msg_nome_arquivo
    cmp nax, 0
    je .end
    call open, buffer, O_WRONLY | O_CREAT, 640o ; 640o -> rw- r-- ---
    mov [fd], eax
.ler_cidades:
    call ler_cidade
    cmp nax, true
    je .ler_cidades
.gravado:
    zero nax
    mov eax, [fd]
    call close, nax
    call puts, msg_sucesso
.end:
    call exit, 0
    epilogue
