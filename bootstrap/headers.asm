  dc.b	'SEGA GENESIS    '	; console name
  dc.b	'(C)NDSS 2018.JUL'			; copyright
  dc.b	'IndigoHedgehog Kernel Demo                      ' ; cart name
  dc.b	'IndigoHedgehog Kernel Demo                      ' ; cart name (alt)
  dc.b	'GM 20180701-00'	; program type / serial number / version
  dc.w	$0000				; ROM checksum
  dc.b	'J               '	; I/O device support (unused)
  dc.l	$00000000			; address of ROM start
  dc.l	RomEnd				; address of ROM end
  dc.l	$FFFF0000,$FFFFFFFF	; RAM start/end
  dc.b	'            '		; backup RAM info
  dc.b	'            '		; modem info
  dc.b	'http://huguesjohnson.com/               ' ; comment
  dc.b	'JUE             '	; regions allowed
