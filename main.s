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
		org	$2000			; system programs execute at $2000
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

		jsr	DL_SetDLRMixMode	; turn on double lo-res

	; init drawing loop first
main_init
		ldx	#4			; do 4 downto 1

		stz	mdlgr_src		; reset smc
		lda	#$50
		sta	mdlgr_src+1

main_loop
		phx				; save counter
		jsr	MoveDLGRBinary		; call function
		lda	#$10			; delay a bit
		jsr	$fca8
		lda	#$FF
		jsr	$fca8

		plx				; restore loop counter
		dex				; decrement
		bne	main_loop		; not done yet - branch and continue

		jmp	main_init		; jump back and loop forever


	; ====================================================================================================
	; move a Double Lo-Res Binary blob from BMP2DHR to video memory
	; this does not stomp on screen holes

	; format is BSAVE, with 0 in slot holes. preserved during copy.

	; input: reset mdlgr_src to your source binary
	; output: binary copied to screen, mdlgr_dst in prime position to continue animation

MoveDLGRBinary
	; start with auxiliary page
		sta	PAGE2ON			; start with aux page

	; reset destination (start at $0400)
mdlgr_resetdst
		stz	mdlgr_dst		; reset destination self-modifying code
		lda	#$04
		sta	mdlgr_dst+1

	; start of $04xx-$07xx memory copy (for both aux/main mem) - copy in $0n00-$0n77 chunks
mdlgr_startcopy
		ldy	#$77			; init loop counter

	; heart of code - copyloop - copy source to destination - self-modifying!
mdlgr_copyloop
mdlgr_src	=	*+1
		lda	$5000,y			; load from storage
mdlgr_dst	=	*+1
		sta	$0400,y			; save to screen
		dey
		bpl	mdlgr_copyloop		; continue while positive (do $77 downto $00)

	; add to source offset
		clc
		lda	mdlgr_src
		adc	#$80			; step by $80 (screen pos)
		sta	mdlgr_src
		bcc	:cont1
		inc	mdlgr_src+1		; remember to do a 16-bit add
:cont1
	; add to destination (screen) offset and check if done
		clc
		lda	mdlgr_dst
		adc	#$80			; step by $80
		sta	mdlgr_dst
		bcc	:cont2
		inc	mdlgr_dst+1		; remember to do a 16-bit add
:cont2
		lda	mdlgr_dst+1		; a is now the hi byte - remember, our copy only valid from $04-$07
		cmp	#$08			; does a=$08 then ?  TODO this should be maybe a >= 8
		bne	mdlgr_startcopy		; not done yet. everything all incremented - branch and continue copy

	; the copy of either aux/main mem complete - check which one
		bit	PAGE2			; which page we on?
		bpl	mdlgr_done		; we're on main page - means we're done

	; not done - flip from aux to main page and do this over again
		sta	PAGE2OFF		; turn on mainpage
		bra	mdlgr_resetdst		; play it again sam
	
	; totally done! well...baaaiiiii!	
mdlgr_done
		rts

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
		; put	tables			; the tables

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
		sta	$C052
		;sta	$C053
		rts

