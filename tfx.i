%module tfx
%{
    #define TFX_IMPL
	#define TFX_GLCORE
	#include "tfx.h"
%}

%rename("%(strip:[tfx])s", %$isclass) "";
%rename("%(regex:/tfx(.*)/\\l\\1/)s", %$isfunction) "";
%rename("%(strip:[TFX_])s", %$isconstant) "";
%rename("%(strip:[TFX_])s", %$isenumitem) "";

%include "tfx.h"
