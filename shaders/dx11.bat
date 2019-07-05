echo off
IF NOT EXIST ".\dx11\." (
mkdir ".\dx11"
) 
IF NOT EXIST ".\dx11\fragment\." (
mkdir ".\dx11\fragment"
)
IF NOT EXIST ".\dx11\vertex\." (
mkdir ".\dx11\vertex"
)
echo on

shadercDebug.exe -f .\src\basic\basic.sc -o .\dx11\vertex\basic.bin --varyingdef .\src\basic\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_4_0 -O 3 -O3
shadercDebug.exe -f .\src\basic\colored.sc -o .\dx11\fragment\colored.bin --varyingdef .\src\basic\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_4_0 -O 3 -O3