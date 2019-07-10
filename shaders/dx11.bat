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

shadercDebug.exe -f .\src\basic\basic.sc -o .\dx11\vertex\basic.h --varyingdef .\src\basic\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows --bin2c -p vs_4_0 -O 3 -O3
shadercDebug.exe -f .\src\basic\colored.sc -o .\dx11\fragment\colored.h --varyingdef .\src\basic\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows --bin2c -p ps_4_0 -O 3 -O3
shadercDebug.exe -f .\src\nuklear\nuklear_vs.sc -o .\dx11\vertex\nuklear_vs.h --varyingdef .\src\nuklear\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows --bin2c -p vs_4_0 -O 3 -O3
shadercDebug.exe -f .\src\nuklear\nuklear_fs.sc -o .\dx11\fragment\nuklear_fs.h --varyingdef .\src\nuklear\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows --bin2c -p ps_4_0 -O 3 -O3