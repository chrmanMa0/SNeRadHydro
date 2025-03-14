      program readoutput
c********************************************************************
c                                                                   *
c  This program reads the unformatted file and prints readable      *
c  numbers.                                                         *
c                                                                   *
c********************************************************************
c
      implicit double precision (a-h,o-z)
c
      parameter (idim=10000)
      parameter (idim1=idim+1)
c
      dimension encm(0:idim1)
      dimension x(0:idim1), v(0:idim1),a(0:idim1)
      dimension q(idim), dq(idim), u(idim), ifleos(idim)
      dimension deltam(idim), abar(idim), rho(idim)
      dimension temp(idim), ye(idim), xp(idim), xn(idim)
      dimension ynue(idim), ynueb(idim), ynux(idim)
      dimension unue(idim), unueb(idim), unux(idim)
      dimension ufreez(idim), pr(idim), u2(idim)
      real ycc(idim,19)
      dimension eta(idim)
      dimension f2ynue(idim),f2ynueb(idim),f2ynux(idim)
      dimension f2unue(idim),f2unueb(idim),f2unux(idim)
      dimension etanue(idim),etanueb(idim),etanux(idim)
      dimension tempnue(idim), tempnueb(idim), tempnux(idim)
      logical te(idim), teb(idim), tx(idim)
      character*1 sample,again
      character*9 output,basename
      character*5 dumpn
      character*3 outname1
      character*4 outname2
      character*5 outname3
      character*6 outname4
      character*6 infile
      integer iskip
c
      double precision dm,press,enue,enueb,ks,ka,ksb,kab,
     $     ksx
c
      read *, infile
      open(42,file=infile,form='unformatted')
c
      pi43=3.14159265359*4.0/3.0
      idump=0
 97   continue
      print *,'number of dumps?'
      read *, ndump
c
c--read data
c     
      print *, 'output basename'
      read(*,fmt='(a)') basename
      ibasenamelen = index(basename,' ')-1

      idump=0
      do k=1,ndump
         vpeak=0.d0
         idump = idump+1
         read(42) nc,t,xmcore,rb,dlc,
     1   (x(i),i=0,nc),(v(i),i=0,nc),(q(i),i=1,nc),(dq(i),i=1,nc),
     2      (u(i),i=1,nc),(deltam(i),i=1,nc),(abar(i),i=1,nc),
     3      (rho(i),i=1,nc),(temp(i),i=1,nc),(ye(i),i=1,nc),
     7      (pr(i),i=1,nc),(u2(i),i=1,nc),
     $     ((ycc(i,j),j=1,17),i=1,nc)
c
         print *, rho(1),ftrape,ftrapb,ftrapx
         if (k.lt.40) then
            imp=1
c         else
c            imp=10
         end if
         if (mod(k,imp).eq.0) then
c            k1=36+int(k/imp)+1
            k1=int(k/imp)+1
            print *, k1
            rhomax=0.
            print *, 'xmcore',xmcore,t
            encm(0)=0.
cxmcore-0.4107
            dke=0.
            do i=1,nc
               encm(i)=encm(i-1)+deltam(i)
cpi43*(x(i)**3-x(i-1)**3)*rho(i)
               vesc=dsqrt(2.*13.34*encm(i-1)/x(i))
               if ((v(i)-vesc).gt.0) then
                  dke=dke+0.5*deltam(i)*(v(i)-vesc)**2
               end if
               if (v(i).gt.vpeak) then
                  vpeak=v(i)
                  xpeak=x(i)
               end if
            end do
            print *, dke
            vmin=0.
            do i=1,nc
               if (v(i).lt.vmin) then
                  vmin=v(i)
                  xshock=x(i)
               end if
               rhomax=max(rho(i),rhomax)
            end do
c            write(72,103) t,vmin,xshock,rho(1),rhomax
         
            if (k1.le.10) then
               write(dumpn,100) k1-1
 100           format('.',I1.1)
               outname1=basename(1:ibasenamelen)//dumpn//char(0)
               open(69,file=outname1)
            else if (k1.le.100) then
               write(dumpn,101) k1-1
 101           format('.',I2.2)
               outname2=basename(1:ibasenamelen)//dumpn//char(0)
               open(69,file=outname2)
            else if (k1.le.1000) then
               write(dumpn,102) k1-1
 102           format('.',I3.3)
               outname3=basename(1:ibasenamelen)//dumpn//char(0)
               open(69,file=outname3)
            else 
               write(dumpn,104) k1-1
 104           format('.',I4.4)
               outname4=basename(1:ibasenamelen)//dumpn//char(0)
               open(69,file=outname4)
            end if

            tautot=0.
            dk=0.
            dene=0.
            sumni=0.
            sumti=0.
            sumca=0.
            sumsi=0.
            sumc=0.
            sumo=0.
            sumne=0.
            summg=0.
            sums=0.
            sumar=0.
            sumcr=0.
            sumzn=0.
            sumfe=0.
            iskip=0
            write(70,*)xpeak,vpeak
            do i=1,nc
               write(69,103)i,encm(i),1.d9*x(i),2.d6*rho(i),1.d8*v(i)
     $              ,ye(i),eta(i),
     $              (u(i)*rho(i)*2.d22)**0.25/11600,
     $              u2(i),u(i)*1.d16,pr(i)
               if (encm(i).lt.199.) then
                  if (i.eq.1) then
                     dm=encm(1)
                  else
                     dm=encm(i)-encm(i-1)
                  end if
                  press=pr(i)*2.d22*dm
                  if (ynue(i).gt.0) then
                     enue=unue(i)/ynue(i)/96.44
                  else
                     enue=10.83
                  end if
                  if (ynueb(i).gt.0) then
                     enueb=unueb(i)/ynueb(i)/96.44
                  else
                     enueb=16.8
                  end if
                  if (ynux(i).gt.0) then
                     enux=unux(i)/ynux(i)/96.44
                  else
                     enux=25.
                  end if
                  ksx=0.2899/1.5799*1.512139d-20*enux**2*
     $                 2.d6*rho(i)
                  ks=1.512139d-20*enue**2*2.d6*rho(i)
                  ka=5.84973737d-20*enue**2*2.d6*rho(i)
                  ksb=1.512139d-20*enueb**2*2.d6
     $                 *rho(i)
                  kab=5.84973737d-20*enueb**2*2.d6
     $                 *rho(i)
                  if (i.eq.1) then
                     tautot=x(i)*(ks+ka)
                  else
                     tautot=tautot+(x(i)-x(i-1))*(ks+ka)
                  end if
                  vg=dsqrt(13.34*(encm(i))/x(i))
                  if (v(i).gt.vg) then
                     dk=dk+0.5*(deltam(i))*
     $                    (v(i)**2-vg**2)
                     if (ifleos(i).eq.1) then
                        dene=dene+0.5*(deltam(i))*
     $                       (v(i)**2-vg**2+2.*u(i))
                        if (u(i).lt.0.) then
                           print *, u(i),ifleos(i)
c                           stop
                        end if
                     elseif (ifleos(i).eq.2) then
                        ui=u(i)+860.
                        if (ui.lt.0.) then
                           print *, ui,ifleos(i)
c                           stop
                        end if
                        dene=dene+0.5*(deltam(i))*
     $                       (v(i)**2-vg**2+2.*ui)
                     end if
                  end if
                  if (v(i).gt.vg) then
                     sumni=sumni+deltam(i)*56.d0*ycc(i,16)
                     sumzn=sumzn+deltam(i)*60.d0*ycc(i,17)
                     sumfe=sumfe+deltam(i)*52.d0*ycc(i,15)
                     sumcr=sumcr+deltam(i)*48.d0*ycc(i,14)
                     sumti=sumti+deltam(i)*44.d0*ycc(i,13)
                     sumca=sumca+deltam(i)*40.d0*ycc(i,12)
                     sumar=sumar+deltam(i)*36.d0*ycc(i,11)
                     sums=sums+deltam(i)*32.d0*ycc(i,10)
                     sumsi=sumsi+deltam(i)*28.d0*ycc(i,9)
                     summg=summg+deltam(i)*24.d0*ycc(i,8)
                     sumne=sumne+deltam(i)*20.d0*ycc(i,7)
                     sumo=sumo+deltam(i)*16.d0*ycc(i,6)
                     sumc=sumc+deltam(i)*12.d0*ycc(i,5)
                  end if
c                  if (encm(i).gt.1.4506.and.encm(i).lt.1.4509) then
c                     write(71,103) t*10,encm(i),1.d9*x(i),1.d8*v(i),
c     $                 1.d8*vg,2.d6*rho(i),
c     $                 temp(i),ye(i),abar(i),
c     $                 28.*ycc(i,9),56.*ycc(i,16)
c                  end if
                  if (k.eq.nc) then
c                     write(70,103)encm(i),1.d9*x(i),1.d8*v(i),
c     $                    2.d6*rho(i),0.0862*eta(i)*temp(i),
c     $              etanue(i)*tempnue(i),
c     $              etanueb(i)*tempnueb(i),
c     $              etanux(i)*tempnux(i),
c--for aimee
c     $              etanue(i),
c     $              etanueb(i),
c     $              etanux(i),
c
c     $                    xn(i),xp(i),pr(i),temp(i)
                  end if
               end if
            end do
            print *, 'Nickel',sumc,sumo,sumne,summg,sumsi,sums,
     $           sumar,sumca,sumti,sumcr,sumfe,sumni,sumzn
         end if
         print *, 'energy',10*t/3600./24.,dk/50.,dene/50.
      end do
 103  format(I5,24(1pe12.4))

 107  format(I3,24(1pe13.5))
c
      end
      

c © 2020. Triad National Security, LLC. All rights reserved.

c This program was produced under U.S. Government contract 89233218CNA000001 for Los Alamos

c National Laboratory (LANL), which is operated by Triad National Security, LLC for the U.S.

c Department of Energy/National Nuclear Security Administration. All rights in the program are

c reserved by Triad National Security, LLC, and the U.S. Department of Energy/National Nuclear

c Security Administration. The Government is granted for itself and others acting on its behalf a

c nonexclusive, paid-up, irrevocable worldwide license in this material to reproduce, prepare

c derivative works, distribute copies to the public, perform publicly and display publicly, and to permit

c others to do so.
c This program is open source under the BSD-3 License.

c Redistribution and use in source and binary forms, with or without modification, are permitted

c provided that the following conditions are met:
c 1. Redistributions of source code must retain the above copyright notice, this list of conditions and

c the following disclaimer.

 

c 2.Redistributions in binary form must reproduce the above copyright notice, this list of conditions

c and the following disclaimer in the documentation and/or other materials provided with the

c distribution.

c 3.Neither the name of the copyright holder nor the names of its contributors may be used to endorse

c or promote products derived from this software without specific prior written permission.

c THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS

c IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE

c IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR

c PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR

c CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,

c EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,

c PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;

c OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,

c WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR

c OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF

c ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


