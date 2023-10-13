      *=====================================================================*
      *  Author  :  Thomas Raddatz                                          *
      *  Date    :  06.05.2002                                              *
      *  E-mail  :  thomas.raddatz@tools400.de                              *
      *  Homepage:  www.tools400.de                                         *
      *=====================================================================*
      *                                                                     *
      *  This software is free software, you can redistribute it and/or     *
      *  modify it under the terms of the GNU General Public License (GPL)  *
      *  as published by the Free Software Foundation.                      *
      *                                                                     *
      *  See GNU General Public License for details.                        *
      *          http://www.opensource.org                                  *
      *          http://www.opensource.org/licenses/gpl-license.html        *
      *                                                                     *
      *=====================================================================*
      *  History:                                                           *
      *                                                                     *
      *  Datum       Name          Änderung                                 *
      *  ----------  ------------  ---------------------------------------  *
      *  11.11.2004  Th.Raddatz    Changed PREFIX to QUALIFIED.             *
      *                                                                     *
      *=====================================================================*
      *   >>PRE-COMPILER<<                                                  *
      *     >>CRTCMD<<  CRTRPGMOD    MODULE(&LI/&OB) +                      *
      *                              SRCFILE(&SL/&SF) +                     *
      *                              SRCMBR(&SM);                           *
      *     >>IMPORTANT<<                                                   *
      *       >>PARM<< TRUNCNBR(*NO);                                       *
      *       >>PARM<< DBGVIEW(*LIST);                                      *
      *       >>PARM<< TGTRLS(*CURRENT);                                    *
      *     >>END-IMPORTANT<<                                               *
      *     >>EXECUTE<<                                                     *
      *     >>CMD<<     CRTPGM       PGM(&LI/&OB) +                         *
      *                              MODULE(*PGM) +                         *
      *                              BNDSRVPGM(&LI/PRTLOG &LI/BASICS1) +    *
      *                              ACTGRP(*NEW   ) +                      *
      *                              TGTRLS(*CURRENT) +                     *
      *                              DETAIL(*BASIC);                        *
      *   >>END-PRE-COMPILER<<                                              *
      *=====================================================================*
     H BNDDIR('QC2LE')
     H EXTBININT(*YES)
     H DATFMT(*ISO) TIMFMT(*ISO) DEBUG(*YES)
      *=====================================================================*
      *
      /COPY QPRTLOG,PPRTLOG                      ?
      *
      *  *ENTRY
     D PGM_ENTRY_POINT...
     D                 PR                  extpgm('PRTLOG_T')
      *
      *  Prototypes of internal procedures
     D p_main...
     D                 PR
      *
      *
      ********************************************************************
      *  Program entry point
      ********************************************************************
      *
     D PGM_ENTRY_POINT...
     D                 PI
      *
     C                   Callp     p_main
      *
     C                   Eval      *inlr = *on
      *
      *==================================================================*
      *  Main Procedure
      *==================================================================*
      *
     P p_main...
     P                 B
     D                 PI
      *
      *  Local fields
     D handle1         S               *                    inz
     D handle2         S               *                    inz
     D isDone1         S               N                    inz
     D isDone2         S               N                    inz
     D msg             S                   like(msg_t     ) inz
     D x               S             10I 0                  inz
      *-------------------------------------------------------------------
      *
      *  Open print log 1
     C                   Callp     system('OVRPRTF ' +
     C                                       'FILE(PRTLOGP) ' +
     C                                       'PAGESIZE(*N  80) ' +
     C                                       'USRDTA('' 80 CHAR'') ' +
     C                                       'SPLFNAME(LOG1) ' )
     C                   Eval      isDone1 = f_opnPrtLog('Log 1'     :
     C                                                   cTrue       :
     C                                                   handle1     )
      *
      *  Open print log 2
     C                   Callp     system('OVRPRTF ' +
     C                                       'FILE(PRTLOGP) ' +
     C                                       'PAGESIZE(*N 132) ' +
     C                                       'USRDTA(''132 CHAR'') ' +
     C                                       'SPLFNAME(LOG2) ' )
     C                   Eval      isDone2 = f_opnPrtLog('Log 2'     :
     C                                                   cFalse      :
     C                                                   handle2     )
      *
      *  Create a message
     C                   Eval      msg = f_newMsg('CPF9897': 'Hello World!')
      *
      *  Write messages to ...
     C                   For       x = 1 to 100
      *  ... log 1
     C                   Eval      isDone1 = f_wrtPrtLog(handle1 :
     C                                                   msg     )
      *  ... log 2
     C                   Eval      isDone2 = f_wrtPrtLog(handle2 :
     C                                                   msg     )
     C                   Eval      msg = f_newMsg('CPF9897': 'This is an ' +
     C                                            'extra long line, to ' +
     C                                            'verify that WORWRAP ' +
     C                                            'works as designed.')
     C                   Endfor
      *
      *  Write end messages to ...
     C                   Eval      msg = f_newMsg('': '*** END ***')
      *  ... log 1
     C                   Eval      isDone1 = f_wrtPrtLog(handle1 :
     C                                                   msg     )
      *  ... log 2
     C                   Eval      isDone2 = f_wrtPrtLog(handle2 :
     C                                                   msg     )
      *
      *  Close log 1
     C                   Eval      isDone1 = f_cloPrtLog(handle1 )
      *
      *  Close log 2
     C                   Eval      isDone2 = f_cloPrtLog(handle2 )
      *
     C                   Return
      *
     P                 E
      *
