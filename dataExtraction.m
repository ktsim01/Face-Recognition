%{
Extracting images

for i = 1:8
    foldName = strcat('FDDB-folds/FDDB-fold-0', int2str(i), '.txt');
    fid = fopen(foldName,'rt');
    C = textscan(fid,'%s');
    fclose(fid);
    folds = [folds;C{:}];
end

numPics = size(folds,1);
faces = cell(1,numPics);

for i = 1:numPics
    picPath = strcat('originalPics/',string(folds(i)), '.jpg');
    img = imread(picPath);
    integral = calcIntegral(img);
    faces{i} = integral;
end

%}

% Extracting eyes
%{
clc
clear all
folds = [];
for i = 1:8
    foldName = strcat('FDDB-folds/FDDB-fold-0', int2str(i), '.txt');
    fid = fopen(foldName,'rt');
    C = textscan(fid,'%s');
    fclose(fid);
    folds = [folds;C{:}];
end

numPics = size(folds,1);
eyes = {};
eyeCount = 1;

for i = 1:numPics
    picPath = strcat('originalPics/',string(folds(i)), '.jpg');
    img = imread(picPath);
    EyeDetect=vision.CascadeObjectDetector('EyePairSmall');
    BB = EyeDetect(img);
    for j = 1:size(BB,1)
        bounding = BB(j,:);
        if(size(BB,1)>0 && size(BB,2)>0)
            Eyes=img([bounding(2):bounding(2)+bounding(4)],[bounding(1):bounding(1)+bounding(3)],:);
            %imshow(Eyes)
            integral = calcIntegral(Eyes);
            eyes{eyeCount} = integral;
            eyeCount = eyeCount+1;
        end
    end
end
%}


%{
ellipse = [];
annotationName = strcat('FDDB-folds/FDDB-fold-06-ellipseList.txt');
fid = fopen(annotationName,'rt');
C = textscan(fid,'%s');
fclose(fid);
ellipse = [ellipse,C{1}];

faces={};
nonFaces = {};
currLine = 1;
faceCount = 1;
while currLine <= size(ellipse,1)
    imgPath = strcat('originalPics/', string(ellipse(currLine)), '.jpg');
    img = imread(imgPath);
    numFace = str2double(ellipse(currLine+1));
    currLine = currLine+2;
    for j = 1:numFace
        a = str2double(ellipse(currLine));
        b = str2double(ellipse(currLine+1));
        angle = str2double(ellipse(currLine+2));
        x = str2double(ellipse(currLine+3));
        y = str2double(ellipse(currLine+4));
        [xb,yb] = bounding_box([a,b,x,y,angle]);

        faceImage = img([max(1,ceil(yb(1))):min(floor(yb(2)),size(img,1))],[max(1,ceil(xb(1))): min(floor(xb(2)),size(img,2))],:);

        top = size(img,1)-floor(yb(2));
        bottom = floor(min(yb(1),1));
        if top>bottom
            nonfaceImage = img([floor(yb(2)):size(img,1)], [max(floor(xb(1)),1):min(floor(xb(2)), size(img,2))], :);
        else
            nonfaceImage = img([1:floor(yb(1))], [max(floor(xb(1)),1):min(floor(xb(2)), size(img,2))], :);
        end

        faces{faceCount} = faceImage;
        nonFaces{faceCount} = nonfaceImage;
        faceCount = faceCount+1;
        currLine = currLine+6;
    end
end

%}
load eyes.mat

for i = 1:size(eyes,2)
    eyes{i} = imresize(eyes{i}, [19,19]);
end