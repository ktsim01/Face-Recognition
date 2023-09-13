function outimg = integral(inimg)
    outimg = cumsum(cumsum(double(inimg),2));
end
