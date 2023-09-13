function intensity = getCorners(img,x1,y1,x2,y2)
    a = img(y1,x1);
    b = img(y1,x2);
    c = img(y2,x1);
    d = img(y2,x2);
    intensity = d-(b+c)+a;
end