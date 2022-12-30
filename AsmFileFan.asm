;////////////////////////////////////////////////////////////
;//  Adi-Soyadi			: Alper Alpaslan							       
;//  Numara			: 05190000480						  
;//  Tarih			: 21.06.2021						  
;//  Uygulama Adi		: Odev 2                                 
;//  
;//	 Aciklama		: Vantilatör Uygulamasý
;//	 				 
;////////////////////////////////////////////////////////////

main:
org 00H
	sjmp mainson
org 23H ; seri port kelime al
	sjmp kelimeal
mainson:
ms_bekleme equ -50000
	clr p3.5
	mov r6,#20	; zamanlayici için 1snlik integer
	mov r2,#60	; zamnalayici 1 dakika sayan integer
	mov r3,#5	; pmw sinyali için aç kapa oranini belirliyor sabit deger
	mov r7,#3	; maksimum 3 kere hiz ayari düsürebilecegi için atadigim deger
	mov r4,#0   ; zamanlayici için
	mov r0,#15  ; zamanlayici dakika sayici
	mov r5,#5	; aç kapa oranini ayarlayan degisken
	clr p2.5	; zamanlayici 120dk dan sonra kapaninca set edilen tus biti
	setb ps		; seri porta öncelik veriyoruz
	clr a
	mov tmod, #20h ; t1 8 bit auto reload	
	mov th1,#-7 	; baud 9600 for 12k mhz 
	mov scon,#50h	; smod 1 renable 1
	mov ie,#10010000b ; kesme yetkileri
	setb it1	; düsen kenarla kesme yapmasi için
	setb it0
	sjmp $	; kelime bekleme satiri
	
kelimeal:		; eger kesmeye girerse buraya gelecek 
	MOV a,sbuf ; kelime aliyor
calismayadevam:                 
	CJNE a,#'a',OFF	; eger basilan harf a degilse off a gidip kapatacak

ON:
	mov a,r3	; belirlenen zaman sabitini r5 e atiyor
	mov r5,a	
	setb ps					; seri portun önceligini arttriyor		
	jnb p3.2,zamanlayici	; eger zamanlayici tusuna basildiysa zamanlayiciya gidip süre islemini yapiyor
zamanlayicidon:
	jnb p3.3,hiztus			; eger hiz tusuna basildiysa hiz alt basligina gidip hiz islemini yapiyor
hiztusdon:
	MOV p2,#00000001B 		; dc motor saat yönünde dönmeye baslar
		
pwmbir:
	setb p1.7				; kare dalga üretmek için önce aciyoruz
pmwhizayarla:
	acall delay					; delay cagiriyor çünkü dalga periyodik olmali
	djnz r5,pmwhizayarla		; süre ile kare dalgalarin on off süreleri delay yaparak hizini ayarliyor

pmwiki:					
	clr  p1.7			
	mov a,r3				; zaman sabitini akümülatöre atiyor
	mov r5,a			
pmwhizayarlaalt:			; burada off süresini on ile toplami 5 olana kadar ayarliyor yani on süresi 3sn ise 2sn off yapiyor
	acall delay				
	inc r5					; r5 i arttirarak on ile off süresi toplami 5 olana kadar burada kaliyor 
	cjne r5,#7,pmwhizayarlaalt	; on off süresi toplamini 5 e esitliyor
	clr ti
	clr ri
	
	MOV a,sbuf 					; kelime aliyor
	CJNE a,#'k',ON				; a harfi mi diye kontrol ediliyor eger k harfi geldiyse off a gidip makineyi kapatir


	OFF:						; k harfi gelince makineyi 0 layip tamamen kapatiyor
	MOV a,sbuf 	
	MOV p2,#00000000b			; dc motoru kapatiyor
	mov sbuf,#00000000b
	clr ri
	clr a
	clr  p1.7			

reti						; kesmenin en üste dönüsü için
	
zamanlayici:				; ilk zamanlayici butonuna basilinca buraya geliyor
	setb p3.2				; zamanlayici tusunu eski haline getiriyor
	mov a,r0				
	subb a,#120				; zamanlayici degeri 120 dakikayi geçtimi diye kontrol ediliyor
	jc zamanlayiciarttir	; eger carry 1 olursa 120 dakika geçilmistir zamanlayici kapatilir yoksa zamanlayici arttir ile süre arttirilir

zamanlayicikapat:
	mov r0,#0
	clr c
	setb p2.5			
	sjmp zamanlayicidon		; zamanlayici kapatilip calismaya devam eder

zamanlayiciarttir:			; zamanlayicida ki süreye 30 eklenip yukarida butonlar tekrar eski haline getirilir
	mov a,r0
	add a,#30				; 30dk süresini arttirip tekrar r0 a atiyoruz
	mov r0,a			
	clr p3.5
	clr p2.5
sjmp zamanlayicidon			; en üst mainde çalismaya geri döner 

hiztus:						
	djnz r7,hiztusson		; en basta r7 ye 3 degerini atamistim 3 den fazla basilirsa hiz kademesi ilk haline dönüyor 
	setb p3.3				; butonu geri aliyorum
	mov r5,#5				; default degerlerini atiyorum
	mov r3,#5
	mov r7,#3				
sjmp hiztusdon				; en yukari mainde çalismaya geri döner
	
hiztusson:
	setb p3.3				; hiz tusunu eski haline getiriyor
	mov a,r3
	subb a,#1				; r3 r5 ne kadar azsa mainde on komutu o kadar az çalisiyor hiz ayari için 
	mov r3,a
	mov r5,a
sjmp hiztusdon				; çalismaya devam ediyor mainde
	

delay:
	mov r6,#20
	mov th0,#high(ms_bekleme)	

dk:
	mov a,r6							; burasi zamanlayici süresini ne kadar açik kalacagini ayarliyor
	mov r2,a							
sn:
zamanlayiciyagirme:
	jb   p2.5,dakikasaydon				; 120 dakikadan sonra tus aktif oluyor zamanlayiciya hiç girmiyor
	inc r4								; 1 sn sayiyor
	cjne r4,#60,dakikasaydon			; 1(60sn) dakika oluncaya kadar dakika saymaya gitmiyor
	mov r4,#0							; saniyeyi sifirliyor tekrar dakika saymayi için
	djnz r0,dakikasaydon				; r0 da süre tutuluyor 0 olunca makine kapaniyor yoksa çalismaya devam ediyor
sjmp OFF
dakikasaydon:
	mov r1,#20
ms:
	MOV a,sbuf 					; kelime aliyor degistiyse diye
	CJNE a,#'a',OFF				; a harfi mi diye kontrol ediliyor eger k harfi geldiyse off a gidip makineyi kapatir
	setb tr0 							; sayma baslat
	jnb tf0,$							; burasi klasik timer
	clr tf0
	clr tr0
	djnz r1,ms
	djnz r2,sn

ret

end