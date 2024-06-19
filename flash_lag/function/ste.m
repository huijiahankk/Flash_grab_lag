function ste=ste(y,dim)
if nargin==1
    dim = 1;
end
n=size(y,dim);

ste=std(y,0,dim)/sqrt(n);
return