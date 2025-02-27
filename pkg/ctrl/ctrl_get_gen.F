#include "CTRL_OPTIONS.h"

      subroutine ctrl_get_gen(
     I          xx_gen_file, xx_genstartdate, xx_genperiod,
     I          genmask, genfld, xx_gen0, xx_gen1, xx_gen_dummy,
     I          xx_gen_remo_intercept, xx_gen_remo_slope,
     I          genweight,
     I          myTime, myIter, myThid )

c     ==================================================================
c     SUBROUTINE ctrl_get_gen
c     ==================================================================
c
c     o new generic routine for reading time dependent control variables
c       heimbach@mit.edu 12-Jun-2003
c
c     ==================================================================
c     SUBROUTINE ctrl_get_gen
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "CTRL.h"
#include "OPTIMCYCLE.h"

c     == routine arguments ==
      character*(MAX_LEN_FNAM) xx_gen_file
      integer xx_genstartdate(4)
      _RL     xx_genperiod
      _RS     genmask(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL     genfld(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL     xx_gen0(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL     xx_gen1(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL     xx_gen_dummy
      _RL     xx_gen_remo_intercept
      _RL     xx_gen_remo_slope
      _RL     genweight(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RL     myTime
      integer myIter
      integer myThid

c     == external functions ==
      integer  ilnblnk
      external ilnblnk

c     == local variables ==
      integer bi,bj
      integer i,j
      integer jmin,jmax
      integer imin,imax
      integer ilgen

      _RL     gensign
      _RL     genfac
      logical doCtrlUpdate
      logical genfirst
      logical genchanged
      integer gencount0
      integer gencount1

      logical doglobalread
      logical ladinit

      character*(MAX_LEN_FNAM) fnamegen
#if ( defined ALLOW_SMOOTH && defined ALLOW_SMOOTH_CTRL2D )
      character*(MAX_LEN_FNAM) fnamegeneric
#endif
      character*(MAX_LEN_FNAM) xx_tauu_file
      character*(MAX_LEN_FNAM) xx_tauv_file
      character*(MAX_LEN_FNAM) xx_aqh_file
      character*(MAX_LEN_FNAM) xx_atemp_file
      character*(MAX_LEN_FNAM) xx_precip_file
      character*(MAX_LEN_FNAM) xx_lwdown_file
      character*(MAX_LEN_FNAM) xx_swdown_file

      INTEGER il

c     == end of interface ==

      jmin = 1-OLy
      jmax = sNy+OLy
      imin = 1-OLx
      imax = sNx+OLx

c--   Now, read the control vector.
      doglobalread = .false.
      ladinit      = .false.
      il   =ilnblnk( ctrlDir )

      if ( optimcycle .ge. 0 ) then
        ilgen=ilnblnk( xx_gen_file )
        write(fnamegen,'(2a,i10.10)')
     &    ctrlDir(1:il)//xx_gen_file(1:ilgen),'.effective.',optimcycle
      endif

c--   Get the counters, flags, and the interpolation factor.
      call ctrl_get_gen_rec(
     I                       xx_genstartdate, xx_genperiod,
     O                       genfac, genfirst, genchanged,
     O                       gencount0,gencount1,
     I                       myTime, myIter, myThid )

      if ( genfirst ) then
cc#ifdef ALLOW_OPENAD
cc        call oad_active_read_xy( fnamegen, xx_gen1, gencount0,
cc     &                       doglobalread, ladinit, optimcycle,
cc     &                       myThid, xx_gen_dummy )
cc#else
#ifdef ALLOW_AUTODIFF
        call active_read_xy( fnamegen, xx_gen1, gencount0,
     &                       doglobalread, ladinit, optimcycle,
     &                       myThid, xx_gen_dummy )
       if (.false.) then
        call active_read_xy( fnamegen, xx_gen0, gencount0,
     &                       doglobalread, ladinit, optimcycle,
     &                       myThid, xx_gen_dummy )
       endif
#else
        CALL READ_REC_XY_RL( fnamegen, xx_gen1, gencount0, 1, myThid )
#endif
cc#endif /* ALLOW_OPENAD */

#ifdef ALLOW_SMOOTH
#ifdef ALLOW_SMOOTH_CTRL2D
        if (useSMOOTH) call smooth2D(xx_gen1,genmask,1,myThid)
        write(fnamegeneric,'(2a,i10.10)')
     &    ctrlDir(1:il)//xx_gen_file(1:ilgen),'.smooth.',optimcycle
        CALL WRITE_REC_3D_RL( fnamegeneric, ctrlprec, 1,
     &             xx_gen1, gencount1, optimcycle, myThid )
#endif /* ALLOW_SMOOTH_CTRL2D */
#endif /* ALLOW_SMOOTH */

        endif

      if (( genfirst ) .or. ( genchanged )) then
        call CTRL_SWAPFFIELDS( xx_gen0, xx_gen1, myThid )

cc#ifdef ALLOW_OPENAD
cc        call oad_active_read_xy( fnamegen, xx_gen1 , gencount1,
cc     &                       doglobalread, ladinit, optimcycle,
cc     &                       myThid, xx_gen_dummy )
cc#else
#ifdef ALLOW_AUTODIFF
        call active_read_xy( fnamegen, xx_gen1 , gencount1,
     &                       doglobalread, ladinit, optimcycle,
     &                       myThid, xx_gen_dummy )
#else
        CALL READ_REC_XY_RL( fnamegen, xx_gen1, gencount1, 1, myThid )
#endif
cc#endif /* ALLOW_OPENAD */

#ifdef ALLOW_SMOOTH
#ifdef ALLOW_SMOOTH_CTRL2D
        if (useSMOOTH) call smooth2D(xx_gen1,genmask,1,myThid)
        write(fnamegeneric,'(2a,i10.10)')
     &     ctrlDir(1:il)//xx_gen_file(1:ilgen),'.smooth.',optimcycle
        CALL WRITE_REC_3D_RL( fnamegeneric, ctrlprec, 1,
     &             xx_gen1, gencount0, optimcycle, myThid )
#endif /* ALLOW_SMOOTH_CTRL2D */
#endif /* ALLOW_SMOOTH */

      endif

c--   Add control to model variable.
cph(
cph this flag ported from the SIO code
cph Initial wind stress adjustments are too vigorous.

      xx_tauu_file       = 'xx_tauu'
      xx_tauv_file       = 'xx_tauv'
      xx_aqh_file        = 'xx_aqh'
      xx_atemp_file      = 'xx_atemp'
      xx_precip_file     = 'xx_precip'
      xx_lwdown_file     = 'xx_lwdown'
      xx_swdown_file     = 'xx_swdown'

      if ( gencount0 .LE. 2 .AND. (
#ifdef CTRL_SKIP_FIRST_TWO_ATM_REC_ALL
     &       xx_gen_file(1:6) .EQ. xx_aqh_file  .OR.
     &       xx_gen_file(1:8) .EQ. xx_atemp_file .OR.
     &       xx_gen_file(1:9) .EQ. xx_precip_file .OR.
     &       xx_gen_file(1:9) .EQ. xx_lwdown_file .OR.
     &       xx_gen_file(1:9) .EQ. xx_swdown_file .OR.
#endif
     &       xx_gen_file(1:7) .EQ. xx_tauu_file .OR.
     &       xx_gen_file(1:7) .EQ. xx_tauv_file ) .AND.
     &     ( xx_genperiod .NE. zeroRL ) ) then
         doCtrlUpdate = .FALSE.
      else
         doCtrlUpdate = .TRUE.
      endif
      if ( xx_gen_file(1:7) .EQ. xx_tauu_file .OR.
     &     xx_gen_file(1:7) .EQ. xx_tauv_file ) then
         gensign = -1.
      else
         gensign = 1.
      endif

cph since the above is ECCO specific, we undo it here:
cph      doCtrlUpdate = .TRUE.
      if ( doCtrlUpdate ) then
cph)
       do bj = myByLo(myThid), myByHi(myThid)
        do bi = myBxLo(myThid), myBxHi(myThid)
c--       Calculate mask for tracer cells (0 => land, 1 => water).
          do j = 1,sNy
            do i = 1,sNx
              genfld(i,j,bi,bj) = genfld (i,j,bi,bj)
     &              + gensign*genfac            *xx_gen0(i,j,bi,bj)
     &              + gensign*(1. _d 0 - genfac)*xx_gen1(i,j,bi,bj)
              genfld(i,j,bi,bj) =
     &             genmask(i,j,bi,bj)*( genfld (i,j,bi,bj) -
     &             ( xx_gen_remo_intercept +
     &               xx_gen_remo_slope*(myTime-starttime) ) )
            enddo
          enddo
        enddo
       enddo
cph(
      endif
cph)

      RETURN
      END
