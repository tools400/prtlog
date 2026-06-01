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
//  Datum       Name          nderung                                 *
//  ----------  ------------  ---------------------------------------  *
//  11.11.2004  Th.Raddatz    Changed PREFIX to QUALIFIED.             *
//                                                                     *
//  03.02.2005  Th.Raddatz    Changed PRTLOG to use service program    *
//                            BASICS1.                                 *
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
//       >>PARM<< OPTION(*EVENTF);                                     *
//     >>END-IMPORTANT<<                                               *
//     >>EXECUTE<<                                                     *
//     >>CMD<<     CRTSRVPGM    SRVPGM(&LI/&OB) +                      *
//                              MODULE(&LI/&OB)  +                     *
//                              EXPORT(*ALL) +                         *
//                              ACTGRP(*CALLER) +                      *
//                              BNDSRVPGM(*LIBL/BASICS1) +             *
//                              DETAIL(*BASIC) +                       *
//                              TGTRLS(*CURRENT) +                     *
//                              TEXT('SrvPgm  : Print log');           *
//   >>END-PRE-COMPILER<<                                              *
//=====================================================================*
ctl-opt nomain;
ctl-opt extbinint(*yes) bnddir('QC2LE');
ctl-opt datfmt(*iso) timfmt(*iso) debug(*yes);
/copy QPRTLOG,COPYRIGHT
//=====================================================================*
dcl-f PRTLOGP printer(*ext) usage(*output) usropn infds(prtf);

//  File information data structures ----------

dcl-ds prtf qualified;
  pagLen   int(5) pos(152);
  pagWidth int(5);
  ovrflw   int(5) pos(188);
  curLine  int(5) pos(367);
  curPage  int(10);
end-ds;

//  Prototypes of exported procedures ---------
/copy QPRTLOG,PPRTLOG

//  Prototypes of private procedures ----------

//  Start a new page.
dcl-pr p_newPage;
  i_pHandle pointer value;
end-pr;

//  Check for overflow.
dcl-pr f_isOverflow ind;
  i_pHandle pointer value;
end-pr;

//  Write empty line.
dcl-pr p_newLine;
  io_pHandle pointer;
end-pr;

//  Prototypes of C functions -----------------

//  Open a Record File for I/O Operations
dcl-pr rOpen pointer extproc('_Ropen');
  i_fileName pointer options(*string) value;
  i_mode     pointer options(*string) value;
end-pr;

//  Set the Record Format Name
dcl-pr rFormat extproc('_Rformat');
  i_handle pointer value;
  i_format pointer options(*string) value;
end-pr;

//  Write the Next Record
dcl-pr rWrite pointer extproc('_Rwrite');
  i_handle  pointer value;
  i_buffer  pointer value;
  i_bufSize uns(10) value;
end-pr;

//  Close a File
dcl-pr rClose int(10) extproc('_Rclose');
  i_handle pointer value;
end-pr;

//  Prototypes of system APIs -----------------

//  Internal reference fields -----------------

//  Handle
dcl-ds handle_t qualified template;
  pFile   pointer;
  is132   ind;
  ovrflw  int(10);
  row     int(10);
  headln  char(132);
  secLvl  ind;
  pageNbr int(10);
end-ds;

dcl-ds rFILE_t qualified template;
  res01   char(16);
  pInBuf  pointer;
  pOutBuf pointer;
  res02   char(48);
  riofb   likeds(rRIOFB_t);
  res03   char(32);
  bufLen  uns(10);
  res04   char(28);
  pInNull pointer;
  pOutNul pointer;
  pKeyNul pointer;
  res05   char(48);
  minLen  int(10);
  nMapLen int(5);
  nKeyLen int(5);
  res06   char(8);
end-ds;

dcl-ds rRIOFB_t qualified align template;
  pKey   pointer;
  pSysP  pointer;
  rrn    uns(10);
  numByt int(10);
  blkCnt int(5);
  blkFld char(1);
  bitfld char(1);
  dupKy  char(1) overlay(bitfld: 1);
  icfLc  char(1) overlay(bitfld: 1);
  res01  char(1) overlay(bitfld: 1);
  res02  char(20);
end-ds;

//  Printer file fields
dcl-s prtf_t_in ind template;
dcl-s prtf_t_headln char(66) template;
dcl-s prtf_t_headlnw char(118) template;
dcl-s prtf_t_headdt char(10) template;
dcl-s prtf_t_headtm char(8) template;
dcl-s prtf_t_headpg char(5) template;
dcl-s prtf_t_date char(8) template;
dcl-s prtf_t_time char(8) template;
dcl-s prtf_t_msgid char(7) template;
dcl-s prtf_t_msgtext char(40) template;
dcl-s prtf_t_msgtextw char(92) template;

//  Constants ---------------------------------

dcl-c cNEWPAGE_ROWS 2;
dcl-c cHEAD_ROWS 3;
dcl-c cPOS_ROWS 1;
dcl-c cNEWLINE_ROWS 1;

//=====================================================================*
//  Open print log.
//=====================================================================*
//  i_headline  -  Headline of the log.
//  i_secLvl    -  Print second level message text
//                   TRUE  = print second level text
//                   FALSE = do not print second level text
//  o_handle    -  Handle of the log, that must be passed to
//                 f_wrtPrtLog() and f_cloPrtLog().
//=====================================================================*
dcl-proc f_opnPrtLog export;
  dcl-pi *n ind;
    i_headline char(118) value;
    i_secLvl   ind value;
    o_handle   like(prtLog_handle_t);
  end-pi;

  //  Return value
  dcl-s isDone ind inz(cFalse);

  dcl-ds handle likeds(handle_t) based(pHandle);

  //  Fields
  dcl-s pFile pointer inz;
  dcl-s handleSize int(10) inz;

  dcl-ds rFILE likeds(rFILE_t) based(pFile);
  dcl-ds rRIOFB likeds(rRIOFB_t) based(pRIOFB);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  //  Open printer file to get OVERFLOW and PAGEWIDTH
  If not %open(PRTLOGP);
    Open PRTLOGP;
  Endif;

  //  Open new instance of printer file ...
  pFile = rOpen('PRTLOGP'   :
               'wr'        );

  If pFile = *NULL;
    isDone = cFalse;
  Else;
    pRIOFB = %addr(rFILE.riofb);

    //  Allocate memory for the new handle ...
    handleSize = %size(handle);
    pHandle = %alloc(handleSize);

    //  Set handle fields ...
    handle.pFile     = pFile;
    If prtf.pagWidth    >= 132;
      handle.is132 = *on;
    Else;
      handle.is132 = *off;
    Endif;
    handle.row       = 0;
    handle.ovrflw    = prtf.ovrflw;
    handle.headln    = %trim(i_headline);
    handle.secLvl    = i_secLvl;
    handle.pageNbr   = 0;
    isDone           = cTrue;
  Endif;

  //  CLose printer file
  If %open(PRTLOGP);
    close PRTLOGP;
  Endif;

  //  Start a new page ...
  p_newPage(pHandle);

  If isDone;
    o_handle = pHandle;
  Else;
    o_handle = *NULL;
  Endif;

  Return isDone;

end-proc;

//=====================================================================*
//  Write to print log.
//=====================================================================*
//  i_pHandle   -  Handle, that was paased back from the
//                 f_opnPrtLog() procedure.
//  i_msg       -  Message that is to be logged.
//=====================================================================*
dcl-proc f_wrtPrtLog export;
  dcl-pi *n ind;
    i_pHandle like(prtLog_handle_t) value;
    i_msg     likeds(msg_t) value;
  end-pi;

  //  Return value
  dcl-s isDone ind inz(cFalse);

  //  Fields
  dcl-ds handle likeds(handle_t) based(pHandle);

  dcl-ds pos qualified inz;
    in20    like(prtf_t_in);
    date    like(prtf_t_date);
    time    like(prtf_t_time);
    msgID   like(prtf_t_msgid);
    msgText like(prtf_t_msgtext);
  end-ds;

  dcl-ds posw qualified inz;
    in20     like(prtf_t_in);
    date     like(prtf_t_date);
    time     like(prtf_t_time);
    msgID    like(prtf_t_msgid);
    msgTextw like(prtf_t_msgtextw);
  end-ds;

  dcl-ds rRIOFB likeds(rRIOFB_t) based(prTgtIO);

  dcl-ds msg likeds(msg_t) inz;

  dcl-s text char(2048) inz;
  dcl-s startPos uns(10) inz;
  dcl-s timestamp timestamp inz;
  dcl-s time time inz;
  dcl-s date date inz;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  isDone  = cTrue;

  pHandle = i_pHandle;
  msg     = i_msg;

  timestamp = %timestamp();
  date = %date(timestamp);
  time = %time(timestamp);

  //     C                   Time                    timeStamp
  //     C                   Movel     timeStamp     date
  //     C                   Movel     timeStamp     time
  //
  //---------------------------------------------
  //  Print message text ...
  //---------------------------------------------
  If msg.ID <> '';
    text     = f_rtvMsgText(msg);
  Else;
    text     = msg.data;
  Endif;

  If %trim(text) <> '';
    startPos = 1;
  Else;
    startPos = 0;
  Endif;

  If handle.is132;
    //  ... set output fields.
    posw.in20  = *on;
    //     C     *DMY          Move      date          posw.date
    //     C     *HMS          Move      time          posw.time
    posw.date  = %scanrpl('/': '.': %char(date: *dmy));
    posw.time = %char(time: *hms);
    posw.msgID = msg.id;
  Else;
    //  ... set output fields.
    pos.in20   = *on;
    //     C     *DMY          Move      date          pos.date
    //     C     *HMS          Move      time          pos.time
    pos.date  = %scanrpl('/': '.': %char(date: *dmy));
    pos.time = %char(time: *hms);
    pos.msgID  = msg.id;
  Endif;

  //  Loop through msgText ...
  Dow startPos > 0;

    //  ... start a new page if required.
    If f_isOverflow(pHandle);
      p_newPage(phandle);
    Endif;

    //  ... select list width.
    If handle.is132;
      //      ... set output field.
      posw.msgTextw = f_wordWrap(text:
                             %size(posw.msgTextw):
                             startPos);
      //      ... select record format.
      rFormat(handle.pFile: 'POSW');
      //      ... write to printer file.
      prTgtIO = rWrite(handle.pFile:
                      %addr(posw):
                      %size(posw));
      If rRIOFB.numByt = 0;
        isDone = cFalse;
        //TODO:     C                   Goto      exit_fnc
        Return isDone;
      Endif;
    Else;
      //      ... set output field.
      pos.msgText   = f_wordWrap(text:
                             %size(pos.msgText):
                             startPos);
      //      ... select record format.
      rFormat(handle.pFile: 'POS');
      //      ... write to printer file.
      prTgtIO = rWrite(handle.pFile:
                      %addr(pos):
                      %size(pos));
      If rRIOFB.numByt = 0;
        isDone = cFalse;
        //TODO:     C                   Goto      exit_fnc
        Return isDone;
      Endif;
    Endif;

    //  ... adjust line counter.
    handle.row = handle.row + cPOS_ROWS;

    //  ... hide "date", "time" and "msgid".
    If handle.is132;
      posw.in20 = *off;
    Else;
      pos.in20 = *off;
    Endif;
  Enddo;

  //---------------------------------------------
  //  Print message help text ...
  //---------------------------------------------
  If handle.secLvl;

    If msg.id <> '';
      text = f_rtvMsgHelpText(msg);
    Else;
      text = '';
    Endif;

    If %trim(text) <> '';
      startPos = 1;
    Else;
      startPos = 0;
    Endif;

    If handle.is132;
      //  ... set output fields.
      posw.in20 = *off;
      //     C     *DMY          Move      date          posw.date
      //     C     *HMS          Move      time          posw.time
      posw.date  = %scanrpl('/': '.': %char(date: *dmy));
      posw.time =  %char(time: *hms);
      posw.msgID = msg.id;
    Else;
      //  ... set output fields.
      pos.in20 = *off;
      //     C     *DMY          Move      date          pos.date
      //     C     *HMS          Move      time          pos.time
      pos.date  = %scanrpl('/': '.': %char(date: *dmy));
      pos.time = %char(time: *hms);
      pos.msgID = msg.id;
    Endif;

    //  Loop through msgText ...
    Dow startPos > 0;

      //  ... start a new page if required.
      If f_isOverflow(pHandle);
        p_newPage(phandle);
      Endif;

      //  ... select list width.
      If handle.is132;
        //      ... set output field.
        posw.msgTextw = f_wordWrap(text:
                               %size(posw.msgTextw):
                               startPos);
        //      ... select record format.
        rFormat(handle.pFile: 'POSW');
        //      ... write to printer file.
        prTgtIO = rWrite(handle.pFile:
                        %addr(posw):
                        %size(posw));
        If rRIOFB.numByt = 0;
          isDone  = cFalse;
          //TODO:     C                   Goto      exit_fnc
          Return isDone;
        Endif;
      Else;
        //      ... set output field.
        pos.msgText = f_wordWrap(text:
                             %size(pos.msgText):
                             startPos);
        //      ... select record format.
        rFormat(handle.pFile: 'POS');
        //      ... write to printer file.
        prTgtIO = rWrite(handle.pFile:
                        %addr(pos):
                        %size(pos));
        If rRIOFB.numByt = 0;
          isDone = cFalse;
          //TODO:     C                   Goto      exit_fnc
          Return isDone;
        Endif;
      Endif;

      //  ... adjust line counter.
      handle.row = handle.row + cPOS_ROWS;

      //  ... hide "date", "time" and "msgid".
      If handle.is132;
        posw.in20 = *off;
      Else;
        pos.in20 = *off;
      Endif;
    Enddo;

  Endif;

  //     C     exit_fnc      Tag

  Return isDone;

end-proc;

//=====================================================================*
//  Close print log.
//=====================================================================*
//  io_pHandle  -  Handle, that was paased back from the
//                 f_opnPrtLog() procedure.
//=====================================================================*
dcl-proc f_cloPrtLog export;
  dcl-pi *n ind;
    io_pHandle like(prtLog_handle_t);
  end-pi;

  //  Return value
  dcl-s isDone ind inz(cFalse);

  //  Fields
  dcl-ds handle likeds(handle_t) based(pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  isDone = cTrue;

  pHandle = io_pHandle;

  If rClose(handle.pFile) = 0;
    isDone = cTrue;
    Dealloc io_pHandle;
    io_pHandle = *null;
  Else;
    isDone = cFalse;
  Endif;

  Return isDone;

end-proc;

//=====================================================================*
//  *** private ***
//  Start a new page.
//=====================================================================*
dcl-proc p_newPage;
  dcl-pi *n;
    i_pHandle pointer value;
  end-pi;

  //  Fields
  dcl-ds handle likeds(handle_t) based(pHandle);

  dcl-ds head1 qualified inz;
    headdt like(prtf_t_headdt) inz;
    headtm like(prtf_t_headtm) inz;
    headpg like(prtf_t_headpg) inz;
  end-ds;

  dcl-ds head2 qualified inz;
    headln like(prtf_t_headln) inz;
  end-ds;

  dcl-ds headw1 qualified inz;
    headdtw like(prtf_t_headdt) inz;
    headtmw like(prtf_t_headtm) inz;
    headpgw like(prtf_t_headpg) inz;
  end-ds;

  dcl-ds headw2 qualified inz;
    headlnw like(prtf_t_headlnw) inz;
  end-ds;

  dcl-ds rRIOFB likeds(rRIOFB_t) based(prTgtIO);

  dcl-s pageTmstmp timestamp;
  dcl-s pageDate date;
  dcl-s pageTime time;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pHandle = i_pHandle;

  //  Start a new page
  rFormat(handle.pFile: 'NEWPAGE');

  prTgtIO = rWrite(handle.pFile:
                  *null:
                  0);

  handle.row = cNEWPAGE_ROWS;
  //  ... adjust page counter
  handle.pageNbr = handle.pageNbr + 1;
  //  ... set Date and Time
  //     C                   Time                    pageTmstmp
  //     C                   Move      pageTmstmp    pageDate
  //     C                   Move      pageTmstmp    pageTime
  pageTmstmp=%timestamp();
  pageDate = %date(pageTmstmp);
  pageTime = %time(pageTmstmp);

  //  Write headline

  If handle.is132;
    //  ... set output fields.
    //     C     *EUR          Move      pageDate      headw1.headdtw
    //     C     *HMS:         Move      pageTime      headw1.headtmw
    headw1.headdtw = %char(pageDate:*eur);
    headw1.headtmw = %char(pageTime:*hms);
    Evalr headw1.headpgw = %trim(
                     %editc(handle.pageNbr :'Z'));
    headw2.headlnw =
                 f_center(handle.headln:
                          %size(headw2.headlnw));
    //  ... select record format for Headline 1
    rFormat(handle.pFile: 'HEADW1');
    //  ... write data to printer file.
    prTgtIO = rWrite(handle.pFile:
                    %addr(headw1):
                    %size(headw1));
    //  ... select record format for Headline 2
    rFormat(handle.pFile: 'HEADW2');
    //  ... write data to printer file.
    prTgtIO = rWrite(handle.pFile:
                    %addr(headw2):
                    %size(headw2));
  Else;
    //  ... set output fields.
    //     C     *EUR          Move      pageDate      head1.headdt
    //     C     *HMS:         Move      pageTime      head1.headtm
    head1.headdt = %char(pageDate:*eur);
    head1.headtm = %char(pageTime:*hms);
    Evalr head1.headpg = %trim(
                    %editc(handle.pageNbr :'Z'));
    head2.headln = f_center(handle.headln:
                           %size(head2.headln));
    //  ... select record format for Headline 1
    rFormat(handle.pFile: 'HEAD1');
    //  ... write data to printer file.
    prTgtIO = rWrite(handle.pFile:
                    %addr(head1):
                    %size(head1));
    //  ... select record format for Headline 2
    rFormat(handle.pFile: 'HEAD2');
    //  ... write data to printer file.
    prTgtIO = rWrite(handle.pFile:
                    %addr(head2):
                    %size(head2));
  Endif;

  //  Adjust line counter
  handle.row = handle.row + cHEAD_ROWS;

  Return;

end-proc;

//=====================================================================*
//  *** private ***
//  Check overflow condition.
//=====================================================================*
dcl-proc f_isOverflow;
  dcl-pi *n ind;
    i_pHandle pointer value;
  end-pi;

  //  Return value
  dcl-s isOverflow ind inz;

  //  Fields
  dcl-ds handle likeds(handle_t) based(pHandle);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pHandle = i_pHandle;

  If handle.row >= handle.ovrflw;
    isOverflow = *on;
  Else;
    isOverflow = *off;
  Endif;

  Return isOverflow;

end-proc;

//=====================================================================*
//  *** private ***
//  Write an empty line.
//=====================================================================*
dcl-proc p_newLine;
  dcl-pi *n;
    io_pHandle pointer;
  end-pi;

  //  Fields
  dcl-ds handle likeds(handle_t) based(pHandle);

  dcl-ds rRIOFB likeds(rRIOFB_t) based(prTgtIO);
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  pHandle = io_pHandle;

  rFormat(handle.pFile: 'NEWLINE');

  prTgtIO = rWrite(handle.pFile:
                  *null:
                  0);

  handle.row = handle.row + cNEWLINE_ROWS;

  Return;

end-proc;

