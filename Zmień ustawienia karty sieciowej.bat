@echo off
chcp 65001
cls
goto permisje

:permisje
net session >nul 2>&1
if %errorLevel% == 0 (echo.) else (echo.
echo Uruchom skrypt za pomocą Administratora.
echo.
pause
goto fail)

goto poczatek
:poczatek
cls
for /f "tokens=* delims==" %%i in ('netsh interface show interface ^| find "Admin"') do (echo %%i)
for /f "tokens=* delims==" %%i in ('netsh interface show interface ^| find "Connected"') do (echo %%i)

for /f "tokens=* delims==" %%i in ('netsh interface show interface ^| find "Connected"') do (set test=%%i)
set popkar=%test:~47%

echo.
set /p poczwyb=Wybrać %popkar%? [Y/N/Wyjdz] 
if %poczwyb%==y (goto a)
if %poczwyb%==n (echo.
set /p popkar=Podaj nazwę karty: 
goto a)
if %poczwyb%==wyjdz (goto exit) else (echo Błąd! Spróbuj ponownie!
pause>nul
goto poczatek)

:a
for /f "tokens=* delims==" %%a in ('netsh interface IPv4 show addresses "%popkar%" ^| find "IP Address"') do (set test=%%a)
set ipad=%test:~42%
cls
echo Karta: %popkar%, Adres IPv4: %ipad%
echo.
echo 1. Adres z puli DHCP
echo 2. Adres statyczny
echo 3. Wyświetl konfigurację karty
echo 4. Zmień kartę sieciową
echo 5. Wyjdź
echo:
set /p opcja=Wybierz: 

if %opcja%==1 (
netsh interface ip set address "%popkar%" dhcp
echo Gotowe!
goto exit)

if %opcja%==2 (goto opcja2)

if %opcja%==3 (goto opcja3) 

if %opcja%==4 (goto poczatek)

if %opcja%==5 (goto exit) else (echo Błąd! Spróbuj ponownie!
pause
goto a)

:opcja2
cls
echo.
echo 1. Presety
echo 2. Ustaw ręcznie
echo 3. Wyjdź
echo.
set /p opcja2w=Wybierz: 

if %opcja2w%==1 (goto opcja2a)
if %opcja2w%==2 (goto opcja2b)
if %opcja2w%==3 (goto a) else (goto opcja2)

:opcja2a
cls
echo Lp.	    Adres	 	Maska	 		Brama	 	Dns
echo 1. 	    10.0.0.10		255.255.255.0		---		---
echo 2. 	    10.0.0.10		255.255.255.0		10.0.0.1	---
echo 3. 	    10.0.0.10		255.255.255.0		10.0.0.1	8.8.8.8
echo 4. 	    192.168.0.10	255.255.255.0		---		---
echo 5. 	    192.168.0.10	255.255.255.0		192.168.0.1	---
echo 6. 	    192.168.0.10	255.255.255.0		192.168.0.1	8.8.8.8
echo.
echo 7. Wyjdź
echo.
set /p wpt=Wybierz: 
if %wpt%==1 (netsh interface ip set address name="%popkar%" static 10.0.0.10 255.255.255.0
goto pomyslny)
if %wpt%==2 (netsh interface ip set address name="%popkar%" static 10.0.0.10 255.255.255.0 10.0.0.1
goto pomyslny)
if %wpt%==3 (netsh interface ip set address name="%popkar%" static 10.0.0.10 255.255.255.0 10.0.0.1
netsh interface ip set dns name="%popkar%" static 8.8.8.8
goto pomyslny)
if %wpt%==4 (netsh interface ip set address name="%popkar%" static 192.168.0.10 255.255.255.0
goto pomyslny)
if %wpt%==5 (netsh interface ip set address name="%popkar%" static 192.168.0.10 255.255.255.0 192.168.0.1
goto pomyslny)
if %wpt%==6 (netsh interface ip set address name="%popkar%" static 192.168.0.10 255.255.255.0 192.168.0.1
netsh interface ip set dns name="%popkar%" static 8.8.8.8
goto pomyslny)
if %wpt%==7 (goto opcja2) else (goto opcja2a)

:opcja2b
cls
echo.
set /P adres=Podaj adres IPv4: 
set /P maska=Podaj maskę: 
echo.
set /p wybor=Ustawić bramę domyślną? [Y/N]: 
if %wybor%==y (goto ustawbrame) else (goto b)
if %wybor%==n (netsh interface ip set address name="%popkar%" static %adres% %maska%
goto b)


:ustawbrame
set /P brama=Podaj bramę domyślną: 
netsh interface ip set address name="%popkar%" static %adres% %maska% %brama%
echo.
goto b

:b
echo.
set /p wybor=Ustawić DNS? [Y/N]: 
if %wybor%==y (goto ustawdns) else (goto pomyslny)

:ustawdns
echo.
set /p pridns=Podaj preferowany serwer DNS: 
netsh interface ip set dns name="%popkar%" static %pridns%
goto pomyslny

:opcja3
cls
for /f "tokens=* delims==" %%x in ('netsh interface IPv4 show addresses "%popkar%" ^| findstr /C:"DHCP enabled"') do (set test=%%x)
set dhcpon=%test:~42%

for /f "tokens=* delims==" %%x in ('netsh interface IPv4 show addresses "%popkar%" ^| findstr /C:"Subnet Prefix"') do (set test=%%x)
set adresip=%test:~42,-20%
set maskaip=%test:~63,-1%

for /f "tokens=* delims==" %%x in ('netsh interface IPv4 show addresses "%popkar%" ^| findstr /C:"Default Gateway"') do (set test=%%x)
set bramaip=%test:~42%

for /f "tokens=* delims==" %%x in ('netsh interface IPv4 show dns "%popkar%" ^| findstr /C:"Statically Configured DNS Servers"') do (set test=%%x)
set dns=%test:~42%

echo.
echo Podsumowanie:
echo.
echo Włączony DHCP: %dhcpon%
echo.
echo Adres IPv4: %ipad%
echo.
echo Maska: %bramaip%
echo.
echo Sieć: %adresip%
echo.
echo Adres serwera DNS: %dns%
echo.
echo ------------------------------------
echo.

pause
goto a

:pomyslny
echo Gotowe!
netsh interface set interface "%popkar%" disable
netsh interface set interface "%popkar%" enable
goto exit

:exit
cls
echo Do zobaczenia! =D
echo Tiktok: @windows.guy
timeout /t 3 >nul

:fail
exit
