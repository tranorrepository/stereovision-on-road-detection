wd=zeros(5,5,10); wd(3,3,:)=1;
wd(3,:,1)=1;
wd(4,1:2,2)=1; wd(2,4:5,2)=1;
wd(4,1,3)=1;wd(3,2,3)=1;wd(3,4,3)=1;wd(2,5,3)=1;
wd(1,5,4)=1;wd(2,4,4)=1;wd(4,2,4)=1;wd(5,1,4)=1;
wd(4:5,2,5)=1;wd(1:2,4,5)=1;
wd(5,2,6)=1;wd(4,3,6)=1;wd(2,3,6)=1;wd(1,4,6)=1;
wd(:,3,7)=1;
wd(4:5,4,8)=1;wd(1:2,2,8)=1;
wd(5,4,9)=1;wd(4,3,9)=1;wd(2,3,9)=1;wd(1,2,9)=1;
wd(1,1,10)=1;wd(2,2,10)=1;wd(4,4,10)=1;wd(5,5,10)=1;
convimg=zeros(240,1310,10);
for i=1:10
    convimg(:,:,i)=conv2(kcsdil,wd(:,:,i),'same');
end
maxconvimg=max(convimg,[],3);