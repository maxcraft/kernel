section .text
bits 32

%define data_port_0 40h
%define data_port_1 41h
%define data_port_2 42h
%define cmd_port	43h

global pit32_wait_ms


pit32_wait_ms:
	mov		al, 30h
	out		cmd_port, al
	mov		al, 0a9h
	out		data_port_0, al
	mov		al, 4
	out		data_port_0, al

.loop_wait:
	mov		al, 0e2h
	out		cmd_port, al
	in		al, data_port_0
	test	al, 1 << 7
	jnz		.loop_wait

	ret

section .data
