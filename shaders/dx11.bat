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

shadercRelease.exe -f .\src\basic\basic_vs.sc -o .\dx11\vertex\basic_vs.bin --varyingdef .\src\basic\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_4_0 -O 3 -O3
shadercRelease.exe -f .\src\basic\basic_fs.sc -o .\dx11\fragment\basic_fs.bin --varyingdef .\src\basic\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_4_0 -O 3 -O3
shadercRelease.exe -f .\src\nuklear\nuklear_vs.sc -o .\dx11\vertex\nuklear_vs.bin --varyingdef .\src\nuklear\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_4_0 -O 3 -O3
shadercRelease.exe -f .\src\nuklear\nuklear_fs.sc -o .\dx11\fragment\nuklear_fs.bin --varyingdef .\src\nuklear\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_4_0 -O 3 -O3
shadercRelease.exe -f .\src\terrain\terrain_vs.sc -o .\dx11\vertex\terrain_vs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_4_0 --debug
shadercRelease.exe -f .\src\terrain\terrain_fs.sc -o .\dx11\vertex\terrain_fs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_5_0 --debug