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
      *  03.02.2005  Th.Raddatz    Changed PRTLOG to use service program    *
      *                            BASICS1.                                 *
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
      *       >>PARM<< OPTION(*EVENTF);                                     *
      *     >>END-IMPORTANT<<                                               *
      *     >>EXECUTE<<                                                     *
      *     >>CMD<<     CRTSRVPGM    SRVPGM(&LI/&OB) +                      *
      *                              MODULE(&LI/&OB)  +                     *
      *                              EXPORT(*ALL) +                         *
      *                              ACTGRP(*CALLER) +                      *
      *                              BNDSRVPGM(&LI/BASICS1) +               *
      *                              DETAIL(*BASIC) +                       *
      *                              TGTRLS(*CURRENT) +                     *
      *                              TEXT('SrvPgm  : Print log');           *
      *   >>END-PRE-COMPILER<<                                              *
      *=====================================================================*
     H NOMAIN
     H EXTBININT(*YES) BNDDIR('QC2LE')
     H DATFMT(*ISO) TIMFMT(*ISO) DEBUG(*YES)
      /COPY QPRTLOG,COPYRIGHT
      *=====================================================================*
     FPRTLOGP   O    E             PRINTER        usropn
     F                                            infds(prtf)
      *
      *  File information data structures ----------
      *
     D prtf            DS                  qualified
     D  pagLen               152    153I 0
     D  pagWidth             154    155I 0
     D  ovrflw               188    189I 0
     D  curLine              367    368I 0
     D  curPage              369    372I 0
      *
      *  Prototypes of exported procedures ---------
      /COPY QPRTLOG,PPRTLOG
      *
      *  Prototypes of private procedures ----------
      *
      *  Start a new page.
     D p_newPage...
     D                 PR
     D  i_pHandle                      *   value
      *
      *  Check for overflow.
     D f_isOverflow...
     D                 PR              N
     D  i_pHandle                      *   value
      *
      *  Write empty line.
     D p_newLine...
     D                 PR
     D  io_pHandle                     *
      *
      *  Prototypes of C functions -----------------
      *
      *  Open a Record File for I/O Operations
     D rOpen           PR              *          extproc('_Ropen')
     D  i_fileName                     *   value  options(*string)
     D  i_mode                         *   value  options(*string)
      *
      *  Set the Record Format Name
     D rFormat         PR                         extproc('_Rformat')
     D  i_handle                       *   value
     D  i_format                       *   value  options(*string)
      *
      *  Write the Next Record
     D rWrite          PR              *          extproc('_Rwrite')
     D  i_handle                       *   value
     D  i_buffer                       *   value
     D  i_bufSize                    10U 0 value
      *
      *  Close a File
     D rClose          PR            10I 0        extproc('_Rclose')
     D  i_handle                       *   value
      *
      *  Prototypes of system APIs -----------------
      *
      *  Internal reference fields -----------------
      *
      *  Handle
     D handle_t        DS                  qualified template
     D  pFile                          *
     D  is132                          N
     D  ovrflw                       10I 0
     D  row                          10I 0
     D  headln                      132A
     D  secLvl                         N
     D  pageNbr                      10I 0
      *
     D rFILE_t         DS                  qualified template
     D  res01                        16A
     D  pInBuf                         *
     D  pOutBuf                        *
     D  res02                        48A
     D  riofb                              likeds(rRIOFB_t)
     D  res03                        32A
     D  bufLen                       10U 0
     D  res04                        28A
     D  pInNull                        *
     D  pOutNul                        *
     D  pKeyNul                        *
     D  res05                        48A
     D  minLen                       10I 0
     D  nMapLen                       5I 0
     D  nKeyLen                       5I 0
     D  res06                         8A
      *
     D rRIOFB_t        DS                  qualified align template
     D  pKey                           *
     D  pSysP                          *
     D  rrn                          10U 0
     D  numByt                       10I 0
     D  blkCnt                        5I 0
     D  blkFld                        1A
     D  bitfld                        1A
     D   dupKy                        1A   overlay(bitfld: 1)
     D   icfLc                        1A   overlay(bitfld: 1)
     D   res01                        1A   overlay(bitfld: 1)
     D  res02                        20A
      *
      *  Printer file fields
     D prtf_t_in       S               N   based(pDummy)
     D prtf_t_headln   S             66A   based(pDummy)
     D prtf_t_headlnw  S            118A   based(pDummy)
     D prtf_t_headdt   S             10A   based(pDummy)
     D prtf_t_headtm   S              8A   based(pDummy)
     D prtf_t_headpg   S              5A   based(pDummy)
     D prtf_t_date     S              6S 0 based(pDummy)
     D prtf_t_time     S              6S 0 based(pDummy)
     D prtf_t_msgid    S              7A   based(pDummy)
     D prtf_t_msgtext  S             40A   based(pDummy)
     D prtf_t_msgtextw...
     D                 S             92A   based(pDummy)
      *
      *  Constants ---------------------------------
      *
     D cNEWPAGE_ROWS   C                   const(2)
     D cHEAD_ROWS      C                   const(3)
     D cPOS_ROWS       C                   const(1)
     D cNEWLINE_ROWS   C                   const(1)
      *
      *=====================================================================*
      *  Open print log.
      *=====================================================================*
      *  i_headline  -  Headline of the log.
      *  i_secLvl    -  Print second level message text
      *                   TRUE  = print second level text
      *                   FALSE = do not print second level text
      *  o_handle    -  Handle of the log, that must be passed to
      *                 f_wrtPrtLog() and f_cloPrtLog().
      *=====================================================================*
     P f_opnPrtLog...
     P                 B                   export
     D                 PI              N
     D  i_headline                  118A   value
     D  i_secLvl                       N   value
     D  o_handle                                  like(prtLog_handle_t)
      *
      *  Return value
     D isDone          S               N                         inz(cFalse)
      *
     D handle          DS                  likeds(handle_t) based(pHandle)
      *
      *  Fields
     D pFile           S               *   inz
     D handleSize      S             10I 0 inz
      *
     D rFILE           DS                  likeds(rFILE_t) based(pFile)
     D rRIOFB          DS                  likeds(rRIOFB_t) based(pRIOFB)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      *
      *  Open printer file to get OVERFLOW and PAGEWIDTH
     C                   If        not %open(PRTLOGP)
     C                   Open      PRTLOGP
     C                   Endif
      *
      *  Open new instance of printer file ...
     C                   Eval      pFile = rOpen('PRTLOGP'   :
     C                                           'wr'        )
      *
     C                   If        pFile = *NULL
     C                   Eval      isDone = cFalse
     C                   Else
     C                   Eval      pRIOFB = %addr(rFILE.riofb)
      *
      *  Allocate memory for the new handle ...
     C                   Eval      handleSize = %size(handle)
     C                   Alloc     handleSize    pHandle
      *
      *  Set handle fields ...
     C                   Eval      handle.pFile     = pFile
     C                   If        prtf.pagWidth    >= 132
     C                   Eval      handle.is132 = *on
     C                   Else
     C                   Eval      handle.is132 = *off
     C                   Endif
     C                   Eval      handle.row       = 0
     C                   Eval      handle.ovrflw    = prtf.ovrflw
     C                   Eval      handle.headln    = %trim(i_headline)
     C                   Eval      handle.secLvl    = i_secLvl
     C                   Eval      handle.pageNbr   = 0
     C                   Eval      isDone           = cTrue
     C                   Endif
      *
      *  CLose printer file
     C                   If        %open(PRTLOGP)
     C                   close     PRTLOGP
     C                   Endif
      *
      *  Start a new page ...
     C                   Callp     p_newPage(pHandle)
      *
     C                   If        isDone
     C                   Eval      o_handle = pHandle
     C                   Else
     C                   Eval      o_handle = *NULL
     C                   Endif
      *
     C                   Return    isDone
      *
     P                 E
      *
      *=====================================================================*
      *  Write to print log.
      *=====================================================================*
      *  i_pHandle   -  Handle, that was paased back from the
      *                 f_opnPrtLog() procedure.
      *  i_msg       -  Message that is to be logged.
      *=====================================================================*
     P f_wrtPrtLog...
     P                 B                   export
     D                 PI              N
     D  i_pHandle                          value  like(prtLog_handle_t)
     D  i_msg                              value  likeds(msg_t        )
      *
      *  Return value
     D isDone          S               N                         inz(cFalse)
      *
      *  Fields
     D handle          DS                  likeds(handle_t) based(pHandle)
      *
     D pos             DS                  qualified inz
     D  in20                               like(prtf_t_in)
     D  date                               like(prtf_t_date)
     D  time                               like(prtf_t_time)
     D  msgID                              like(prtf_t_msgid)
     D  msgText                            like(prtf_t_msgtext)
      *
     D posw            DS                  qualified inz
     D  in20                               like(prtf_t_in)
     D  date                               like(prtf_t_date)
     D  time                               like(prtf_t_time)
     D  msgID                              like(prtf_t_msgid)
     D  msgTextw                           like(prtf_t_msgtextw)
      *
     D rRIOFB          DS                  likeds(rRIOFB_t) based(prTgtIO)
      *
     D msg             DS                  likeds(msg_t) inz
      *
     D text            S           2048A   inz
     D startPos        S             10U 0 inz
     D timestamp       S               Z   inz
     D time            S               T   inz
     D date            S               D   inz
      *
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      *
     C                   Eval      isDone  = cTrue
      *
     C                   Eval      pHandle = i_pHandle
     C                   Eval      msg     = i_msg
      *
     C                   Time                    timeStamp
     C                   Movel     timeStamp     date
     C                   Movel     timeStamp     time
      *
      *---------------------------------------------
      *  Print message text ...
      *---------------------------------------------
     C                   If        msg.ID <> ''
     C                   Eval      text     = f_rtvMsgText(msg)
     C                   Else
     C                   Eval      text     = msg.data
     C                   Endif
      *
     C                   If        %trim(text) <> ''
     C                   Eval      startPos = 1
     C                   Else
     C                   Eval      startPos = 0
     C                   Endif
      *
     C                   If        handle.is132
      *  ... set output fields.
     C                   Eval      posw.in20  = *on
     C     *DMY          Move      date          posw.date
     C     *HMS          Move      time          posw.time
     C                   Eval      posw.msgID = msg.id
     C                   Else
      *  ... set output fields.
     C                   Eval      pos.in20   = *on
     C     *DMY          Move      date          pos.date
     C     *HMS          Move      time          pos.time
     C                   Eval      pos.msgID  = msg.id
     C                   Endif
      *
      *  Loop through msgText ...
     C                   Dow       startPos > 0
      *
      *  ... start a new page if required.
     C                   If        f_isOverflow(pHandle)
     C                   Callp     p_newPage(phandle)
     C                   Endif
      *
      *  ... select list width.
     C                   If        handle.is132
      *      ... set output field.
     C                   Eval      posw.msgTextw = f_wordWrap(text:
     C                                                     %size(posw.msgTextw):
     C                                                     startPos)
      *      ... select record format.
     C                   Callp     rFormat(handle.pFile: 'POSW')
      *      ... write to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(posw):
     C                                              %size(posw))
     C                   If        rRIOFB.numByt = 0
     C                   Eval      isDone = cFalse
     C                   Goto      exit_fnc
     C                   Endif
     C                   Else
      *      ... set output field.
     C                   Eval      pos.msgText   = f_wordWrap(text:
     C                                                     %size(pos.msgText):
     C                                                     startPos)
      *      ... select record format.
     C                   Callp     rFormat(handle.pFile: 'POS')
      *      ... write to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(pos):
     C                                              %size(pos))
     C                   If        rRIOFB.numByt = 0
     C                   Eval      isDone = cFalse
     C                   Goto      exit_fnc
     C                   Endif
     C                   Endif
      *
      *  ... adjust line counter.
     C                   Eval      handle.row = handle.row + cPOS_ROWS
      *
      *  ... hide "date", "time" and "msgid".
     C                   If        handle.is132
     C                   Eval      posw.in20 = *off
     C                   Else
     C                   Eval      pos.in20 = *off
     C                   Endif
     C                   Enddo
      *
      *---------------------------------------------
      *  Print message help text ...
      *---------------------------------------------
     C                   If        handle.secLvl
      *
     C                   If        msg.id <> ''
     C                   Eval      text = f_rtvMsgHelpText(msg)
     C                   Else
     C                   Eval      text = ''
     C                   Endif
      *
     C                   If        %trim(text) <> ''
     C                   Eval      startPos = 1
     C                   Else
     C                   Eval      startPos = 0
     C                   Endif
      *
     C                   If        handle.is132
      *  ... set output fields.
     C                   Eval      posw.in20 = *off
     C     *DMY          Move      date          posw.date
     C     *HMS          Move      time          posw.time
     C                   Eval      posw.msgID = msg.id
     C                   Else
      *  ... set output fields.
     C                   Eval      pos.in20 = *off
     C     *DMY          Move      date          pos.date
     C     *HMS          Move      time          pos.time
     C                   Eval      pos.msgID = msg.id
     C                   Endif
      *
      *  Loop through msgText ...
     C                   Dow       startPos > 0
      *
      *  ... start a new page if required.
     C                   If        f_isOverflow(pHandle)
     C                   Callp     p_newPage(phandle)
     C                   Endif
      *
      *  ... select list width.
     C                   If        handle.is132
      *      ... set output field.
     C                   Eval      posw.msgTextw = f_wordWrap(text:
     C                                                     %size(posw.msgTextw):
     C                                                     startPos)
      *      ... select record format.
     C                   Callp     rFormat(handle.pFile: 'POSW')
      *      ... write to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(posw):
     C                                              %size(posw))
     C                   If        rRIOFB.numByt = 0
     C                   Eval      isDone  = cFalse
     C                   Goto      exit_fnc
     C                   Endif
     C                   Else
      *      ... set output field.
     C                   Eval      pos.msgText = f_wordWrap(text:
     C                                                   %size(pos.msgText):
     C                                                   startPos)
      *      ... select record format.
     C                   Callp     rFormat(handle.pFile: 'POS')
      *      ... write to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(pos):
     C                                              %size(pos))
     C                   If        rRIOFB.numByt = 0
     C                   Eval      isDone = cFalse
     C                   Goto      exit_fnc
     C                   Endif
     C                   Endif
      *
      *  ... adjust line counter.
     C                   Eval      handle.row = handle.row + cPOS_ROWS
      *
      *  ... hide "date", "time" and "msgid".
     C                   If        handle.is132
     C                   Eval      posw.in20 = *off
     C                   Else
     C                   Eval      pos.in20 = *off
     C                   Endif
     C                   Enddo
      *
     C                   Endif
      *
     C     exit_fnc      Tag
      *
     C                   Return    isDone
      *
     P                 E
      *
      *=====================================================================*
      *  Close print log.
      *=====================================================================*
      *  io_pHandle  -  Handle, that was paased back from the
      *                 f_opnPrtLog() procedure.
      *=====================================================================*
     P f_cloPrtLog...
     P                 B                   export
     D                 PI              N
     D  io_pHandle                                like(prtLog_handle_t)
      *
      *  Return value
     D isDone          S               N                         inz(cFalse)
      *
      *  Fields
     D handle          DS                  likeds(handle_t) based(pHandle)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     C                   Eval      isDone = cTrue
      *
     C                   Eval      pHandle = io_pHandle
      *
     C                   If        rClose(handle.pFile) = 0
     C                   Eval      isDone = cTrue
     C                   Dealloc                 io_pHandle
     C                   Eval      io_pHandle = *null
     C                   Else
     C                   Eval      isDone = cFalse
     C                   Endif
      *
     C                   Return    isDone
      *
     P                 E
      *
      *=====================================================================*
      *  *** private ***
      *  Start a new page.
      *=====================================================================*
     P p_newPage...
     P                 B
     D                 PI
     D  i_pHandle                      *   value
      *
      *  Fields
     D handle          DS                  likeds(handle_t) based(pHandle)
      *
     D head1           DS                  qualified inz
     D  headdt                             like(prtf_t_headdt  ) inz
     D  headtm                             like(prtf_t_headtm  ) inz
     D  headpg                             like(prtf_t_headpg  ) inz
      *
     D head2           DS                  qualified inz
     D  headln                             like(prtf_t_headln  ) inz
      *
     D headw1          DS                  qualified inz
     D  headdtw                            like(prtf_t_headdt  ) inz
     D  headtmw                            like(prtf_t_headtm  ) inz
     D  headpgw                            like(prtf_t_headpg  ) inz
      *
     D headw2          DS                  qualified inz
     D  headlnw                            like(prtf_t_headlnw ) inz
      *
     D rRIOFB          DS                  likeds(rRIOFB_t) based(prTgtIO)
      *
     D pageTmstmp      S               Z
     D pageDate        S               D
     D pageTime        S               T
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      *
     C                   Eval      pHandle = i_pHandle
      *
      *  Start a new page
     C                   Callp     rFormat(handle.pFile: 'NEWPAGE')
      *
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              *null:
     C                                              0)
      *
     C                   Eval      handle.row = cNEWPAGE_ROWS
      *  ... adjust page counter
     C                   Eval      handle.pageNbr = handle.pageNbr + 1
      *  ... set Date and Time
     C                   Time                    pageTmstmp
     C                   Move      pageTmstmp    pageDate
     C                   Move      pageTmstmp    pageTime
      *
      *  Write headline
      *
     C                   If        handle.is132
      *  ... set output fields.
     C     *EUR          Move      pageDate      headw1.headdtw
     C     *HMS:         Move      pageTime      headw1.headtmw
     C                   Evalr     headw1.headpgw = %trim(
     C                                              %editc(handle.pageNbr :'Z'))
     C                   Eval      headw2.headlnw =
     C                                           f_center(handle.headln:
     C                                                    %size(headw2.headlnw))
      *  ... select record format for Headline 1
     C                   Callp     rFormat(handle.pFile: 'HEADW1')
      *  ... write data to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(headw1):
     C                                              %size(headw1))
      *  ... select record format for Headline 2
     C                   Callp     rFormat(handle.pFile: 'HEADW2')
      *  ... write data to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(headw2):
     C                                              %size(headw2))
     C                   Else
      *  ... set output fields.
     C     *EUR          Move      pageDate      head1.headdt
     C     *HMS:         Move      pageTime      head1.headtm
     C                   Evalr     head1.headpg = %trim(
     C                                             %editc(handle.pageNbr :'Z'))
     C                   Eval      head2.headln = f_center(handle.headln:
     C                                                     %size(head2.headln))
      *  ... select record format for Headline 1
     C                   Callp     rFormat(handle.pFile: 'HEAD1')
      *  ... write data to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(head1):
     C                                              %size(head1))
      *  ... select record format for Headline 2
     C                   Callp     rFormat(handle.pFile: 'HEAD2')
      *  ... write data to printer file.
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              %addr(head2):
     C                                              %size(head2))
     C                   Endif
      *
      *  Adjust line counter
     C                   Eval      handle.row = handle.row + cHEAD_ROWS
      *
     C                   Return
      *
     P                 E
      *
      *=====================================================================*
      *  *** private ***
      *  Check overflow condition.
      *=====================================================================*
     P f_isOverflow...
     P                 B
     D                 PI              N
     D  i_pHandle                      *   value
      *
      *  Return value
     D isOverflow      S               N   inz
      *
      *  Fields
     D handle          DS                  likeds(handle_t) based(pHandle)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      *
     C                   Eval      pHandle = i_pHandle
      *
     C                   If        handle.row >= handle.ovrflw
     C                   Eval      isOverflow = *on
     C                   Else
     C                   Eval      isOverflow = *off
     C                   Endif
      *
     C                   Return    isOverflow
      *
     P                 E
      *
      *=====================================================================*
      *  *** private ***
      *  Write an empty line.
      *=====================================================================*
     P p_newLine...
     P                 B
     D                 PI
     D  io_pHandle                     *
      *
      *  Fields
     D handle          DS                  likeds(handle_t) based(pHandle)
      *
     D rRIOFB          DS                  likeds(rRIOFB_t) based(prTgtIO)
      * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      *
     C                   Eval      pHandle = io_pHandle
      *
     C                   Callp     rFormat(handle.pFile: 'NEWLINE')
      *
     C                   Eval      prTgtIO = rWrite(handle.pFile:
     C                                              *null:
     C                                              0)
      *
     C                   Eval      handle.row = handle.row + cNEWLINE_ROWS
      *
     C                   Return
      *
     P                 E
      *
