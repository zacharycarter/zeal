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
IF NOT EXIST ".\dx11\compute\." (
mkdir ".\dx11\compute"
)
echo on

shadercRelease.exe -f .\src\basic\basic_vs.sc -o .\dx11\vertex\basic_vs.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_5_0 --debug -O 0
shadercRelease.exe -f .\src\basic\basic_fs.sc -o .\dx11\fragment\basic_fs.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_5_0 --debug -O 0

shadercRelease.exe -f .\src\terrain\terrain_vs.sc -o .\dx11\vertex\terrain_vs.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_5_0 --debug -O 0
shadercRelease.exe -f .\src\terrain\terrain_fs.sc -o .\dx11\fragment\terrain_fs.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_5_0 --debug -O 0

shadercRelease.exe -f .\src\tonemap\tonemap_vs.sc -o .\dx11\vertex\tonemap_vs.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_5_0 --debug -O 0
shadercRelease.exe -f .\src\tonemap\tonemap_fs.sc -o .\dx11\fragment\tonemap_fs.bin --varyingdef .\src\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_5_0 --debug -O 0