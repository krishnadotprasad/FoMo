

PRO which_line_fomo,ion=ion,w0=w0,cw0=cw0,lv1=lv1,lv2=lv2,all=all,fact=fact,num=num,enum=enum,silent=silent


;  Given an ion name and wavelength, it provides the Chianti
;  wavelength, the lower and upper levels of a line transition within 0.2% of the
;  input wavelength are searched for. This routine is based on the
;  routine 'which_line' of the Chianti distribution.
;
; INPUTS
;
; ion:  Name of an ion in the CHIANTI format. E.g., 'fe_13' for Fe XIII.
; w0:  wavelength of line transition in angstroms.

; OUTPUT:
;
; cw0: corresponding closest wavelength to w0 in the CHIANTI database
; lv1 = index of lower level of line transition (same
; nomenclature as Chianti's read_wgfa2)
; lv2 = index of upper level of line transition (same
; nomenclature as Chianti's read_wgfa2)
;
; If keyword 'silent' is not set it prints the atomic transition and
; wavelength for the line close to the input wavelength.
;
; OPTIONAL:
;
; ALL: If set, then lines with theoretical wavelengths are
;              included in the check.
; FACT: provide a factor to further reduce the wavelength
;range in which the search is made: w0*[1-0.002/fact,1+0.002/fact]
; NUM: In case of multiple lines within the range give the index
;number of the desired line through this keyword.
;
; EXAMPLE
;
; IDL> which_line,ion='o_6',w0=1032,cw0=cw0,lv1=lv1,lv2=lv2
;   cw0     lv1  lv2  Lower level           Upper level             A-value
;  1037.615   1   2   1s2.2s 2S1/2        - 1s2.2p 2P1/2          4.21e+008
;  1031.914   1   3   1s2.2s 2S1/2        - 1s2.2p 2P3/2          4.28e+008
; 
; CALLS
;
;     CONVERTNAME, ZION2FILENAME, READ_WGFA2, READ_ELVLC
;

IF ~keyword_set(ion) THEN BEGIN
  print,'which_line_fomo,ion=ion,w0=w0,cw0=cw0,lv1=lv1,lv2=lv2,all=all,silent=silent'
  return
ENDIF

convertname,ion,enum,inum,diel=diel
zion2filename,enum,inum,filename,diel=diel

wgfaname=filename+'.wgfa'
elvlcname=filename+'.elvlc'

read_wgfa2,wgfaname,lvl1,lvl2,wavel,gf,a_value,ref
read_elvlc,elvlcname,l1,term,conf,ss,ll,jj,ecm,eryd,ecmth,erydth,ref

factor1=0.002
if n_elements(fact) ne 0 then begin
   factor = factor1/fact
endif else begin
   factor = factor1
endelse

chck=w0*factor

;
; Find lines within wavelength range
;
ind=where(abs(abs(wavel)-w0) LE chck,n_ind)

;
; Filter out those lines with negative wavelengths.
;
IF NOT keyword_set(all) AND n_ind NE 0 THEN BEGIN
  k=where(wavel[ind] GT 0.,nk)
  IF nk NE 0 THEN ind=ind[k]
  n_ind=nk
ENDIF 

IF n_ind EQ 0 THEN BEGIN
  print,'% WHICH_LINE: no lines found within '+string(factor,format="(d0)")+'% of the wavelength '+string(w0)
  return
ENDIF

if n_ind GT 1 and n_elements(num) eq 0 then begin
   print,'more than 1 line found within '+string(factor,format="(d0)")+'% of the wavelength '+string(w0)
   print,abs(wavel[ind[sort(abs(wavel[ind]))]])
   return
endif
if n_ind gt 1 and n_elements(num) ne 0 then begin
   k = sort(abs(wavel[ind]))
   ind = ind[k[num]]
   cw0 = abs(wavel[ind])
endif
if n_ind eq 1 then begin
   k = sort(abs(wavel[ind]))
   ind = ind[k[0]]
   cw0 = abs(wavel[ind])
endif

if n_ind eq 1 or (n_ind gt 1 and n_elements(num) ne 0) then begin
   lv1 =lvl1[ind]
   lv2 =lvl2[ind]

   if ~keyword_set(silent) then begin
      print,'     cw0   lv1   lv2  Lower level           Upper level             A-value'
      j=ind
      term1=strpad(term[lvl1[j]-1],20,/after,fill=' ')
      term2=strpad(term[lvl2[j]-1],20,/after,fill=' ')
      print,format='(f14.3,2i4,"  ",a20,"- ",a20,e11.2)', $
            abs(wavel[j]),lvl1[j],lvl2[j], $
            term1,term2,a_value[j]
   endif
   IF NOT keyword_set(all) and ~keyword_set(silent) THEN BEGIN
      print,''
      print,'Use keyword /all to include lines with theoretical wavelengths.'
   ENDIF
endif

END
