[org 0x7c00]         ; BIOS loads bootloader at this memory address

init:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Set video mode to 80x25 text mode and clear screen
    mov ax, 0x0003
    int 0x10

    ; Hide text cursor (move it out of screen limits)
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

    ; --- DRAW TEXT-GUI BACKGROUND & BORDERS ---
    ; Draw background fill (Light cyan background with blue text attribute)
    mov ax, 0x0600      ; Scroll up window function
    mov bh, 0x31        ; Background Cyan (3), Text Blue (1)
    mov cx, 0x0000      ; Top-left corner (0,0)
    mov dx, 0x184f      ; Bottom-right corner (24,79)
    int 0x10

    ; Draw Main Header Window / Top Banner
    mov ax, 0x0600
    mov bh, 0x1f        ; Blue Background (1), White Text (F)
    mov cx, 0x0000      ; (0,0)
    mov dx, 0x024f      ; (2,79)
    int 0x10

    ; Print Header Text "WINDOWS 12 - TEXT GUI OS"
    mov ah, 0x02        ; Set cursor position
    mov bh, 0           ; Page number
    mov dh, 1           ; Row 1
    mov dl, 27          ; Column 27 (Centered)
    int 0x10
    mov si, text_title
    call print_string

    ; Draw Center Dialog Box for App Options
    mov ax, 0x0600
    mov bh, 0xf0        ; White Background (F), Black Text (0)
    mov cx, 0x0614      ; Row 6, Col 20
    mov dx, 0x103c      ; Row 16, Col 60
    int 0x10

    ; Print Welcome Label inside box
    mov dh, 8
    mov dl, 22
    call set_cursor
    mov si, text_welcome
    call print_string

    ; Print Button Option 1
    mov dh, 11
    mov dl, 24
    call set_cursor
    mov si, text_opt1
    call print_string

    ; Print Button Option 2
    mov dh, 13
    mov dl, 24
    call set_cursor
    mov si, text_opt2
    call print_string

    ; Draw Bottom Taskbar / Status Bar
    mov ax, 0x0600
    mov bh, 0x70        ; Light Gray Background (7), Black Text (0)
    mov cx, 0x1700      ; Row 23, Col 0
    mov dx, 0x184f      ; Row 24, Col 79
    int 0x10

    ; Print Taskbar Info
    mov dh, 23
    mov dl, 2
    call set_cursor
    mov si, text_taskbar
    call print_string

main_loop:
    ; Wait for key press
    mov ah, 0x00
    int 0x16

    ; Check if '1' is pressed
    cmp al, '1'
    je action_app
    ; Check if '2' is pressed
    cmp al, '2'
    je action_reboot

    jmp main_loop

action_app:
    ; Trigger Visual Feedback: Open a simulation pop-up window
    mov ax, 0x0600
    mov bh, 0x4f        ; Red Background (4), White Text (F)
    mov cx, 0x0a19      ; Row 10, Col 25
    mov dx, 0x0e37      ; Row 14, Col 55
    int 0x10

    mov dh, 12
    mov dl, 28
    call set_cursor
    mov si, text_app_running
    call print_string
    jmp main_loop

action_reboot:
    ; Far jump to BIOS reset vector to reboot computer
    jmp 0xffff:0x0000

; --- HELPER FUNCTIONS ---
print_string:
    lodsb               ; Load byte at DS:SI into AL and increment SI
    or al, al           ; Check if character is 0 (Null terminator)
    jz .done
    mov ah, 0x0e        ; BIOS teletype output function
    mov bl, 0x07        ; Normal attribute
    int 0x10
    jmp print_string
.done:
    ret

set_cursor:
    mov ah, 0x02
    mov bh, 0           ; Page 0
    int 0x10
    ret

; --- DATA SECTION (STRINGS) ---
text_title       db 'WINDOWS 12 - ASM PROTOTYPE OS', 0
text_welcome     db '--- GUI APPS MANAGER ---', 0
text_opt1        db '[1] Launch Hello App', 0
text_opt2        db '[2] Reboot Computer', 0
text_taskbar     db 'Status: Ready | Press Key [1-2] to interact...', 0
text_app_running db 'App Running Successfully!', 0

; --- BOOT SECTOR PADDING ---
times 510-($-$$) db 0
dw 0xaa55             ; Boot signature
