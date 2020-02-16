
%---------------------------------------------------------------- 
% filename :main.m
% created by yufei at  2/14/2020
% description :The training set and test set were generated based on the images and labels, and the CNN training test was used to draw the original images, divide the images and forecast images, and output accuracy
%----------------------------------------------------------------
clear;
fname='image1.json'; %����ȡ���ļ�����
image_name='image1.TIF';%����ȡ��ͼƬ����
DataMark(fname,image_name);%���ݱ�Ǻ���

%��ȡ������ͼ������
load image_label
image=imread(image_name);%��ȡԭʼͼ��
[m1,n1,k1]=size(image);%ԭʼ�ߴ�
label2=label;


image=imresize(image,[m,n]);%����ͼ��ߴ磬���ʺ�cnn������
%ͼ���з֣���image��label�����з�Ϊc*r��16*16��cell����
c=zeros(1,m/16)+16;
r=zeros(1,n/16)+16;
image1=mat2cell(image,c,r,k);
label1=mat2cell(label,c,r);

%ͼ���ǣ����һ����1����������һ�룬��Ϊ��ˮ����Ϊ1����֮��Ϊ��½�ر��Ϊ0
label=zeros(m*n/16/16,k);
for i=1:m/16
    for j=1:n/16
        if(sum(sum(label1{i,j})))>128
            label((i-1)*m/16+j)=1;
        else
            label((i-1)*m/16+j)=0;
        end
    end
end


%��image1��cell����תΪ4D-array���ݣ�����Ϊcnn������
input=zeros(16,16,k,m*n/16/16);
for i=1:m/16
    for j=1:n/16
        input(:,:,:,(i-1)*m/16+j)=image1{i,j};
    end
end
output=categorical(label);%��double�͵�label����תΪcnn���õ�categorical������

train_input=input(:,:,:,1:floor(m*n*0.8/16/16));%ȡ80%������������Ϊѵ��������
test_input=input(:,:,:,ceil(m*n*0.8/16/16):m*n/16/16);%ȡ20%������������Ϊ���Լ�����
train_output=output(1:floor(m*n*0.8/16/16));%ȡ80%�����������Ϊѵ�������
test_output=output(ceil(m*n*0.8/16/16):m*n/16/16);%ȡ20%�����������Ϊ���Լ����


%���cnn
%�Ų���������
%1.����㣬���ݴ�С16*16*k��kΪͼ��ͨ������
%2.����㣬16��3*3��С�ľ���ˣ�����Ϊ1���Ա߽粹0��
%3.�ػ��㣬ʹ��2*2�ĺˣ�����Ϊ2��
%4.����㣬32��3*3��С�ľ���ˣ�����Ϊ1���Ա߽粹0��
%5.�ػ��㣬ʹ��2*2�ĺˣ�����Ϊ2��
%6.����㣬64��3*3��С�ľ���ˣ�����Ϊ1���Ա߽粹0��
%7.�ػ��㣬ʹ��2*2�ĺˣ�����Ϊ2��
%8.ȫ���Ӳ㣬30����Ԫ��
%9.ȫ���Ӳ㣬2����Ԫ��
layers = [
    imageInputLayer([16 16 k])%����㣬kΪͨ����
    
    convolution2dLayer(3,16,'Padding','same')%�����16��3*3�����
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)%�ػ���2*2������2
    
    convolution2dLayer(3,32,'Padding','same')%�����32��3*3�����
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)%�ػ���2*2������2
    
    convolution2dLayer(3,64,'Padding','same')%�����64��3*3�����
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)%�ػ���2*2������2
    
    fullyConnectedLayer(30)%30���ڵ��ȫ���Ӳ�
    fullyConnectedLayer(2)%2���ڵ��ȫ���Ӳ�
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...%ѧϰ����
    'MaxEpochs',10-ceil(m/1024)*2, ...%����������
    'Shuffle','every-epoch', ...
    'L2Regularization',0.001,...%L2���򻯲���
    'Verbose',false, ...
    'Plots','training-progress');
[net,info] = trainNetwork(train_input,train_output,layers,options);%ѵ������
 
%     'ValidationData',{test_input,test_output},...%��ֹ�����
%      'ValidationFrequency',10, ...
     
YPred = classify(net,test_input);%��������
if size(YPred)~=size(test_output)
    test_output=test_output';
end
accuracy = sum(YPred == test_output)/numel(test_output)%������Լ���ac��

YPred = classify(net,input);%��ȫ������Ž��������Ԥ�⣬����Ԥ�������ӻ�
out_image=zeros(m/16,n/16);%out_imageΪ���Ԥ��ͼƬ
for i=1:m/16 %��categorical��������ת��double��
    for j=1:n/16
        out_image(i,j)=YPred((i-1)*m/16+j);
        out_image(i,j)=out_image(i,j)-1;
    end
end
%չʾԭʼͼ�񡢻��ֺ�ͼ���Ԥ��ͼ��
subplot(2,2,1),imshow(imresize(image,[m1,n1])),title('ԭʼͼ��');
%���� ������ʱȡ��ˮ���������
subplot(2,2,2),imshow(imresize(label2,[m1,n1])),title('���ֺ�ͼ��');
out_image=imresize(out_image,[m1,n1]);%��ͼƬ��С����Ϊԭʼ��С

%ȡ�� ������ʱȡ��½�ؾ���ȡ��
% subplot(2,2,2),imshow(imresize(1-label2,[m1,n1])),title('���ֺ�ͼ��');
% out_image=imresize(1-out_image,[m1,n1]);%��ͼƬ��С����Ϊԭʼ��С
subplot(2,2,3),imshow(out_image),title('Ԥ��ͼ��');
