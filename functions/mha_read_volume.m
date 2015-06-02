function V = mha_read_volume(info)
% Function for reading the volume of a Insight Meta-Image (.mha, .mhd) file
% 
% from: http://www.mathworks.com/matlabcentral/fileexchange/29344-read-medical-data-3d/content//mha/mha_read_volume.m
% for zlib compression with java see e.g. http://www.mathworks.com/matlabcentral/fileexchange/8899-rapid-lossless-data-compression-of-numerical-or-string-variables/content//dunzip.m
% volume = tk_read_volume(file-header)
%
% examples:
% 1: info = mha_read_header()
%    V = mha_read_volume(info);
%    imshow(squeeze(V(:,:,round(end/2))),[]);
%
% 2: V = mha_read_volume('test.mha');

if(~isstruct(info)), info=mha_read_header(info); end


switch(lower(info.DataFile))
    case 'local'
    otherwise
    % Seperate file
    info.Filename=fullfile(fileparts(info.Filename),info.DataFile);
end
        
% Open file
switch(info.ByteOrder(1))
    case ('true')
        fid=fopen(info.Filename,'rb','ieee-be');
    otherwise
        fid=fopen(info.Filename,'rb','ieee-le');
end

switch(lower(info.DataFile))
    case 'local'
        % Skip header
        fseek(fid,info.HeaderSize,'bof');
    otherwise
        fseek(fid,0,'bof');
end

datasize=prod(info.Dimensions)*info.BitDepth/8;

switch(info.CompressedData(1))
    case 'f'
        % Read the Data
        switch(info.DataType)
            case 'char'
                 V = int8(fread(fid,datasize,'char')); 
            case 'uchar'
                V = uint8(fread(fid,datasize,'uchar')); 
            case 'short'
                V = int16(fread(fid,datasize,'short')); 
            case 'ushort'
                V = uint16(fread(fid,datasize,'ushort')); 
            case 'int'
                 V = int32(fread(fid,datasize,'int')); 
            case 'uint'
                 V = uint32(fread(fid,datasize,'uint')); 
            case 'float'
                 V = single(fread(fid,datasize,'float'));   
            case 'double'
                V = double(fread(fid,datasize,'double'));
        end
    case 't'
        switch(info.DataType)
            case 'char', DataType='int8';
            case 'uchar', DataType='uint8';
            case 'short', DataType='int16';
            case 'ushort', DataType='uint16';
            case 'int', DataType='int32';
            case 'uint', DataType='uint32';
            case 'float', DataType='single';
            case 'double', DataType='double';
        end
        V = zlib_decompress(info.Filename,info.HeaderSize,DataType);

end
fclose(fid);
V = reshape(V,info.Dimensions);

function M = zlib_decompress(fname,hsize,DataType)
a= javaObject('java.io.FileInputStream', fname);#replacement for java.io.ByteArrayInputStream(Z);
a.skip(hsize);
b= javaObject('java.util.zip.InflaterInputStream', a);
c= javaObject('java.io.ByteArrayOutputStream');

##BEGIN: replacement for com.mathworks.mlwidgets.io.InterruptibleStreamCopier copyStream(b,c);
buffer= javaArray('java.lang.Byte',4096)
len= javaObject('java.lang.Integer', 0);
off= javaObject('java.lang.Integer', 0);
max= javaObject('java.lang.Integer', 4096);
bc=0;
#while ((len = b.read(buffer)) != -1)#NoSuchMethodException
#while ((len = javaMethod('read','java.util.zip.InflaterInputStream',buffer)) != -1)
while ((len = b.read(buffer,off,max)) != -1)#NoSuchMethodException
  c.write(buffer, 0, len);
  bc+=len;
  fprintf(stderr, "\rread %d Bytes", bc);
end
##END: replacement for com.mathworks.mlwidgets.io.InterruptibleStreamCopier

fprintf(stderr, "read %d Bytes\n", bc);
c.close();
b.close();
a.close();
M=typecast(c.toByteArray,DataType);
