'   Example M file describing the memory architecture of a PIC 16F877A.
'
'   *** WORK IN PROGRESS ***

'   Program memory
'
memory progmem
    adrbits 13
    datbits 14
    access read execute

memregion page0 in progmem
    startadr 16#0000
    length   16#0800
memregion page1 in progmem
    startadr 16#0800
    length   16#0800
memregion page2 in progmem
    startadr 16#1000
    length   16#0800
memregion page3 in progmem
    startadr 16#1800
    length   16#0800

adrspace progsp
    adrbits 13
    datbits 14
    access execute
