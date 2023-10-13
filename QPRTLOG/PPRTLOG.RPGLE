      /IF NOT DEFINED(PPRTLOG)
      /DEFINE PPRTLOG
      *
      /COPY QBASICS1,PBASICS1                    ?
      *
      *  Typedefs and constants
     D prtLog_handle_t...
     D                 S               *   based(pDummy)
      *
     D PRTLOG_Handle_null...
     D                 C                   const(*NULL)
      *
      *  Open PrintLog
     D f_opnPrtLog...
     D                 PR              N
     D                                     extproc('PRTLOGR1+
     D                                     _f_opnPrtLog+
     D                                     ')
     D  i_headline                  118A   value
     D  i_scndLvl                      N   value
     D  o_handle                                  like(prtLog_handle_t)
      *
      *  write into Log
     D f_wrtPrtLog...
     D                 PR              N
     D                                     extproc('PRTLOGR1+
     D                                     _f_wrtPrtLog+
     D                                     ')
     D  i_handle                           value  like(prtLog_handle_t)
     D  i_msg                              value  likeds(msg_t        )
      *
      *  Close PrintLog
     D f_cloPrtLog...
     D                 PR              N
     D                                     extproc('PRTLOGR1+
     D                                     _f_cloPrtLog+
     D                                     ')
     D  io_handle                                 like(prtLog_handle_t)
      *
      /ENDIF
