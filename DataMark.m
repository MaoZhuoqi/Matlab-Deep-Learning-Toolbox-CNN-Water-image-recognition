%---------------------------------------------------------------- 
% filename :DataMark.m
% created by yufei at  2/14/2020
% input list:
%               fname->str Json :file name
%               image_name->str :Image file name
% output list:
%               image_label.mat->double list :Image label data
%----------------------------------------------------------------
function  DataMark(fname,image_name)
% description :This function takes the generated json file and the original image as input data, and generates the image data label, with land as 0 and water as 1.

addpath('jsonlab\jsonlab'); %jsonlab���ļ����·��
jsonData=loadjson(fname);
[m,n,k]=size(imread(image_name));
m=ceil(m/16)*16;
n=ceil(n/16)*16;

%����labelme�Ļ������ɻ���ͼ��
I=zeros(m,n);
label=I;
% subplot(1,2,1),imshow(label),title('original');
[i,j]=size(jsonData.shapes);
for i=1:j
    c = jsonData.shapes{1, i}.points(:,1);
    r =  jsonData.shapes{1, i}.points(:,2);
    BW = roipoly(zeros(m,n),c,r);
    label = label+BW;
end

%����ͼ��Ĵ�С
if m<1024
    m=1024;
elseif m>4096
    m=4096;
end
if n<1024
    n=1024;
elseif n>4096
    n=4096;
end
label=imresize(label,[m,n]);

% subplot(1,2,2),imshow(label),title('Water display');
save('image_label.mat','label','image_name','m','n','k')
end