#!/usr/bin/octave -q
##script to execute imEuler3d from http://in.mathworks.com/matlabcentral/fileexchange/33690-geometric-measures-in-2d-3d-images


####ToDo
## check only once if label actually exists and store result for use in j-loop

addpath ("~/octave/imMeasures/");

function pairId = CantorPairing(x, y)
  pairId= (x+y)*(x+y+1)/2 + y;
endfunction    

arg_list = argv ();
if nargin != 1
  fprintf(stderr, "Usage: %s <input3D.mha>\n", program_name);
  fprintf(stderr, "Decompressing MHAs/MHDs is very slow!\n");
  exit(1)
else
  fprintf(stderr, "Reading 3D data from %s ...\n", arg_list{1});
  i3dInfo= mha_read_header(arg_list{1});#from ~/octave/functions/
  fprintf(stderr, "ElementSize: %f, %f, %f\n", i3dInfo.PixelDimensions);
  i3d= mha_read_volume(i3dInfo);#from ~/octave/functions/
  fprintf(stderr, "Reading done.\n", arg_list{1});
  fprintf(stderr, "Image size: %d %d %d\n", size(i3d))
  # if nargin == 2
  #   if (arg_list{2} == "-q")
  #     quiet= 1;
  #   endif
  # endif
endif

if ndims(i3d) ~= 3
  error('Image has to be 3D!');
end

ll= min(min(min(i3d)));
ul= max(max(max(i3d)));
fprintf(stderr, "Image value range: %d to %d\n", ll, ul);


printf("L1\tL2\n")

n= imRAG(i3d);
printf("%d\t%d\n", n')

## print neighbours of specific label i:
# i= 7
# n( n(:,1) == i, 2)
