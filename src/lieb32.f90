! --------------------------------------------------------------------
! TMMultLieb3DAtoB:
!
! 3D version of TMMult2D. Extra boundary conditions

SUBROUTINE TMMultLieb3DAtoB5(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  USE MyNumbers
  USE IPara
  USE RNG
  USE DPara

  ! wave functions:
  !       
  ! (PSI_A, PSI_B) on input, (PSI_B,PSI_A) on output

  IMPLICIT NONE

  INTEGER Ilayer,           &! current # TM multiplications
       M                     ! strip width

  REAL(KIND=RKIND)  DiagDis,&! diagonal disorder
       En                    ! energy

  REAL(KIND=RKIND) PSI_A(M*M,M*M),PSI_B(M*M,M*M),OnsitePotVec(3*M,3*M)

  INTEGER jState, ISeedDummy,iSiteS,jSiteS, iSiteL,jSiteL, indexS,indexL
  REAL(KIND=RKIND) OnsitePot, OnsiteRight, OnsiteLeft, OnsiteUp, OnsiteDown
  REAL(KIND=RKIND) NEW, PsiLeft, PsiRight, PsiUp, PsiDown, stub

  INTEGER Coord2IndexL
  EXTERNAL Coord2IndexL

  !PRINT*,"DBG: TMMultLieb3DAtoB()"

  ! create the new onsite potential
  DO iSiteS=1,3*M
     DO jSiteS=1,3*M

        !indexS= (iSiteS-1)*3*M + jSiteS

        SELECT CASE(IRNGFlag)
        CASE(0)
           OnsitePotVec(iSiteS,jSiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
        CASE(1)
           OnsitePotVec(iSiteS,jSiteS)= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
        CASE(2)
           OnsitePotVec(iSiteS,jSiteS)= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
        END SELECT
     END DO
  END DO

  !PRINT*,"iS,pL,RndVec", iSite,pLevel,RndVec((pLevel-1)*M+iSite)

  !new TMM
  DO iSiteL=1,M
     DO jSiteL=1,M

        iSiteS= (iSiteL-1)*3 + 1
        jSiteS= (jSiteL-1)*3 + 1
        
        indexL= (jSiteL-1)*M + iSiteL
        !indexS= (jSiteS-1)*M + iSiteS
        
!!$        PRINT*,"iSL,jSL, iSS, jSS, iL, iLL", &
!!$             iSiteL,jSiteL, iSiteS,jSiteS, indexL,Coord2IndexL(M,iSiteL,jSiteL)

        OnsitePot=OnsitePotVec(iSiteS,jSiteS)

        DO jState=1,M*M
           
           !PsiLeft
           IF (iSiteL.LE.1) THEN
              IF (IBCFlag.EQ.0) THEN       ! hard wall BC
                 OnsiteLeft= ZERO
                 PsiLeft= ZERO               
              ELSE IF (IBCFlag.EQ.1) THEN  ! periodic BC
                 CONTINUE
              ELSE IF (IBCFlag.EQ.2) THEN  ! antiperiodic BC
                 CONTINUE
              ENDIF
           ELSE
              stub= OnsitePotVec(iSiteS-1,jSiteS)*OnSitePotVec(iSiteS-2,jSiteS)-1.0D0
              IF( ABS(stub).LT.TINY) THEN           
                 stub= SIGN(TINY,stub)
              ENDIF
              OnsiteLeft= OnsitePotVec(iSiteS-2,jSiteS)/stub
!!$              PsiLeft= Psi_A(jState,Coord2IndexL(M,iSiteL-1,jSiteL))/stub
              PsiLeft= Psi_A(Coord2IndexL(M,iSiteL-1,jSiteL),jState)/stub
           END IF

           !PsiRight
           IF (iSiteL.GE.M) THEN
              IF (IBCFlag.EQ.0) THEN        ! hard wall BC
                 OnsiteRight= ZERO
                 PsiRight= ZERO        
              ELSE IF (IBCFlag.EQ.1) THEN   ! periodic BC
                 CONTINUE
              ELSE IF (IBCFlag.EQ.2) THEN   ! antiperiodic BC
                 CONTINUE
              ENDIF
           ELSE
              stub= (OnsitePotVec(iSiteS+1,jSiteS)*OnSitePotVec(iSiteS+2,jSiteS)-1.0D0)
              IF( ABS(stub).LT.TINY) THEN             
                 stub= SIGN(TINY,stub)
              ENDIF
              OnsiteRight= OnsitePotVec(iSiteS+2,jSiteS)/stub
!!$              PsiRight= Psi_A(jState,Coord2IndexL(M,iSiteL+1,jSiteL))/stub
              PsiRight= Psi_A(Coord2IndexL(M,iSiteL+1,jSiteL),jState)/stub
           END IF

           !PsiUp
           IF (jSiteL.GE.M) THEN
              IF (IBCFlag.EQ.0) THEN        ! hard wall BC
                 OnsiteUp=ZERO      
                 PsiUp=ZERO
              ELSE IF (IBCFlag.EQ.1) THEN   ! periodic BC
                 CONTINUE
              ELSE IF (IBCFlag.EQ.2) THEN   ! antiperiodic BC
                 CONTINUE
              ENDIF
           ELSE
              stub= (OnsitePotVec(iSiteS,jSiteS+1)*OnSitePotVec(iSiteS,jSiteS+2)-1.0D0)
              IF( ABS(stub).LT.TINY) THEN
                 stub= SIGN(TINY,stub)
              ENDIF
              OnsiteUp= OnsitePotVec(iSiteS,jSiteS+2)/stub
!!$              PsiUp= Psi_A(jState,Coord2IndexL(M,iSiteL,jSiteL+1))/stub
              PsiUp= Psi_A(Coord2IndexL(M,iSiteL,jSiteL+1),jState)/stub
           END IF

           !PsiDown
           IF (jSiteL.LE.1) THEN
              IF (IBCFlag.EQ.0) THEN       ! hard wall BC
                 OnsiteDown= ZERO
                 PsiDown= ZERO                 
              ELSE IF (IBCFlag.EQ.1) THEN   ! periodic BC
                 CONTINUE
              ELSE IF (IBCFlag.EQ.2) THEN   ! antiperiodic BC
                 CONTINUE
              ENDIF
           ELSE
              stub= (OnsitePotVec(iSiteS,jSiteS-1)*OnSitePotVec(iSiteS,jSiteS-2)-1.0D0)
              IF( ABS(stub).LT.TINY) THEN
                 stub= SIGN(TINY,stub)
              ENDIF
              OnsiteDown= OnsitePotVec(iSiteS,jSiteS-2)/stub
!!$              PsiDown=  Psi_A(jState,Coord2IndexL(M,iSiteL,jSiteL-1))/stub
              PsiDown=  Psi_A(Coord2IndexL(M,iSiteL,jSiteL-1),jState)/stub
           END IF
!!$
!!$           NEW= ( OnsitePot - OnsiteLeft - OnsiteRight - OnsiteUp - OnsiteDown ) * &
!!$                Psi_A(jState,Coord2IndexL(M,iSiteL,jSiteL))&
!!$                - Kappa * ( PsiLeft + PsiRight + PsiUp + PsiDown  ) &
!!$                - PSI_B(jState,Coord2IndexL(M,iSiteL,jSiteL))
           NEW= ( OnsitePot - OnsiteLeft - OnsiteRight - OnsiteUp - OnsiteDown ) * &
                Psi_A(Coord2IndexL(M,iSiteL,jSiteL),jState)&
                - Kappa * ( PsiLeft + PsiRight + PsiUp + PsiDown  ) &
                - PSI_B(Coord2IndexL(M,iSiteL,jSiteL),jState)
           
!!$           PSI_B(jState,Coord2IndexL(M,iSiteL,jSiteL))= NEW
           PSI_B(Coord2IndexL(M,iSiteL,jSiteL),jState)= NEW
        END DO !jState
        
     END DO !iSiteL
  END DO !jSiteL
  RETURN

END SUBROUTINE TMMultLieb3DAtoB5

! --------------------------------------------------------------------
! convert i,j coordinates to an index
FUNCTION Coord2IndexL(isize, iSite, jSite)
  INTEGER Coord2IndexL, isize, iSite, jSite
  
  Coord2IndexL= (jSite-1)*isize + iSite
  
  RETURN
END FUNCTION Coord2IndexL

! --------------------------------------------------------------------
! TMMultLieb3DBtoA:
!
! 3D version of TMMult2D. Extra boundary conditions

SUBROUTINE TMMultLieb3DB5toB6(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  USE MyNumbers
  USE IPara
  USE RNG
  USE DPara
  
  ! wave functions:
  !       
  ! (PSI_A, PSI_B) on input, (PSI_B,PSI_A) on output
  
  IMPLICIT NONE
  
  INTEGER Ilayer,           &! current # TM multiplications
       M                     ! strip width
  
  REAL(KIND=RKIND)  DiagDis,&! diagonal disorder
       En                    ! energy
  
  REAL(KIND=CKIND) PSI_A(M*M,M*M), PSI_B(M*M,M*M)
  
  INTEGER iSite, jState, ISeedDummy
  REAL(KIND=RKIND) OnsitePot
  REAL(KIND=CKIND) NEW
  
  !PRINT*,"DBG: TMMultLieb3DBtoA()"
  
  DO iSite=1,M*M
     
     ! create the new onsite potential
     SELECT CASE(IRNGFlag)
     CASE(0)
        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)
     CASE(1)
        OnsitePot= -En + DiagDis*(DRANDOM(ISeedDummy)-0.5D0)*SQRT(12.0D0)
     CASE(2)
        OnsitePot= -En + GRANDOM(ISeedDummy,0.0D0,DiagDis)
     END SELECT
     
     !PRINT*,"iS,pL,RndVec", iSite,pLevel,RndVec((pLevel-1)*M+iSite)
     
     DO jState=1,M*M
        
        !PRINT*,"jState, iSite", jState, iSite,
!!$        
!!$        NEW= ( OnsitePot * PSI_A(jState,iSite) &
!!$             - PSI_B(jState,iSite) )
        NEW= ( OnsitePot * PSI_A(iSite,jState) &
             - PSI_B(iSite,jState) )
        
        !PRINT*,"i,jSite,En, OP, PL, PR, PA,PB, PN"
        !PRINT*, iSite, jState, En, OnsitePot, PsiLeft, PsiRight,
        !        PSI_A(iSite,jState), PSI_B(iSite,jState),
        !        new
        
!!$        PSI_B(jState,iSite)= NEW
        PSI_B(iSite,jState)= NEW
        
     ENDDO ! jState
  ENDDO ! iSite
  
  RETURN
END SUBROUTINE TMMultLieb3DB5toB6

SUBROUTINE TMMultLieb3DB6toA(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  USE MyNumbers
  USE IPara
  USE RNG
  USE DPara
  
  ! wave functions:
  !       
  ! (PSI_A, PSI_B) on input, (PSI_B,PSI_A) on output
  
  IMPLICIT NONE
  
  INTEGER Ilayer,           &! current # TM multiplications
       M                     ! strip width
  
  REAL(KIND=RKIND)  DiagDis,&! diagonal disorder
       En                    ! energy
  
  REAL(KIND=CKIND) PSI_A(M*M,M*M), PSI_B(M*M,M*M)
  
  INTEGER iSite, jState, ISeedDummy
  REAL(KIND=RKIND) OnsitePot
  REAL(KIND=CKIND) NEW

  CALL TMMultLieb3DB5toB6(PSI_A,PSI_B, Ilayer, En, DiagDis, M )

  RETURN
END SUBROUTINE TMMultLieb3DB6toA