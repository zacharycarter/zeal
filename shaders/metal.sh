mkdir -p ./metal/vertex
mkdir -p ./metal/fragment
mkdir -p ./metal/compute

./shadercDebug -f ./src/basic/basic_vs.sc -o ./metal/vertex/basic_vs.bin --varyingdef ./src/varying.def.sc -i ../../bgfx/src -i ./src --type vertex --platform osx -p metal
./shadercDebug -f ./src/basic/basic_fs.sc -o ./metal/fragment/basic_fs.bin --varyingdef ./src/varying.def.sc -i ../../bgfx/src -i ./src --type fragment --platform osx -p metal

./shadercDebug -f ./src/terrain/terrain_vs.sc -o ./metal/vertex/terrain_vs.bin --varyingdef ./src/varying.def.sc -i ../../bgfx/src -i ./src --type vertex --platform osx -p metal
./shadercDebug -f ./src/terrain/terrain_fs.sc -o ./metal/fragment/terrain_fs.bin --varyingdef ./src/varying.def.sc -i ../../bgfx/src -i ./src --type fragment --platform osx -p metal

./shadercDebug -f ./src/tonemap/tonemap_vs.sc -o ./metal/vertex/tonemap_vs.bin --varyingdef ./src/varying.def.sc -i ../../bgfx/src -i ./src --type vertex --platform osx -p metal
./shadercDebug -f ./src/tonemap/tonemap_fs.sc -o ./metal/fragment/tonemap_fs.bin --varyingdef ./src/varying.def.sc -i ../../bgfx/src -i ./src --type fragment --platform osx -p metal