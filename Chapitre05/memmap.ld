MEMORY
{
  flash      (rx)  : ORIGIN = 0x10000000, LENGTH = 2048k
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH =   0x00080000
}

/* heap is just after bss section */
__HEAP_SIZE  = 64K;

STACK_SIZE = 0x4000;

/* this is to eliminate RWX permission error for text segment */
PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
  bss PT_LOAD FLAGS(6);
}

/* Section Definitions */
SECTIONS
{

    .text :
    {
       /*  KEEP(*(.vectors .vectors.*))  pour simplifier */
        *(.text*)
        *(.rodata*)
    } > flash   :text

    . = ALIGN(4);
    _debutFlashData = . ;
    .data :
    {
      _debutRamData = . ;
     . = ALIGN(2);
        *(.data*);
    } > ram AT >flash  :data
    
    
     /* .bss section which is used for uninitialized data */
      . = ALIGN(4);
     _debutRamBss = . ;
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram  :bss
     _finRamBss = . ;
     /* heap starts after bss and grows bottom up */
     .heap (COPY) :
    {
    . = ALIGN(4);
     _debutHeap = . ;

    . = . + __HEAP_SIZE;
    . = ALIGN(4);
    __HeapLimit = .;    /* used for checking stack/heap overflow */
    end = .;            /* used by NEWLIB */

  } > ram


    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        _stack = .;
        . = ALIGN(8);
    } > ram

    _end = . ;
}