;
; FEMTOTRO 2
;

; Code and graphics by T.M.R/Cosine
; Music by 4-Mat/Ate Bit/Orb


; Femtotro 2 comes in two flavours; the "full fat" build will
; happily fit into under 3.5K, but selecting "compact" mode will
; disable the music (replacing it with the classic "hum") and
; the entire intro runs from $0400 to $07ff. Speaking of which...

compact		= $00		; $00 for music, $01 for hum

; This source code is formatted for the ACME cross assembler from
; http://sourceforge.net/projects/acme-crossass/
; Compression is handled with Exomizer which can be downloaded at
; https://csdb.dk/release/?id=167084

; build.bat will call both to create an assembled file and then the
; crunched release version.


; Select an output filename
		!to "femtotro_2.prg",cbm

; Pull in the music (if required)
!if compact=$00 {
		* = $0800
music		!binary "data/flute_loop.prg",,$02
}

; Constants
scroll_len	= (scroll_end-scroll_text)-$01
border_col	= $0f
screen_col	= $0c
logo_bgnd_col	= $0b
scroll_col	= $0b

; Entry point at $0400
		* = $0400
entry		sei

; Set the border colour and stash the ghostbyte
		lda #border_col
		sta $d020

; Stash and then zero the ghostbyte
		lda $3fff
		sta ghost_stash+$01

		ldx #$00
		stx $3fff

; Set the colour RAM
		lda #screen_col
clear_colour	sta $d800,x
		sta $d900,x
		sta $da00,x
		sta $dae8,x
		inx
		bne clear_colour

; Set the logo's colour RAM and char multicolour
		lda #$09
logo_colour	sta $d918,x
		sta $d958,x
		inx
		bne logo_colour

		lda #$09
		sta $d023

; Set the scroller's colour RAM
		lda #scroll_col
scroll_colour	sta $daa8,x
		inx
		cpx #$27
		bne scroll_colour

; Set up the music or SID hum
!if compact=$00 {
		lda #$00
		jsr music+$48
} else {
		jsr sid_init
}

; The main loop starts here (it skips around a lot!)
main_loop	lda #$67
		cmp $d012
		bne *-$03

; Mask the screen before the logo
		lda #$7b
		sta $d011
		lda #logo_bgnd_col
		sta $d021

		lda #$69
		cmp $d012
		bne *-$03

		lda #$10
		sta $d018

		ldy #$14
		dey
		bne *-$01

		ldx #$00

		lda #$1b
		sta $d011

; Split some registers for the logo
split_loop_1	nop
		ldy #$10
		lda #$0c
		sty $d016
		sta $d022

		nop
		nop
		nop

		ldy #$11
		lda raster_cols+$00,x
		sty $d016
		sta $d022

		ldy #$09
		dey
		bne *-$01
		nop

		ldy #$12
		lda raster_cols+$00,x
		sty $d016
		sta $d022

		ldy #$09
		dey
		bne *-$01
		nop
		nop

		ldy #$13
		lda raster_cols+$01,x
		sty $d016
		sta $d022

		ldy #$09
		dey
		bne *-$01
		nop
		nop

		ldy #$14
		lda raster_cols+$00,x
		sty $d016
		sta $d022

		ldy #$09
		dey
		bne *-$01
		nop
		nop

		ldy #$15
		lda raster_cols+$01,x
		sty $d016
		sta $d022

		ldy #$09
		dey
		bne *-$01
		nop

		ldy #$16
		lda raster_cols+$01,x
		sty $d016
		sta $d022

		ldy #$09
		dey
		bne *-$01
		nop
		nop

		ldy #$17
		lda #$0c
		sty $d016
		sta $d022
		inx

		ldy #$07
		dey
		bne *-$01
		nop
		nop

		cpx #$08
		beq *+$05
		jmp split_loop_1

; Mask the screen after the logo
		lda #$7b
		sta $d011

		lda #$ae
		cmp $d012
		bne *-$03

; Set the colour and scroll registers
		lda #screen_col
		sta $d021
		lda #$00
		sta $d016
		lda #$16

; Skip over the logo data
		jmp main_loop_2


; Screen data for the logo
		* = $0518
		!byte $fe,$ff,$ff,$ff,$fe,$fe,$fe,$ff
		!byte $ff,$ff,$fe,$fe,$fe,$ff,$ff,$ff
		!byte $fe,$fe,$ff,$ff,$fe,$fe,$ff,$ff
		!byte $ff,$fe,$fe,$fe,$ff,$ff,$ff,$fe
		!byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe

		!byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
		!byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
		!byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
		!byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
		!byte $ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe

		!byte $fe,$fe,$ff,$ff,$fe,$fe,$fe,$fe
		!byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
		!byte $fe,$fe,$fe,$fe,$ff,$ff,$fe,$ff
		!byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
		!byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe

		!byte $fe,$fe,$fe,$ff,$ff,$fe,$fe,$fe
		!byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$fe
		!byte $ff,$ff,$ff,$fe,$fe,$ff,$ff,$fe
		!byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
		!byte $ff,$ff,$fe,$fe,$fe,$fe,$fe,$fe

		!byte $fe,$fe,$fe,$fe,$ff,$ff,$fe,$fe
		!byte $fe,$fe,$ff,$ff,$fe,$ff,$ff,$fe
		!byte $fe,$fe,$fe,$ff,$ff,$fe,$ff,$ff
		!byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
		!byte $ff,$fe,$fe,$fe,$fe,$fe,$fe,$fe

		!byte $fe,$fe,$fe,$fe,$fe,$ff,$ff,$fe
		!byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
		!byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
		!byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
		!byte $ff,$ff,$fe,$ff,$ff,$fe,$fe,$fe

		!byte $fe,$fe,$fe,$fe,$fe,$fe,$ff,$ff
		!byte $ff,$ff,$ff,$fe,$ff,$ff,$ff,$ff
		!byte $ff,$fe,$ff,$ff,$fe,$ff,$ff,$fe
		!byte $ff,$ff,$fe,$ff,$ff,$fe,$ff,$ff
		!byte $fe,$ff,$ff,$ff,$ff,$ff,$fe,$fe

		!byte $fe,$fe,$fe,$fe,$fe,$fe,$fe,$fe
		!byte $ff,$ff,$ff,$fe,$fe,$fe,$ff,$ff
		!byte $ff,$fe,$fe,$fe,$ff,$ff,$ff,$fe
		!byte $fe,$ff,$ff,$fe,$ff,$ff,$fe,$ff
		!byte $ff,$fe,$fe,$ff,$ff,$ff,$fe


; Carry on where we left off before the logo
main_loop_2	sta $d018

; Wait for the end of the current scanline and turn the
; screen back on
		ldx #$07
		dex
		bne *-$01
		lda #$1b
		sta $d011

; Mask the screen before the scroller
		lda #$b7
		cmp $d012
		bne *-$03

		lda #$7b
		sta $d011
scroll_x	lda #$00
		asl
		sta $d016

; Wait for the start of the scroll line and turn the screen
; back on
		lda #$b9
		cmp $d012
		bne *-$03

		ldx #$16
		dex
		bne *-$01

		lda #$1b
		sta $d011

; Hop over another block of data including the scrolling message
		jmp main_loop_3


; Colour data for the logo
raster_cols	!byte $06,$04,$0e,$03,$0d,$0f,$0a,$08
		!byte $02

; Colour data for the scroller
scroll_cols	!byte $0c,$0f,$07,$01,$07,$0f,$0c,$0b

; Scrolling message data
scroll_text	!scrxor $80,"Greetings to all of Cosine's friends!   "
		!scrxor $80,"FEMTOTRO 2 by Cosine   "
scroll_end


; Split the scroller's colours
main_loop_3	lda scroll_cols+$00
		sta $d021

		ldx #$02
		dex
		bne *-$01
		bit $ea

		lda scroll_cols+$01
		sta $d021

		ldx #$0a
		dex
		bne *-$01
		nop
		nop

		lda scroll_cols+$02
		sta $d021

		ldx #$0a
		dex
		bne *-$01
		nop
		nop

		lda scroll_cols+$03
		sta $d021

		inc $d016

		ldx #$09
		dex
		bne *-$01
		bit $ea
		nop

		lda scroll_cols+$04
		sta $d021

		ldx #$0a
		dex
		bne *-$01
		nop
		nop

		lda #scroll_col
		sta $d021

		ldx #$0a
		dex
		bne *-$01
		nop
		nop

		lda scroll_cols+$06
		sta $d021

		ldx #$0a
		dex
		bne *-$01
		nop
		nop

		lda scroll_cols+$07
		sta $d021

; Mask the screen after the scroller
		ldx #$0a
		dex
		bne *-$01
		nop

		lda #$7b
		sta $d011
		lda #screen_col
		sta $d021

		lda #$c7
		cmp $d012
		bne *-$03

		lda #$1b
		sta $d011

; Update the scroller
		ldx scroll_x+$01
		dex
		cpx #$ff
		bne sx_xb

; Shift the scroll area (it wraps around)
		ldy scroll_text+$00

		ldx #$00
mover		lda scroll_text+$01,x
		sta scroll_text+$00,x
		inx
		cpx #scroll_len
		bne mover

		sty scroll_text+scroll_len

		ldx #$03
sx_xb		stx scroll_x+$01

; Roll the scroller's colours down
scrl_col_cnt	ldx #$00
		bne scc_skip

		ldy scroll_cols+$07

		ldx #$06
scrl_col_move	lda scroll_cols+$00,x
		sta scroll_cols+$01,x
		dex
		bpl scrl_col_move

		sty scroll_cols+$00

scc_skip	ldx scrl_col_cnt+$01
		inx
		cpx #$05
		bne *+$04
		ldx #$00
		stx scrl_col_cnt+$01

; Upper/lower border wrangling
		lda #$f9
		cmp $d012
		bne *-$03
		lda #$13
		sta $d011

		lda #$fc
		cmp $d012
		bne *-$03
		lda #$1b
		sta $d011

; Play the music (if not in compact mode)
!if compact=$00 {
		jsr music+$21
}

; Check to see if space has been pressed and exit
		lda $dc01
		cmp #$ef
		beq *+$05
		jmp main_loop

		lda #$00
		sta $d418
		lda #$0b
		sta $d011

ghost_stash	lda #$00
		sta $3fff

		jmp $fce2

; Set up the SID hum (if in compact mode)
!if compact=$01 {
sid_init	ldx #$00
		lda sid_data,x
		sta $d407,x
		inx
		cpx #$12
		bne sid_init+$02

		rts

; SID registers for the hum
sid_data	!byte $00,$03,$00,$00,$21,$0f,$ff
		!byte $03,$03,$00,$00,$21,$0f,$ff
		!byte $00,$00,$00,$0b
}

; Character data for the logo
		* = $07f0
char_data	!byte $00,$00,$00,$00,$00,$00,$00,$00
		!byte $fd,$d6,$d6,$d6,$d6,$d6,$d6,$6a
