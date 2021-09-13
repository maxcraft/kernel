%ifndef AP_INIT_INC
%define AP_INIT_INC

%define REAL_BASE 8000h

%ifndef AP_INIT_
	extern ap_init, ap_init_end, ap_hello_str
%else
	global ap_init, ap_init_end, ap_hello_str
%endif ; AP_INIT_

%endif ; AP_INIT_INC
