/* -------------------------------------------------------------------------- */
/* CRTMSGDS   - SCRIPT MEMBER                                                 */
/* Use commands  xmlgenINC (generate text for install pgm)                    */
/*               xmlgenMBR (to define source members                          */
/*               xmlgenCMD (execute qcmdexc at run time                       */
/* Put &TOLIB where you want user selected lib at run time.                   */
   DCL &TOLIB *CHAR 10
/* -------------------------------------------------------------------------- */
/* >>PRE-COMPILER<<                                                           */
/*   >>CRTCMD<<  XMLGEN  XMLSCRIPT(&SM) SCRIPTSRCF(&SL/&SF);                  */
/*   >>IMPORTANT<<                                                            */
/*     >>PARM<<  SRCTOFILE(&LI/QXML);                                         */
/*     >>PARM<<  XMLMBR(*SCRIPT);                                             */
/*     >>PARM<<  ENCODING('ISO-8859-1');                                      */
/*     >>PARM<<  AUTHOR('Thomas Raddatz');                                    */
/*   >>END-IMPORTANT<<                                                        */
/*   >>EXECUTE<<                                                              */
/* >>END-PRE-COMPILER<<                                                       */
/* -------------------------------------------------------------------------- */
             XMLGENINC  XINCLUDE(*YES)

             XMLGENVRS XSRCFILE(QPRTLOG) XSRCLIB(PRTLOGD) XSRCMBR(COPYRIGHT)

             XMLGENSET  XVAR(&SRCFILE) XVALUE(QPRTLOG)

             XMLGENCND  XMSG('Create sample programs? (YES, NO)') +
                          XVALUES(YES NO) XVAR(&CRTTSTPGM)

/* ---------------------------------- */
/*  Deploy source member              */
/* ---------------------------------- */
             XMLGENMBR  XMBR(A_INSTALL ) XMBRATR(CLLE  ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(A_README  ) XMBRATR(TXT   ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(COPYRIGHT ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*CMD    ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(PPRTLOG   ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*CMD    ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(PRTLOG_T  ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*CMD    ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(PRTLOG    ) XMBRATR(RPGLE ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*PGM    ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(PRTLOGP   ) XMBRATR(PRTF  ) +
                          XFROMSRCF(QPRTLOG   ) XFROMSRCL(PRTLOGD) +
                          XTOSRCF(QPRTLOG   ) XOBJTYPE(*PNLGRP ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

/* ---------------------------------- */
/*  Create objects                    */
/* ---------------------------------- */
             XMLGENCMD  XCMD(CRTBNDCL PGM(&TOLIB/A_INSTALL) +
                          SRCFILE(&TOLIB/QPRTLOG  ) SRCMBR(*PGM) +
                          DFTACTGRP(*NO) ACTGRP(*NEW) +
                          DBGVIEW(*LIST)) XDLTSPLF(A_INSTALL)

             XMLGENCMD  XCMD(CALL PGM(&TOLIB/A_INSTALL) +
                             PARM('&TGTRLS' '&SRCFILE' '&TOLIB' '&CRTTSTPGM'))
             XMLGENCMD  XCMD(DLTPGM PGM(&TOLIB/A_INSTALL))

