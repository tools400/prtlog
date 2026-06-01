**free
/if NOT defined(PPRTLOG)
/define PPRTLOG

/copy QBASICS1,PBASICS1 ?

//  Typedefs and constants
dcl-s prtLog_handle_t pointer template;

dcl-c PRTLOG_Handle_null *null;

//  Open PrintLog
dcl-pr f_opnPrtLog ind extproc('PRTLOGR1_f_opnPrtLog');
  i_headline char(118) value;
  i_scndLvl  ind value;
  o_handle   like(prtLog_handle_t);
end-pr;

//  write into Log
dcl-pr f_wrtPrtLog ind extproc('PRTLOGR1_f_wrtPrtLog');
  i_handle like(prtLog_handle_t) value;
  i_msg    likeds(msg_t) value;
end-pr;

//  Close PrintLog
dcl-pr f_cloPrtLog ind extproc('PRTLOGR1_f_cloPrtLog');
  io_handle like(prtLog_handle_t);
end-pr;

/endif
