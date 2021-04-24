1. Ambiente de desenvolvimento:
- Criar o arquivo da plataforma corrente (osx, win32, etc)
- Compilar de acordo com a plataforma (osx-llvm [clang], win32 [msvc], etc)
- Como funciona um compilador (gcc vs clang vs cl.exe)?
- Criar script de build
- Criar Xcode project Empty (other), importar o executable (com debug -g), criar novo scheme, importar como reference a pasta do source code

2. Open Window
- Criar a primeira Window e seu callback (handle)
- Run loop for Window
- Handle Resize
- Tint background with white | black (swap test)
- Adicionar dependencias no script
* Note: interface cannot be static (e.g. NSColor) at ObjC

3. Allocate backbuffer
- Quit run looping
- Resize handle with width and height (rect client) and create/delete a backbuffer bitmap (4 bytes RGBA)
- When paint, update the window (stretch if needed)

4. Animating backbuffer
- change offset x,y and redraw_buffer- 

5. Cleanup code
- extract all global into struct BackBuffer
- disable 'change and resize' and now, the image stretchs according window
