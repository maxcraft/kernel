%ifndef VGA_TEXT_32_INC
%define VGA_TEXT_32_INC

extern vga_text_clear, vga_text_scroll_up, vga_text_scroll_down, vga_text_puts, vga_text_init
extern vga_text_set_color, vga_text_get_color

%macro print 0
	call	vga_text_puts
%endmacro

%macro print 1
	mov		esi, %1
	print
%endmacro

%macro print 3
	mov		esi, %1
	add		esi, %2
	add		esi, %3
	print
%endmacro


%endif ; VGA_TEXT_32_INC
