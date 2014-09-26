@echo off
cd %~dp0
echo =========================================================================
echo  Festlegen der Version, welche erstellt werden soll
echo =========================================================================
echo.
for /f "tokens=1,2,3 delims= " %%a in (
  'findstr /R \@TUDVersion{[0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9] source\tudscr-version.dtx'
) do set version=%%b
set /p append=%version%
set version=%version%%append%
if exist temp rmdir /s /q temp> nul
if exist release rmdir /s /q release> nul
echo =========================================================================
echo  Erzeugen der Klassen und der inline-Dokumentation fuer %version%
echo =========================================================================
xcopy source temp\ /s
cd temp
call clear.bat
mkdir tex\latex\tudscr
mkdir source\latex\tudscr
mkdir doc\latex\tudscr
echo \BaseDirectory{.}> docstrip.cfg
echo \UseTDS>> docstrip.cfg
tex tudscr.ins
rem move source\latex\tudscr\doc\tudscrman.sty source\latex\tudscr\doc\tutorials\
copy tex\latex\tudscr\tudscrdoc.cls tudscrdoc.cls
pdflatex "\def\tudfinalflag{}\input{tudscrsource.tex}"
pdflatex "\def\tudfinalflag{}\input{tudscrsource.tex}"
makeindex -s gglo.ist -o tudscrsource.gls tudscrsource.glo
makeindex -s gind.ist -o tudscrsource.ind tudscrsource.idx
pdflatex "\def\tudfinalflag{}\input{tudscrsource.tex}"
move  *.dtx            source\latex\tudscr\
move  tudscr.ins       source\latex\tudscr\
move  tudscrsource.tex source\latex\tudscr\
xcopy doc              source\latex\tudscr\doc\ /s
rem mkdir doc\latex\tudscr\tutorials
for /f %%f in ('dir  /b ..\*.md') do copy ..\%%f doc\latex\tudscr\%%~nf
move tudscrsource.pdf doc\latex\tudscr\
move logo             tex\latex\tudscr\
del *.* /q> nul
echo =========================================================================
echo  Erzeugen des Benutzerhandbuchs
echo =========================================================================
rem del source\latex\tudscr\doc\tudscr_test.tex> nul
copy tex\latex\tudscr\*.* doc
copy tex\latex\tudscr\logo\*.* doc
cd doc
pdflatex -shell-escape "\def\tudfinalflag{}\input{tudscr.tex}"
pdflatex "\def\tudfinalflag{}\input{tudscr.tex}"
pdflatex "\def\tudfinalflag{}\input{tudscr.tex}"
pdflatex "\def\tudfinalflag{}\input{tudscr.tex}"
pdflatex -shell-escape "\def\tudfinalflag{}\input{tudscr.tex}"
pdflatex "\def\tudfinalflag{}\def\tudprintflag{}\input{tudscr.tex}"
copy tudscr.pdf tudscr_print.pdf
pdflatex "\def\tudfinalflag{}\input{tudscr.tex}"
move tudscr*.pdf latex\tudscr
rem move tutorials\*.pdf latex\tudscr\tutorials\
del *.* /q> nul
rmdir /s /q examples> nul
echo =========================================================================
echo  Erzeugen der Installationdateien
echo =========================================================================
cd ..\install
tex tudscr-install.ins
rename *.bxt *.bat
setlocal enabledelayedexpansion
set "pattern=_VER_"
set "replace=_%version%_"
for %%a in (*.*) do (
  set "file=%%~a"
  rename "%%a" "!file:%pattern%=%replace%!"
)
endlocal
echo =========================================================================
echo  Release fuer GitHub
echo =========================================================================
cd %~dp0
mkdir release\temp
mkdir release\GitHub
copy *.md                                   release\temp\
copy development\fonts\*.*                  release\temp\
copy development\tools\*.*                  release\temp\
copy temp\doc\latex\tudscr\tudscr.pdf       release\temp\
copy temp\doc\latex\tudscr\tudscr_print.pdf release\temp\
move temp\install\*.*                       release\temp\
rmdir /s /q temp\install> nul
cd release\temp
7za a -tzip tudscr_%version%_full.zip   .\..\..\temp\*
7za a -tzip tudscr_%version%_update.zip .\..\..\temp\* -xr!logo
7za a -tzip tudscrfonts.zip             @7za_files_metrics.txt
for /f %%f in ('dir /b *.md') do unix2dos -n %%f %%~nf.txt
7za a -tzip .\..\TUD-KOMA-Script_%version%_Windows_all.zip    -x!*.sh             @7za_files_full.txt @7za_files_postscript.txt
7za a -tzip .\..\TUD-KOMA-Script_%version%_Windows_full.zip   -x!*.sh             @7za_files_full.txt
rem 7za a -tzip .\..\TUD-KOMA-Script_%version%_Windows_update.zip -x!*.sh             @7za_files_update.txt
7za a -tzip .\..\TUD-KOMA-Script_fonts_Windows.zip            -x!*.sh             @7za_files_fonts.txt
for /f %%f in ('dir /b *.md') do copy %%f %%~nf.txt
7za a -tzip .\..\TUD-KOMA-Script_%version%_Unix_all.zip       -x!*.bat -x!7za.exe @7za_files_full.txt @7za_files_postscript.txt
7za a -tzip .\..\TUD-KOMA-Script_%version%_Unix_full.zip      -x!*.bat -x!7za.exe @7za_files_full.txt
rem 7za a -tzip .\..\TUD-KOMA-Script_%version%_Unix_update.zip    -x!*.bat -x!7za.exe @7za_files_update.txt
7za a -tzip .\..\TUD-KOMA-Script_fonts_Unix.zip               -x!*.bat -x!7za.exe @7za_files_fonts.txt
cd..
attrib +h *_all.zip
move *.zip GitHub\
attrib -h *_all.zip
move temp\tudscr_%version%_full.zip  GitHub\tudscr_%version%.zip
rem move temp\tudscr_uninstall.*         GitHub\release\
echo =========================================================================
echo  Release fuer CTAN
echo =========================================================================
mkdir CTAN\tudscr\doc
mkdir CTAN\tudscr\source
mkdir CTAN\tudscr\tex
xcopy ..\temp\doc\latex\tudscr\*.*    CTAN\tudscr\doc\    /s
xcopy ..\temp\source\latex\tudscr\*.* CTAN\tudscr\source\ /s
xcopy ..\temp\tex\latex\tudscr\*.*    CTAN\tudscr\tex\    /s
echo =========================================================================
echo  Loeschen aller temporaeren Dateien
echo =========================================================================
pause.
cd %~dp0
if exist temp rmdir /s /q temp> nul
if exist release\temp rmdir /s /q release\temp> nul