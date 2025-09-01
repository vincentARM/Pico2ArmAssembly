/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ   FALSE, 0
.equ   TRUE,  1

.equ ADRSTACK,     0x20040800           @ adresse de la pile

.equ LED_PIN, 25

.equ ATOMIC_XOR, 0x1000
.equ ATOMIC_SET, 0x2000
.equ ATOMIC_CLEAR, 0x3000

.equ SIO_BASE,        0xD0000000
.equ CLOCKS_BASE,     0x40010000
.equ RESETS_BASE,     0x40020000
.equ IO_BANK0_BASE,   0x40028000
.equ PADS_BANK0_BASE, 0x40038000
.equ PLL_SYS_BASE,    0x40050000

.equ PPB_BASE,        0xe0000000
.equ PPB_CPUID,       0xed00
.equ PPB_VTOR,        0xed08

.equ GPIO0_CTRL,      4

.equ GPIO_IN        , 0x004 @ Input value for GPIO pins
.equ GPIO_HI_IN     , 0x008 @ Input value for QSPI pins
.equ GPIO_OUT       , 0x010 @ GPIO output value
.equ GPIO_HI_OUT    , 0x014 @ QSPI output value

.equ GPIO_OUT_SET   , 0x018 @ GPIO output value set
.equ GPIO_HI_OUT_SET, 0x01C @ QSPI output value set

.equ GPIO_OUT_CLR   , 0x020 @ GPIO output value clear
.equ GPIO_HI_OUT_CLR, 0x024 @ QSPI output value clear

.equ GPIO_OUT_XOR   , 0x028 @ GPIO output value XOR
.equ GPIO_HI_OUT_XOR, 0x02c @ QSPI output value XOR
.equ GPIO_OE        , 0x030 @ GPIO output enable
.equ GPIO_HI_OE     , 0x034 @ QSPI output enable
.equ GPIO_OE_SET    , 0x038 @ GPIO output enable set
.equ GPIO_HI_OE_SET , 0x03C @ QSPI output enable set
.equ GPIO_OE_CLR    , 0x040 @ GPIO output enable clear
.equ GPIO_HI_OE_CLR , 0x044 @ QSPI output enable clear
.equ GPIO_OE_XOR    , 0x048 @ GPIO output enable XOR
.equ GPIO_HI_OE_XOR , 0x04c @ QSPI output enable XOR

.equ GPIO_FUNC_SIO,   5     @ fonction gpio 
