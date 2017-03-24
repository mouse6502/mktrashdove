
ZP0		=	$06
ZP1		=	$07
ZP2		=	$08
ZP3		=	$09

PAGE2		=	$C01C			; R7 1=video page2 OR aux video page selected
PAGE2OFF	=	$C054			; RW select page1 display (or main video memory)
PAGE2ON		=	$C055			; RW select page2 display (or aux video memory)

DHRON		=	$C05E			; enable dhr
DHROFF		=	$C05F			; disable dhr

TEXTOFF		=	$C050			; select graphics mode

MIXEDON		=	$C053			; use graphics with four lines of text
