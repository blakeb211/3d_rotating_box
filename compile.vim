" NOTE - must have the dlls in the same folder 

" build and run odin file
!odin run % -llvm-api 
"cd ..\src<CR>
"term clang++ -g -std=c++17 -fuse-ld=lld -Lc:\SFML\lib -IC:\SFML\include -lsfml-graphics -lsfml-window -lsfml-system global.cpp entity.cpp builder.cpp main1.cpp -o ..\build\game.exe

" Compile SFML Project WITH Audio
"
" term clang++ -std=c++17 -Lc:\SFML\lib -IC:\SFML\include -lsfml-audio -lsfml-graphics -lsfml-window -lsfml-system  % -o %.exe




