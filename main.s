; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;
; Template Apple II 6502 Code?
;
; Could be..Awesome Apple II low-resolution horizontal starfield thingy
; ..Or..Trash Dove printer.. Who knows yet?
;
; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

; Use ezgif.com to convert animated gifs to frames
; To convert to a2, use b2d file.bmp DL D


		mx	%11			; assemble in 8-bit mode
		typ	$06			; type binary (for merlin32)
		org	$7000			; system programs execute at $2000
		dsk	main			; this is the main .system blob
						; we probably want to relocate to higher ground, to free hgr1

		put	main_h			; use our shared header
		;put	gfx40_h			; and the 40 col graphics routines
		;put	tables_h		; use tables_h

	; ====================================================================================================
	; start of code

start
		lda	#$A0			; why do I do this?
		jsr	$C300			; init 80 column card

		;bit	DHRON			; turn double-hires on
		;bit	TEXTOFF			; turn on graphics mode
		;bit	MIXEDON			; use bottom 4 rows as text
		jsr	DL_SetDLRMixMode	; turn on double lo-res


	; ====================================================================================================
	; draw a 80x48 glyph

draw80x48glyph
		stz	curline			; initialize curline to 0
		stz	startloop+4		; reset self modifying code
		stz	startloop+1
		lda	#$50
		sta	startloop+2
		lda	#$04
		sta	startloop+5

start2
		sta	PAGE2ON			; start with aux page
start3
		ldy	#$27			; start copying
startloop
		lda	$5000,y			; load from storage
		sta	$0400,y			; save to screen
		dey
		bpl	startloop

		clc				; always add to address for reading after our copy
		lda	startloop+1
		adc	#$28			; increase screen pos
		sta	startloop+1
		lda	startloop+2
		adc	#0
		sta	startloop+2

		bit	PAGE2			; is page2 on or off
		bpl	start4			; we're on main page - done - continue

		sta	PAGE2OFF		; not done, switch to main page, reset, copy, continue
		bra	start3			; and continue loop

start4
		inc	curline			; both aux and main copied - now increase the current line and continue
		ldx	curline
		cpx	#24			; 0-23 done?
		beq	startdone

		lda	lgr_lo,x		; get new screen row for writing
		sta	startloop+4		; smc
		lda	lgr_hi,x
		sta	startloop+5

		bra	start2

startdone
		rts

curline		db	0

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Lo-Res Screen - 40 by 48. 48 = 24 * 2 colors per byte separated by nybble (TTTT BBBB) - one horiz line represented below
;                    __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __  
;  top col, low nyb |__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|
;   bot col, hi nyb |__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|__|
;         offset dec  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39
;         offset hex  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F 20 21 22 23 24 25 26 27

; -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Support Libraries

		; temp insert directly here
		; put	gfx40			; graphics library
		put	tables			; the tables

; from Flapple Bird

DL_SetDLRMixMode
		;lda	LORES
		lda	$C050
		;lda	SETAN3
		lda	$C05E
		;sta	SET80VID
		sta	$C00D
		;sta	C80STOREON
		sta	$C001
		;sta	MIXSET
		sta	$C053
		rts

