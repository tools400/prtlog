**free
//=====================================================================*
//  Author  :  Thomas Raddatz                                          *
//  Date    :  06.05.2002                                              *
//  E-mail  :  thomas.raddatz@tools400.de                              *
//  Homepage:  www.tools400.de                                         *
//=====================================================================*
//                                                                     *
//  This software is free software, you can redistribute it and/or     *
//  modify it under the terms of the GNU General Public License (GPL)  *
//  as published by the Free Software Foundation.                      *
//                                                                     *
//  See GNU General Public License for details.                        *
//          http://www.opensource.org                                  *
//          http://www.opensource.org/licenses/gpl-license.html        *
//                                                                     *
//=====================================================================*
//  History:                                                           *
//                                                                     *
//  Datum       Name          Änderung                                 *
//  ----------  ------------  ---------------------------------------  *
//  11.11.2004  Th.Raddatz    Changed PREFIX to QUALIFIED.             *
//                                                                     *
//=====================================================================*
//   >>PRE-COMPILER<<                                                  *
//     >>CRTCMD<<  CRTRPGMOD    MODULE(&LI/&OB) +                      *
//                              SRCFILE(&SL/&SF) +                     *
//                              SRCMBR(&SM);                           *
//     >>IMPORTANT<<                                                   *
//       >>PARM<< TRUNCNBR(*NO);                                       *
//       >>PARM<< DBGVIEW(*LIST);                                      *
//       >>PARM<< TGTRLS(*CURRENT);                                    *
//     >>END-IMPORTANT<<                                               *
//     >>EXECUTE<<                                                     *
//     >>CMD<<     CRTPGM       PGM(&LI/&OB) +                         *
//                              MODULE(*PGM) +                         *
//                              BNDSRVPGM(*LIBL/PRTLOG *LIBL/BASICS1) +*
//                              ACTGRP(*NEW   ) +                      *
//                              TGTRLS(*CURRENT) +                     *
//                              DETAIL(*BASIC);                        *
//   >>END-PRE-COMPILER<<                                              *
//=====================================================================*
ctl-opt bnddir('QC2LE');
ctl-opt extbinint(*yes);
ctl-opt datfmt(*iso) timfmt(*iso) debug(*yes);
//=====================================================================*

/copy QPRTLOG,PPRTLOG ?

//  *ENTRY
dcl-pr PGM_ENTRY_POINT extpgm('PRTLOG_T');
end-pr;

//  Prototypes of internal procedures
dcl-pr p_main;
end-pr;


//*******************************************************************
//  Program entry point
//*******************************************************************
dcl-pi PGM_ENTRY_POINT;
end-pi;

p_main();

*inlr = *on;

//==================================================================*
//  Main Procedure
//==================================================================*

dcl-proc p_main;
  dcl-pi *n;
  end-pi;

  //  Local fields
  dcl-s handle1 pointer inz;
  dcl-s handle2 pointer inz;
  dcl-s isDone1 ind inz;
  dcl-s isDone2 ind inz;
  dcl-s msg like(msg_t) inz;
  dcl-s x int(10) inz;
  //-------------------------------------------------------------------

  //  Open print log 1
  system('OVRPRTF ' +
  'FILE(PRTLOGP) ' +
  'PAGESIZE(*N  80) ' +
  'USRDTA('' 80 CHAR'') ' +
  'SPLFNAME(LOG1) ' );
  isDone1 = f_opnPrtLog('Log 1'     :
  cTrue       :
  handle1     );

  //  Open print log 2
  system('OVRPRTF ' +
  'FILE(PRTLOGP) ' +
  'PAGESIZE(*N 132) ' +
  'USRDTA(''132 CHAR'') ' +
  'SPLFNAME(LOG2) ' );
  isDone2 = f_opnPrtLog('Log 2'     :
  cFalse      :
  handle2     );

  //  Create a message
  msg = f_newMsg('CPF9897': 'Hello World!');

  //  Write messages to ...
  For x = 1 to 100;
    //  ... log 1
    isDone1 = f_wrtPrtLog(handle1 :
    msg     );
    //  ... log 2
    isDone2 = f_wrtPrtLog(handle2 :
    msg     );
    msg = f_newMsg('CPF9897': 'This is an ' +
                  'extra long line, to ' +
    'verify that WORWRAP ' +
    'works as designed.');
  Endfor;

  //  Write end messages to ...
  msg = f_newMsg('': '*** END ***');
  //  ... log 1
  isDone1 = f_wrtPrtLog(handle1 :
  msg     );
  //  ... log 2
  isDone2 = f_wrtPrtLog(handle2 :
  msg     );

  //  Close log 1
  isDone1 = f_cloPrtLog(handle1 );

  //  Close log 2
  isDone2 = f_cloPrtLog(handle2 );

  Return;

end-proc;

