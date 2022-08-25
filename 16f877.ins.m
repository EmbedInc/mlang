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
'
'   Data memory.
'
memory datamem
    adrbits 9
    datbits 8
    access read write

memregion bank0 in datamem
    startadr 16#020
    endadr   16#06F
memregion bank1 in datamem
    startadr 16#0A0
    endadr   16#0EF
memregion bank2 in datamem
    startadr 16#120
    endadr   16#16F
memregion bank3 in datamem
    startadr 16#1A0
    endadr   16#1EF

adrspace data
    adrbits 8
    datbits 8
    access read write

adrregion banked in data
    startadr 16#20
    endadr   16#6F
    mapsto bank0
    mapsto bank1
    mapsto bank2
    mapsto bank3
