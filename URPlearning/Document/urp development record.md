URP开发记录

对core shader library/urp shader library的复用

hlsl编写规范整理：

1.当编写一个功能pass的hlsl，需要用外部传进来的properties值时，不能将值的定义单独写在hlsl中，否则该变量无法进cbuffer从而无法进行batcher。

正确的做法：使用properties值的接口函数来代替直接写值，在引用这个pass的hlsl时，需要同时给出值的接口函数的定义，该pass才能被正确引用。



urp library复用注意：

ShaderCasterPass.hlsl : 会sample _BaseMap，因此albedo图名称定死为 _BaseMap。同时需要用到SurfaceInput.hlsl的采样alpha的函数用于clip，clip需要定义 _Cutoff变量，因此需要一个commonInput定义 _Cutoff变量。SurfaceInput.hlsl有一些texture定义例如 _BaseMap，注意不要重定义。