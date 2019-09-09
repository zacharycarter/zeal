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

shadercRelease.exe -f .\src\terrain\terrain_render_vs.sc -o .\dx11\vertex\terrain_render_vs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_5_0 --debug -O 0
shadercRelease.exe -f .\src\terrain\terrain_render_fs.sc -o .\dx11\fragment\terrain_render_fs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_5_0 --debug -O 0
shadercRelease.exe -f .\src\terrain\terrain_render_normal_fs.sc -o .\dx11\fragment\terrain_render_normal_fs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type fragment --platform windows -p ps_5_0 --debug -O 0
shadercRelease.exe -f .\src\terrain\terrain_lod_cs.sc -o .\dx11\compute\terrain_lod_cs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type compute --platform windows -p cs_5_0 --debug --disasm -O 0
shadercRelease.exe -f .\src\terrain\terrain_update_indirect_cs.sc -o .\dx11\compute\terrain_update_indirect_cs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type compute --platform windows -p cs_5_0 --debug --disasm -O 0
shadercRelease.exe -f .\src\terrain\terrain_update_draw_cs.sc -o .\dx11\compute\terrain_update_draw_cs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type compute --platform windows -p cs_5_0 --debug --disasm -O 0
shadercRelease.exe -f .\src\terrain\terrain_init_cs.sc -o .\dx11\compute\terrain_init_cs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type compute --platform windows -p cs_5_0 --debug --disasm -O 0