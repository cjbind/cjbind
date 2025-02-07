SECTIONS {
  .text : {
    *(.text.unlikely .text.*_unlikely .text.unlikely.*)
    *(.text.exit .text.exit.*)
    *(.text.startup .text.startup.*)
    *(.text.hot .text.hot.*)
    *(.text .stub .gnu.linkonce.t.*)
    g_runtimeStaticStart = .;
    *(.text_runtime)
    *(SORT(.text.*MRT*))
    *(SORT(.text.*MCC*))
    *(SORT(.text.*MapleRuntime*))
    *(SORT(.text.*Monitor*))
    *(.text_thread)
    g_runtimeStaticEnd = .;
    *(.cjinit_function .cjinit_function.*)
    *(.gnu.warning)
    *(.text.*)
  }
}