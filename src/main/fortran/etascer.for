      SUBROUTINE ETASCEr(IS,NMO,DOM,ETROUT)

C***************************************************************************
C
C   Function        : ETASCEr.for
C   Author          : E WILSON
C   Date            : November 2004
C   Purpose         : This calculates the alfalfa-based reference 
C                     evapotranspiration using the ASCE Penman-Monteith equation.
C   Calling program : etref.f 
C   Called programs : none
C   Input arguments : is     = current weather station   
C                     dom    = current day of month
C   Output arguments: etrout = reference evapotranspiration alfalfa-based 
C                              for the current day of year
C   Assumptions     :
C   Limitations     :
C   Notes           : The equation formulations are based on ASCE Manuals
C                     and Reports No. 70 on Evapotranspiration and Irriga-
C                     tion Water Requirements by Jensen et al., 1990, with
C                     modifications to reflect ASCE Standardized simplifications.
C
C   Definition of Important Variables:
C
C     Etr    =  Reference crop evapotranspiration (Alfalfa)
C     Eto    =  Referance crop evapotranspiration (Grass)
C     DELTA  =  Slope of the Saturation Vapor Pressure-Temperature curve
C     PC     =  Psychrometric Constant
C     RN     =  Net Radiation
C     G      =  Heat Flux Density to the ground
C     VPD    =  Vapor Pressure Deficit
C     Wf     =  Wind Function

C***************************************************************************

      INCLUDE 'pmdata.inc'
      INCLUDE 'pmcommon.inc'
      INCLUDE 'gcommon.inc'

C-----Local Variable Declaration
      INTEGER MON, DOM, N, M, DOY, IS, NMO
      REAL ETROUT, LAT_rad
      REAL DELTA, XLTHT, PC, PX, ALBEDO
      REAL XA1, A1, RBO, RSO, RATIO, A, B, outs
      REAL RB, G, UZ, VPD, XNUM, RAALF, XKK1
      REAL ETOALF1, ETOALF2, RN, FAC1, FAC2

      PX=101.3*((293-0.0065*WELEV(IS))/293)**5.26
      PC = 0.000665*PX
      Gday=0
      DELTA=2504.0*EXP((17.27*TAVG)/(TAVG+237.3))/(TAVG + 237.3)**2

      Es_min = 0.6108*EXP((17.27*TMIN)/(TMIN+237.3))  
      Es_max = 0.6108*EXP((17.27*TMAX)/(TMAX+237.3))  
      Es = (Es_min + Es_max)/2.0
      Ea = EDPT    

c look into vapor pressure measured vs calculated from dew point temp.
      UZ=WD/86.4
c  alfalfa based
      U_2r=Uz*4.87/(ALOG(67.8*ZM(IS)-5.42))
      DOY=JULIAN(NMO,DOM)
      Dr = 1 + 0.033*COS(2*PI*DOY/365)
      SD =  0.409 * SIN((2*PI*DOY/365)-1.39)
      LAT_rad = wlat(IS)*PI/180
      SS_ang = ACOS(-TAN(LAT_rad)*TAN(SD))
      Ra = (24.0/PI) * 4.92 * Dr * ((SS_ang * SIN(LAT_rad) * SIN(SD)) +
     &     (COS(LAT_rad) * COS(SD) * SIN(SS_ang)))
      tmaxt = tmax+273.16
      tmint = tmin+273.16
      Rso = (0.75 + 2.0E-5*welev(IS))*Ra
      Rnl = 4.901E-9*((TMAXT**4+TMINT**4)/2)*
     & (0.34 - 0.14*(Ea**0.5)) * (1.35*(Rs/Rso) - 0.35)

      Rns = (1 - 0.23)*Rs
      Rn = Rns - Rnl

c afalfa based
      CNr = 1600
      CDr = 0.38
      FAC1r = PC * Cnr/(TAVG + 273.0)
      FAC2r = U_2r * (Es - Ea)
      FAC3r = DELTA + PC * (1.0 + Cdr * U_2r)

      ETOALF1 = 0.408 * DELTA * (Rn-Gday)
      ETOALF2r = FAC1r * FAC2r

      ETROUT = (ETOALF1 + ETOALF2r) / FAC3r /25.4
!      write(533,*) nmo,dom,etrout
      DOY=JULIAN(NMO,DOM)

c      if(nmo .eq. 7 .and. dom .eq. 1) then
c      write(*,*) 'tavg = ', tavg
c      write(*,*) 'u_2r = ', u_2r
c      write(*,*) 'es = ', es
c      write(*,*) 'ea = ', ea
c      write(*,*) 'fac1r = ', fac1r
c      write(*,*) 'fac2r = ', fac2r
c      write(*,*) 'fac3r = ', fac3r
c      write(*,*) 'alf1 = ', etoalf1
c      write(*,*) 'alf2 = ', etoalf2r
c      write(*,*) 'etrout = ', etrout
c      pause
c      endif
      RETURN
      END