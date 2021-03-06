clear all;pause(0.01);
warning off;
f='D:\StereoLaptop_new\Image Collection(new Cam)58';
% f='D:\StereoLaptop_new\RealRun_Laptop_new_Cam\RealRunImg\test214';
% f='D:\StereoLaptop_new\Cali';
save_dir=f;

leftimg_dir=[f '\left'];
rightimg_dir=[f '\right'];
% save_dir=[f '\Offline'];
% % % leftimg_dir='D:\Stereo\RealRun_Laptop_new_Cam\RealRunImg\test93\left';
% % % rightimg_dir='D:\Stereo\RealRun_Laptop_new_Cam\RealRunImg\test93\right';
% % % save_dir='D:\Stereo\RealRun_Laptop_new_Cam\RealRunImg\test93\Offline';
% leftimg_dir='D:\Stereo\RealRun_Laptop\RealRunImg\test15\left';
% rightimg_dir='D:\Stereo\RealRun_Laptop\RealRunImg\test15\right';
% save_dir='D:\Stereo\RealRun_Laptop\RealRunImg\test15\offline';
% leftimg_dir='D:\Stereo\MPC\GA with Simple Map\Simulated Img\left';
% rightimg_dir='D:\Stereo\MPC\GA with Simple Map\Simulated Img\right';
% save_dir='D:\Stereo\MPC\GA with Simple Map\Simulated Img';
% leftimg_dir='D:\Stereo\Calibration\realcali\realleft';
% rightimg_dir='D:\Stereo\Calibration\realcali\realright';
% save_dir='D:\Stereo\Calibration\realcali';
figure;
%for Image Collection(new Cam)8
% log_ite_s=[2 461 243 115];
% log_ite_e=[126 812 378 530];
%for Image Collection(new Cam)58
log_ite_s=[225 1104 243 115];
log_ite_e=[973 1690 378 530];

% % hump_gt=[249:255 300:305 367:372 470:476 555:561 616:621];
% % zebra_gt=[135:143, 284:287, 579:586, 733:740];
% % arrow_gt=[5,6,7,8,9,10,46,47,48,49,50,51,64,65,66,67, ...
% %     96,97,98,99,100,101,105,106,107,108,109,110,111, ...
% %     124,125,126,127,128,149,150,151,152,166,167, ...
% %     191,192,193,194,206,207,208,216,217,218, ...
% %     665:668, 713:715, 726:729, 745:749, 756:760, ...
% %     763:768, 793:798, 812];
% % letter_gt=[15,16,17,18,19,66,67,68,69,70,71,72, ...
% %     93,94,95,96,97,98,116,117,118,129,130,131,132,133, ...
% %     234,235,236,240,241,242,243,247,248, ...
% %     291,292,293,294,295,296,297,298,348,349,350,351, ...
% %     355,356,357,360,361,362,363,463,464,465,466,467, ...
% %     543,544,545,546,547,548,549,550,551,552,601,602,603,604, ...
% %     607,608,609,611,612,613,614,717,718,719,729,730,731,732, ...
% %     766,767,768,769,770];
zebra_gt=0; letter_gt=0; hump_gt=0; arrow_gt=0;
% load('\detector_gt.mat');
FP_letter=0; FP_hump=0; FP_zebra=0; FP_arrow=0;
TP_letter=0; TP_hump=0; TP_zebra=0; TP_arrow=0;
FN_letter=0; FN_hump=0; FN_zebra=0; FN_arrow=0;
TN_letter=0; TN_hump=0; TN_zebra=0; TN_arrow=0;
%for Image Collection(new Cam)2,3,4
% log_ite_s=[1    170 318 459 622 770]; 
% log_ite_e=[113  250 381 541 710 860];
endf=zeros(1,857);
for outloop=1:1
ite_s=log_ite_s(outloop);
ite_e=log_ite_e(outloop);
preallocate_memory;
global_varibles;
InitializationGlobalVariable;
load (strcat(save_dir,'\cali3.mat')); %'cali3_old2.mat' is for img collection 6. The original webcam calibration results
load(strcat(save_dir,'\odemotry.mat'));%actural data readings from EV velocity and steering
% load 'fft_boundary.mat';
save_dir=f;
miss_infor_flag=0;
Phai0=0.3070;
D_pre=focal*tan(Phai0);H=1.665;marking_width_pre=0.10;diff_marking_width=0;lane_width=2.95;
marking_width_pre2=0.10;continue_frame=0;marking_width=0.1;
top_row=2*floor((cc_y-40)/2)-1; %make sure cc_y-40 is odd
btm_row=2*ceil((cc_y-480)/2); %make sure cc_y-480 is even
cc_y=2*ceil(cc_y/2);
% D_pre=174.4855; H=1.6428;
SampleRectification;
Ridge_width_ini=8.5;
ImgSize1=480; ImgSize2=640; NFFT=2^nextpow2(ImgSize2);
fre_seq=ImgSize2/2*linspace(0,1,NFFT/2+1);
wd=zeros(5,5,8); wd(3,3,:)=1;
wd(3,:,1)=1;
wd(4,1:2,2)=1; wd(2,4:5,2)=1;wd(3,2,2)=1;wd(3,4,2)=1;
wd(1,5,3)=1;wd(2,4,3)=1;wd(4,2,3)=1;wd(5,1,3)=1;
wd(4:5,2,4)=1;wd(1:2,4,4)=1;wd(4,3,4)=1;wd(2,3,4)=1;
wd(:,3,5)=1;
wd(4:5,4,6)=1;wd(1:2,2,6)=1;wd(4,3,6)=1;wd(2,3,6)=1;
wd(1,1,7)=1;wd(2,2,7)=1;wd(4,4,7)=1;wd(5,5,7)=1;
wd(2,1:2,8)=1; wd(4,4:5,8)=1; wd(3,2,8)=1; wd(3,4,8)=1;
convimg=zeros(240,1310,8);
kcsditmpl=zeros(ImgSize1/2,ImgSize2);
kcsditmpr=zeros(ImgSize1/2,ImgSize2);
xtmpl=[]; xtmpr=[];
%Image Collection 2
% ite_s=52; ite_e=405;
% ite_s=646; ite_e=845;
% ite_s=961; ite_e=1255;
% ite_s=1516; ite_e=1800;
% Theta=-5/180*pi;

% This block is for template matching initialization
load 'roadmarkingtemplates_low.mat';
del_w=-30:5:30;
theta=asin(del_w/65);
del_h=floor(26*cos(theta));
log_ind=cell(1,length(del_w));
log_mask=cell(1,length(del_w));
for i=1:length(del_w)
    log_ind{i}=[round((65*sin(theta(i))-1)/(26*cos(theta(i))-1)*((1:del_h(i))-1)+1); 1:del_h(i)];
    x=[log_ind{i}(1,:) log_ind{i}(1,:)+1 log_ind{i}(1,:)+2];
    y=[log_ind{i}(2,:) log_ind{i}(2,:) log_ind{i}(2,:)];
    min_x=min(x);
    if min_x<=0
        x=x-min_x+1;
    end
    mask=zeros(max(y), max(x));
    ind=sub2ind(size(mask),y,x);
    mask(ind)=1;
    log_mask{i}=mask;
end
log_atrribute=cell(1,30);
[ximg,yimg]=meshgrid(1:640,1:2:480);
xxc=-ximg+cc_x_right;
yyc=-yimg+cc_y;
total_counter=0;

%This block is for arrow recognition
load 'pca_temp3.mat';
load 'pca_temp3_arrow_tip2.mat';
win_r=16; win_c=30;
conv_win=ones(win_r,win_c);
ratio=(((1:(win_r/2))+win_r/2)/win_r)';
ratio_top=repmat(ratio,1,150/2);
ratio=((((win_r/2):-1:1)+win_r/2)/win_r)';
ratio_btm=repmat(ratio,1,150/2);

%This block is for zebra recognition
B_zebra=zeros(225,150);
NFFT_zebra=2^nextpow2(size(B_zebra,2));
fre_seq_zebra=size(B_zebra,2)/2*linspace(0,1,NFFT_zebra/2+1);

%This block is for hump recognition
B_hump=zeros(225,150);
NFFT_hump=2^nextpow2(size(B_hump,2));
fre_seq_hump=size(B_hump,2)/2*linspace(0,1,NFFT_hump/2+1);

    
    
% Image Collection 3
% ite_s=1; ite_e=415;
% ite_s=571; ite_e=930;
% ite_s=1041; ite_e=1230;
% ite_s=1321; ite_e=1560;
% ite_s=1681; ite_e=2050;
% ite_s=2166; ite_e=2460;

%Image Collection 4
% ite_s=516; ite_e=560;
% ite_s=2150; ite_e=2220;
% ite_s=1; ite_e=400;
% ite_s=516; ite_e=965;
% ite_s=1100; ite_e=1345;
% ite_s=1435; ite_e=1700;
% ite_s=1834; ite_e=2250;
% ite_s=2368; ite_e=2680;
Theta=-0.002; 
% offset_vector=[-0.09;0.01;-0.34]; %World=R*Cam+offset_vector;
offset_vector=[-0.0;0.01;-0.34]; %World=R*Cam+offset_vector;
[Tpix2cam_left, Tpix2cam_right]=Pix2Cam(focal,cc_x_left,cc_x_right,cc_y);

pre_line_type=1;
% ite_s=1384; ite_e=1498;
% vid1 = videoinput('winvideo', 1, 'YUY2_640x480');
% set(vid1,'FramesPerTrigger',1);
% set(vid1,'TriggerRepeat',Inf);
% triggerconfig(vid1,'manual');
% start(vid1);
% preview(vid1);
% log_dumy=zeros(1,2);
ximg=[]; yimg=[]; log_xyimg{1}=[];
ix1=[]; xfil3={[]}; 
%%
try
KickOff_PF2;
log_p_tip(ii)=0;
tdx1=tdx;
% intesnity_td_min=230;
% intesnity_td_max=255;
for ii=(ite_s+1):ite_e
    if ii==422
        a=0;
    end
    in_start=tic;
%     trigger(vid1);
%     dd=getdata(vid1);
    % [v_m, phai_m]=get_measurements;
    v_m=act_v(ii); phai_m=act_phai(ii);
    leftimg=imread(strcat(leftimg_dir,int2str(ii),'.jpg'));
    rightimg=imread(strcat(rightimg_dir,int2str(ii),'.jpg'));
    start=tic;
    leftimg=double(max(leftimg,[],3));
    rightimg=double(max(rightimg,[],3));
    % tic
    leftimg=Retify(leftimg,a1_left,a2_left,a3_left,a4_left,ind_1_left,ind_2_left,ind_3_left,ind_4_left,ind_new_left);
    rightimg=Retify(rightimg,a1_right,a2_right,a3_right,a4_right,ind_1_right,ind_2_right,ind_3_right,ind_4_right,ind_new_right);
    img=[leftimg(1:2:ImgSize1,:) zeros(ImgSize1/2, 30) rightimg(1:2:ImgSize1,:)];
    img(235:end,:)=0;
    mask=img;mask(img<intesnity_td_min)=0;mask(img>=intesnity_td_min)=1;mask(img>intesnity_td_max)=0;
    
%     C_in_region(dumy,xtmpli_lb,xtmpli_rb,xtmpri_lb+ImgSize2+30,xtmpri_rb+ImgSize2+30,ytopr,ybtmr);
    expo_mask=C_in_region(img, expos_box{1}, expos_box{2}, expos_box{3}+ImgSize2+30, expos_box{4}+ImgSize2+30, expos_box{5}, expos_box{6});
    expo_mask(1:25,:)=0;
    expo_mask_l1=expo_mask(25:55,1:ImgSize2); 
    expo_mask_l2=expo_mask(56:120,1:ImgSize2); 
    expo_mask_l3=expo_mask(121:end,1:ImgSize2); 
    log_road_bright_l(ii)=mean(expo_mask_l1(expo_mask_l1~=0))+ ...
                            mean(expo_mask_l2(expo_mask_l2~=0))+ ...
                            mean(expo_mask_l3(expo_mask_l3~=0));
    log_road_bright_l(ii)=log_road_bright_l(ii)/3;
    
    expo_mask_r1=expo_mask(25:55,(ImgSize2+31):end);
    expo_mask_r2=expo_mask(56:120,(ImgSize2+31):end);
    expo_mask_r3=expo_mask(121:end,(ImgSize2+31):end);
    log_road_bright_r(ii)=mean(expo_mask_r1(expo_mask_r1~=0))+ ...
                            mean(expo_mask_r2(expo_mask_r2~=0))+ ...
                            mean(expo_mask_r3(expo_mask_r3~=0));
    log_road_bright_r(ii)=log_road_bright_r(ii)/3;

    temp_p=0.3; temp_H=1.66; temp_td=230; 
%     log_xyimg{ii}=[]; % delet
% %     letter_t=tic;
    template_matching;
% %     log_letter_t(ii)=toc(letter_t);
    
    ImgSmooth=zeros(size(img));
    for i=1:(length(ix)-1)
        ImgSmooth(ix(i):(ix(i+1)-1),:)=conv2(img(ix(i):(ix(i+1)-1),:),xfil2{i},'same');
    end
    maxconvimg=C_new_Ridge(ImgSmooth,tdx,Offset);
    maxconvimg=maxconvimg.*mask;
    C_refine_Ridge(maxconvimg,Offset);
%     log_total_num(ii)=sum(maxconvimg(:));
    
% % % %     if ~isempty(ix1)
% % % %         ImgSmooth=zeros(size(img));
% % % %         for i=1:(length(ix1)-1)
% % % %             ImgSmooth(ix1(i):(ix1(i+1)-1),:)=conv2(img(ix1(i):(ix1(i+1)-1),:),xfil3{i},'same');
% % % %         end
% % % %         maxconvimg1=C_new_Ridge(ImgSmooth,tdx1,Offset);
% % % %         maxconvimg1=maxconvimg1.*mask;
% % % %         C_refine_Ridge(maxconvimg1,Offset);
% % % %         if sum(maxconvimg(:))<sum(maxconvimg1(:))
% % % %             maxconvimg=maxconvimg1;
% % % %             ix=ix1; tdx=tdx1; xfil2=xfil3;
% % % %         end
% % % %     end
    
    dumy3=maxconvimg(1:end,1:end); %after ridge detection
    
    if (isempty(ximg) && ~isempty(log_xyimg{ii-1})) || (isempty(ximg) && ~isempty(log_xyimg{ii-2}))
        new_states=C_Predict_P([0;0;pi/2],loop_t,loop_phi,loop_v);
        d_theta_letter=-new_states(3)+pi/2;
        R_letter=[cos(d_theta_letter) -sin(d_theta_letter); sin(d_theta_letter) cos(d_theta_letter)];
        T_letter=-R_letter*[new_states(1); new_states(2)];
        RT_letter=[R_letter T_letter; 0 0 1];
        xzW_letter=RT_letter*[xW_letter;zW_letter+L_wheel_cam;ones(1,length(xW_letter))];
        xW_letter=xzW_letter(1,:); zW_letter=xzW_letter(2,:)-L_wheel_cam;
        xC_letter=focal*xW_letter./(temp_H*sin(temp_p)+cos(temp_p)*zW_letter);
        yC_letter=(zW_letter*sin(temp_p)*focal-temp_H*focal*cos(temp_p))./(temp_H*sin(temp_p)+zW_letter*cos(temp_p));
        ximg=-xC_letter+cc_x_right;
        yimg=-yC_letter+cc_y;
        if min(yimg)>480
            ximg=[]; yimg=[];
        else
            ximg=[ximg ximg(1)]; yimg=[yimg yimg(1)];
        end
    end
    if ~isempty(ximg)
        ximg1=ximg(1:4)+ImgSize2+30; yimg1=yimg(1:4)/2;
        min_x=max([ImgSize2+31, min(ximg1)]);   max_x=min([2*ImgSize2+30, max(ximg1)]);
        min_y=max([1, min(yimg1)]);             max_y=min([ImgSize1/2, max(yimg1)]);
        maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
        maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
        [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
        if ~isempty(maxconvimgtmp_x)
            maxconvimgtmp_y=maxconvimgtmp_y-1;
            maxconvimgtmp_x=maxconvimgtmp_x-1;
            ximg1=ximg1-1;            yimg1=yimg1-1;
            C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
        end
        log_letter(ii)=1;
    end
%     dumy2=zeros(size(maxconvimg));
    dumy2=maxconvimg(1:end,1:end); %after letter detection

    log_zebra(ii)=0;
    if ~(log_hump(ii-1)==1 || log_hump(ii-2)==1)
        zebra_recognition;
        if log_zebra(ii)==1
            ximg1=ximg_zebra(1:4)+ImgSize2+30; yimg1=yimg_zebra(1:4)/2;
            min_x=max([ImgSize2+31, min(ximg1)]);   max_x=min([2*ImgSize2+30, max(ximg1)]);
            min_y=max([1, min(yimg1)]);             max_y=min([ImgSize1/2, max(yimg1)]);
            maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
            maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
            [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
            if ~isempty(maxconvimgtmp_x)
                maxconvimgtmp_y=maxconvimgtmp_y-1;
                maxconvimgtmp_x=maxconvimgtmp_x-1;
                ximg1=ximg1-1;            yimg1=yimg1-1;
                C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
            end
        end
    end
    
    log_hump(ii)=0;
    if ~(log_zebra(ii-1)==1 || log_zebra(ii)==1)
        hump_recognition;
        if log_hump(ii)==1
            ximg1=ximg_hump(1:4)+ImgSize2+30; yimg1=yimg_hump(1:4)/2;
            min_x=max([ImgSize2+31, min(ximg1)]);   max_x=min([2*ImgSize2+30, max(ximg1)]);
            min_y=max([1, min(yimg1)]);             max_y=min([ImgSize1/2, max(yimg1)]);
            maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
            maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
            [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
            if ~isempty(maxconvimgtmp_x)
                maxconvimgtmp_y=maxconvimgtmp_y-1;
                maxconvimgtmp_x=maxconvimgtmp_x-1;
                ximg1=ximg1-1;            yimg1=yimg1-1;
                C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
            end
            ximg1=ximg_hump(1:4); yimg1=yimg_hump(1:4)/2;
            min_x=max([1, min(ximg1)]);   max_x=min([ImgSize2, max(ximg1)]);
            min_y=max([1, min(yimg1)]);   max_y=min([ImgSize1/2, max(yimg1)]);
            maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
            maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
            [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
            if ~isempty(maxconvimgtmp_x)
                maxconvimgtmp_y=maxconvimgtmp_y-1;
                maxconvimgtmp_x=maxconvimgtmp_x-1;
                ximg1=ximg1-1;            yimg1=yimg1-1;
                C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
            end
        end
    end
   
    arrow_recognition;
    if ~isempty(rr_arrow)
        ximg1=ximg_arrow(1:4)+ImgSize2+30; yimg1=yimg_arrow(1:4)/2;
        min_x=max([ImgSize2+31, min(ximg1)]);   max_x=min([2*ImgSize2+30, max(ximg1)]);
        min_y=max([1, min(yimg1)]);             max_y=min([ImgSize1/2, max(yimg1)]);
        maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
        maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
        [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
        if ~isempty(maxconvimgtmp_x)
            maxconvimgtmp_y=maxconvimgtmp_y-1;
            maxconvimgtmp_x=maxconvimgtmp_x-1;
            ximg1=ximg1-1;            yimg1=yimg1-1;
            C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
        end
    elseif isempty(rr_arrow) && ~isempty(rr_tip)
        ximg1=ximg_arrow_tip(1:4)+ImgSize2+30; yimg1=yimg_arrow_tip(1:4)/2;
        min_x=max([ImgSize2+31, min(ximg1)]);   max_x=min([2*ImgSize2+30, max(ximg1)]);
        min_y=max([1, min(yimg1)]);             max_y=min([ImgSize1/2, max(yimg1)]);
        maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
        maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
        [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
        if ~isempty(maxconvimgtmp_x)
            maxconvimgtmp_y=maxconvimgtmp_y-1;
            maxconvimgtmp_x=maxconvimgtmp_x-1;
            ximg1=ximg1-1;            yimg1=yimg1-1;
            C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
        end
    elseif isempty(rr_arrow) && isempty(rr_tip) && (log_p_tip(ii-1)>0 || log_p_tip(ii-2)>0)
        ximg1=ximg_arrow_tip_est(1:4)+ImgSize2+30; yimg1=yimg_arrow_tip_est(1:4)/2;
        min_x=max([ImgSize2+31, min(ximg1)]);   max_x=min([2*ImgSize2+30, max(ximg1)]);
        min_y=max([1, min(yimg1)]);             max_y=min([ImgSize1/2, max(yimg1)]);
        maxconvimgtmp=zeros(ImgSize1/2,2*ImgSize2+30);
        maxconvimgtmp(min_y:max_y,min_x:max_x)=maxconvimg(min_y:max_y,min_x:max_x);
        [maxconvimgtmp_y, maxconvimgtmp_x]=find(maxconvimgtmp==1);
        if ~isempty(maxconvimgtmp_x)
            maxconvimgtmp_y=maxconvimgtmp_y-1;
            maxconvimgtmp_x=maxconvimgtmp_x-1;
            ximg1=ximg1-1;            yimg1=yimg1-1;
            C_in_poly_new(maxconvimg, maxconvimgtmp_x, maxconvimgtmp_y, ximg1, yimg1);
        end
    end
    dumy5=maxconvimg(1:end,1:end);
    
    dumy1=maxconvimg;
    
    num_ite=15000; %number of iterations for RANSAC
    if ~isempty(xtmpl) && ~isempty(xtmpr)
        xtmpl=[xtmpl ImgSize2*ones(1,ImgSize1/2+ytmpl(end))];
        xtmpr=[xtmpr ImgSize2*ones(1,ImgSize1/2+ytmpr(end))];
        maxconvimg=C_Search_region(maxconvimg,xtmpl,xtmpr+ImgSize2+30,-ytmpr(1),ImgSize1/2);
%         maxconvimg=C_Search_region(maxconvimg,xtmpl,xtmpr+ImgSize2+30,-ytmpr(1),-ytmpr(end));
%         maxconvimg(-ytmpr(end):end,:)=0;
        maxconvimg(1:-ytmpr(1),:)=0;
        maxconvimg(-ytmpr(end):ImgSize1/2,:)=0;
        num_ite=960;
    else
% % %         if leftrightlane==0
% % %             xtmpl_dumy=expos_box{1}; xtmpr_dumy=expos_box{3};
% % %             maxconvimg1=C_Search_region(maxconvimg1,xtmpl_dumy,xtmpr_dumy+ImgSize2+30,-expos_box{7}(1),ImgSize1/2);
% % %         else
% % %             xtmpl_dumy=expos_box{2}; xtmpr_dumy=expos_box{4};
% % %             maxconvimg1=C_Search_region(maxconvimg1,xtmpl_dumy,xtmpr_dumy+ImgSize2+30,-expos_box{8}(1),ImgSize1/2);
% % %         end
    end
    dumy4=maxconvimg; %after removing lane center pixels based on pre reseults, then combine with pre dumys

    dumy=[dumy1;dumy2];

   imwrite([dumy3;dumy2;dumy5;dumy1;dumy4],strcat(save_dir,'\oriRidge',int2str(ii),'.jpg'),'jpg');
     
    [sel_xtmpl,sel_ytmpl, xtmpl, ytmpl,sel_xtmpr,sel_ytmpr, xtmpr, ytmpr, num_in, para, inlier_xy_r, paraz,break_location, ~]= ...
        linefitting_simu2(maxconvimg(:,1:ImgSize2),maxconvimg(:,end-ImgSize2+1:end), D_pre, H, num_ite,pre_line_type,logC0(ii-1),log_zebra(ii));
%     lognum_in(ii)=num_in;
    [benchmark_xc(ii),benchmark_d_theta(ii)]=bench_mark_algo1(maxconvimg(:,end-ImgSize2+1:end),temp_p,temp_H,focal,temp_td,cc_x_right,cc_y);

    if num_in<60
        
        maxconvimg=dumy1;
        if ~isempty(xtmpl2) && ~isempty(xtmpr2)
            xtmpl2=[xtmpl2 ImgSize2*ones(1,ImgSize1/2+ytmpl2(end))];
            xtmpr2=[xtmpr2 ImgSize2*ones(1,ImgSize1/2+ytmpr2(end))];
            maxconvimg=C_Search_region(maxconvimg,xtmpl2,xtmpr2+ImgSize2+30,-ytmpr2(1),ImgSize1/2);
        else
            if leftrightlane==0
                xtmpl_dumy=expos_box{2}; xtmpr_dumy=expos_box{4};
                maxconvimg=C_Search_region(maxconvimg,xtmpl_dumy,xtmpr_dumy+ImgSize2+30,-expos_box{8}(1),ImgSize1/2);
            else
                xtmpl_dumy=expos_box{1}; xtmpr_dumy=expos_box{3};
                maxconvimg=C_Search_region(maxconvimg,xtmpl_dumy,xtmpr_dumy+ImgSize2+30,-expos_box{7}(1),ImgSize1/2);
            end
        end
        num_ite=1960;
        [sel_xtmpl,sel_ytmpl, xtmpl, ytmpl,sel_xtmpr,sel_ytmpr, xtmpr, ytmpr, num_in, para, inlier_xy_r, paraz,break_location,~]= ...
            linefitting_simu2(maxconvimg(:,1:ImgSize2),maxconvimg(:,end-ImgSize2+1:end), D_pre, H, num_ite,pre_line_type,logC0(ii-1),log_zebra(ii));
%         log_miss(ii)=1;
%         miss_infor_flag=1;
        if num_in<60
            SmoothAgain;
            if num_in<60
                update_w_missinfor;
                continue;
            end
        else
            if leftrightlane==0
                leftrightlane=1;
            else
                leftrightlane=0;
            end
        end
%         logC0(ii)=4*para(1,1)*cos(Phai)^3/H/focal;
    end
% % %     if sum(paraz(:))==0
% % %     logC0(ii)=4*para(1,1)*cos(Phai)^3/H/focal^2;
% % %     else logC0(ii)=0;
% % %     end
    sel_xtmpl_tmp=round(sel_xtmpl); sel_xtmpl_tmp(sel_xtmpl_tmp<1)=1; sel_xtmpl_tmp(sel_xtmpl_tmp>ImgSize2)=ImgSize2;
    sel_xtmpr_tmp=round(sel_xtmpr); sel_xtmpr_tmp(sel_xtmpr_tmp<1)=1; sel_xtmpr_tmp(sel_xtmpr_tmp>ImgSize2)=ImgSize2;
    indtmp_l=sub2ind(size(img),-sel_ytmpl,sel_xtmpl_tmp);
    intensity_l(ii,:)=[min(img(indtmp_l)) max(img(indtmp_l))];
    indtmp_r=sub2ind(size(img),-sel_ytmpr,sel_xtmpr_tmp+ImgSize2+30);
    intensity_r(ii,:)=[min(img(indtmp_r)) max(img(indtmp_r))];
    intesnity_td_min=min([min(img(indtmp_l)) min(img(indtmp_r))])-35;
    intesnity_td_max=max([max(img(indtmp_l)) max(img(indtmp_r))])+35;
    %convert back to original image coordinate 480x640
    % % [~,ir,il]=intersect(sel_ytmpr, ytmpl, 'stable');
%%
    if miss_infor_flag==1
        Detection_left_right_lane;
    end
    
    if leftrightlane==0 %left lane
        [~,il,ir]=intersect(ytmpl,sel_ytmpr,'stable');
        sel_ytmpr=sel_ytmpr(ir);
        sel_xtmpr=sel_xtmpr(ir);
        CorepxR=-(sel_xtmpr-cc_x_right);
        CorepxL=-(xtmpl(il)-cc_x_left);
        sel_ytmpr=2*sel_ytmpr-1; %convert back to -480x640 coordinate
    else
        [~,ir,il]=intersect(ytmpr,sel_ytmpl,'stable');
        sel_ytmpl=sel_ytmpl(il);
        sel_xtmpl=sel_xtmpl(il);
        CorepxL=-(sel_xtmpl-cc_x_left);
        CorepxR=-(xtmpr(ir)-cc_x_right);
        sel_ytmpl=2*sel_ytmpl-1; %convert back to -480x640 coordinate
    end
    disparity=CorepxR-CorepxL;
    indtmp=(disparity~=0);
    Zc=dist_left_right*focal./disparity;
    Xc=CorepxL.*Zc/focal+dist_left_right/2;
    % or Xc=CorepxR.*Zc/focal-dist_left_right/2;
    if leftrightlane==0
        Yc=(round(sel_ytmpr)+cc_y).*Zc/focal;
        ind_near=(sel_ytmpr<-192); %Use those pixels at 2/3bottom to calculate phai
    else
        Yc=(round(sel_ytmpl)+cc_y).*Zc/focal;
        ind_near=(sel_ytmpl<-192); %Use those pixels at 2/3bottom to calculate phai
    end
    ind_near=ind_near & indtmp;
    Xc1=Xc(1); Zc1=Zc(1); Yc1=Yc(1);
    marking_length(ii)=((Xc(1)-Xc(end))^2+(Zc(1)-Zc(end))^2)^0.5;
    if sum(ind_near)>=5
        Yc_near=Yc(ind_near); Zc_near=Zc(ind_near); Xc_near=Xc(ind_near);
    else
        Yc_near=Yc(indtmp(end-5:end)); Zc_near=Zc(indtmp(end-5:end)); 
        Xc_near=Xc(indtmp(end-5:end));
    end
    Atmp=[Zc_near' -ones(length(Zc_near),1)];
    Btmp=Yc_near'*cos(Theta)+Xc_near'*sin(Theta);
    tan_Phai_H=pinv(Atmp)*Btmp;
    tan_Phai=tan_Phai_H(1);
    Phai=atan(tan_Phai);
    logPhaiNaN(ii)=Phai;
    if isnan(Phai)
        Phai=atan(D_pre/focal);
    end
    logPhai(ii)=Phai;
    Phai=median(logPhai(max([ite_s, ii-10]):ii)); %median value of the previous 10 results.
    logPhai_f(ii)=Phai;
    D_pre=focal*tan(Phai);
    %     H=mean((Zc_near*tan(Phai)-Yc_near)*cos(Phai));
    H=tan_Phai_H(2)*cos(Phai);
    logHNaN(ii)=H;
    if H<1.4 || isnan(H) || H>1.8
        H=1.665;
    end
    logH(ii)=H;
    H=median(logH(max([ite_s, ii-10]):ii)); %median value of the previous 10 results.
    logH_f(ii)=H;
    if sum(paraz(:))==0
    logC0(ii)=4*para(1,1)*cos(Phai)^3/H/focal^2;
    else logC0(ii)=0;
    end
    refine_para=para;
    [~,il,ir]=intersect(ytmpl,ytmpr,'stable');
    if ~isempty(break_location)
        break_location=find(abs(ir-break_location)==min(abs(ir-break_location)),1);
        break_location=break_location(1);
    end
    CorL=-(xtmpl(il)-cc_x_left);
    CorR=-(xtmpr(ir)-cc_x_right);
    dis=CorR-CorL;
    indtmp=(dis>0); indtmp_dumy=indtmp;
    if sum(indtmp)<0.5*length(indtmp)
        update_w_missinfor;
        continue;
    end
    Zc=dist_left_right*focal./dis;
    Xc=CorL.*Zc/focal+dist_left_right/2;
    if leftrightlane==0
        Yc=(2*ytmpr(ir)-1+cc_y).*Zc/focal;
    else
        Yc=(2*ytmpl(il)-1+cc_y).*Zc/focal;
    end
    if ~isempty(break_location)
        dumZc=Zc(break_location);
    end
    Xc=Xc(indtmp); Yc=Yc(indtmp); Zc=Zc(indtmp);
    if ~isempty(break_location)
        break_location=find(abs(Zc-dumZc)==min(abs(Zc-dumZc)));
        break_location=break_location(1);
    end
    if sum(paraz(:)==0)
        [sel_xtmpl2,sel_ytmpl2,xtmpl2, ytmpl2, sel_xtmpr2,sel_ytmpr2,xtmpr2, ytmpr2, num_in2, para2, lwtmp, dumytmp, xtmpl_imagine, xtmpr_imagine, ytmp_imagine]= ...
            fit_other_lane(leftrightlane,dumy1,refine_para,-ytmpr(1),-ytmpr(end),H,Phai,D_pre, ximg, yimg);
        if isempty(xtmpl2)
            if leftrightlane==0
                expos_box={xtmpl, xtmpl_imagine, xtmpr, xtmpr_imagine, -ytmpr(1), 240, ytmpr, ytmp_imagine};
            else
                expos_box={xtmpl_imagine, xtmpl, xtmpr_imagine, xtmpr, -ytmpr(1), 240, ytmp_imagine, ytmpr};
            end
        else
            if leftrightlane==0
                expos_box={xtmpl, xtmpl2, xtmpr, xtmpr2, -ytmpr(1), 240, ytmpr, ytmpr2};
            else
                expos_box={xtmpl2, xtmpl, xtmpr2, xtmpr, -ytmpr(1), 240, ytmpr2, ytmpr};
            end
        end
    else
        xtmpl2=[];ytmpl2=[];xtmpr2=[];ytmpr2=[];
        sel_xtmpl2=[];sel_ytmpl2=[];sel_xtmpr2=[];sel_ytmpr2=[];
        num_in2=0; para2=[]; lwtmp=[]; dumytmp=dumy; 
        [xtmpl2,ytmpl2,xtmpr2,ytmpr2,num_in2,dumytmp]=fit_other_lane_zebra(leftrightlane,dumy1,xtmpl,ytmpl,xtmpr,ytmpr,D_pre,H, ximg,yimg);
        if isempty(xtmpl2)
            if leftrightlane==0
                expos_box={xtmpl, xtmpl+round(46.8-2.26*ytmpl), xtmpr, xtmpr+round(46.8-2.26*ytmpr), -ytmpr(1), 240, ytmpr, ytmpr};
            else
                expos_box={xtmpl-round(46.8-2.26*ytmpl), xtmpl, xtmpr-round(46.8-2.26*ytmpr), xtmpr, -ytmpr(1), 240, ytmpr, ytmpr};
            end
        else
            if leftrightlane==0
                expos_box={xtmpl, xtmpl2, xtmpr, xtmpr2, -ytmpr(1), 240, ytmpr, ytmpr2};
            else
                expos_box={xtmpl2, xtmpl, xtmpr2, xtmpr, -ytmpr(1), 240, ytmpr2, ytmpr};
            end
        end
    end
% %     log_expos_box{ii}=expos_box;
    lognum_in2(ii)=num_in2;
    dumy=[dumy; dumytmp];
% %     imwrite(dumy,strcat(save_dir,'\Ridge',int2str(ii),'.jpg'),'jpg');
    if isempty(lwtmp)
        log_lw(ii,1)=0;
    else
        log_lw(ii,1)=lwtmp;
    end
    log_non_0_lw=log_lw(log_lw~=0);
    log_non_0_num_in2=lognum_in2(log_lw~=0);
    if isempty(log_non_0_num_in2) || isempty(log_non_0_lw)
        lane_width=log_lane_width_f(ii-1);
    else
        m=-min([10, length(log_non_0_lw)]):-1;
        coe_fil=cos(m*pi/2/max(-m));
        coe_fil=log_non_0_num_in2((end-max(-m)+1):end).*coe_fil;
        coe_fil=coe_fil'/sum(coe_fil);
        lane_width=sum(coe_fil.*log_non_0_lw((end-max(-m)+1):end));
%         log_lane_width_cal(ii)=lane_width;
        if lane_width==0
            lane_width=log_lane_width_f(ii-1);
        elseif ((lane_width-log_lane_width_f(ii-1))>0.3)
            lane_width=log_lane_width_f(ii-1)+0.3;
        elseif ((lane_width-log_lane_width_f(ii-1))<-0.3)
            lane_width=log_lane_width_f(ii-1)-0.3;
        end
    end
    log_lane_width_f(ii)=lane_width;
    
    R=[cos(Theta) -sin(Theta) 0; ...
        cos(Phai)*sin(Theta) cos(Phai)*cos(Theta) -sin(Phai); ...
        sin(Phai)*sin(Theta) sin(Phai)*cos(Theta) cos(Phai);];
    T=[0;H;L_wheel_cam];
    World=[R T+offset_vector;0 0 0 1]*[Xc; Yc; Zc; ones(1,length(Zc))];
    % logXw=World(1); logYw=World(2); logZw=World(3);
    % toc
    Xw=World(1,:); Yw=World(2,:); Zw=World(3,:);
    inf_ind=(isinf(Xw) | isinf(Yw) | isinf(Zw)) | (isnan(Xw) | isnan(Yw) | isnan(Zw)) | (Zw>10);
    if ~isempty(break_location)
       dumZw=Zw(break_location);
    end
    Xw(inf_ind)=[];Yw(inf_ind)=[];Zw(inf_ind)=[];
    if isempty(Zw)
        update_w_missinfor;
        xtmpl=[]; xtmpr=[];
        continue;
    end
    World(:,inf_ind)=[];
    if ~isempty(break_location)
        break_location=find(abs(Zw-dumZw)==min(abs(Zw-dumZw)));
        break_location=break_location(1);
    end
    
    pre_Xw=rot_World(1,:); pre_Zw=rot_World(2,:);
%     log_rot_World{ii}=rot_World;
%     log_World{ii}=World;
    [pre_Xw, pre_Zw]=conjugate_points(pre_Xw, pre_Zw, lane_width, leftrightlane, pre_leftrightlane);
    pre_Xw(pre_Zw>Zw(end))=[];
    pre_Zw(pre_Zw>Zw(end))=[];
    if sum(paraz(:)==0)
        if sum(abs(para(:,2)))==0 %model is hypobola
            del_Xw=pre_Xw(end)-Xw(end);
            pre_Xw=pre_Xw-2/3*del_Xw;
            Xw=Xw+1/3*del_Xw;
            World(1,:)=World(1,:)+1/3*del_Xw;
            Atmp=[[Zw pre_Zw].^2; [Zw pre_Zw]; ones(1,length([Zw pre_Zw]))]';
            Btmp=[Xw pre_Xw]';
            Wtmp=diag([ones(length(Zw),1); ones(length(pre_Zw),1)*1.0]);
            Atmp=(sqrt(Wtmp))'*Atmp; Btmp=sqrt(Wtmp)*Btmp;
            abc=pinv(Atmp)*Btmp;
%             log_line_para(ii)=2;
            pre_line_type=2;
        else %model is line
            if marking_length(ii)<4.1
                World1=[R T+offset_vector;0 0 0 1]*[Xc1; Yc1; Zc1; 1];
                Xw1=World1(1); Zw1=World1(3);
                [Xw, Zw]=best_line(Xw,Zw,mean(Predict_Xc(1:50)),mean(Predict_d_theta(1:50)), ...
                    leftrightlane,pre_leftrightlane,lane_width, num_in, Xw1, Zw1);
            end
            del_Xw=pre_Xw(end)-Xw(end);
            pre_Xw=pre_Xw-2/3*del_Xw;
            Xw=Xw+1/3*del_Xw;
%             World(1,:)=World(1,:)+1/3*del_Xw;
            World(1,:)=Xw; World(3,:)=Zw;
            Atmp=[[Zw pre_Zw]; ones(1,length([Zw pre_Zw]))]';
            Btmp=[Xw pre_Xw]';
            Wtmp=diag([ones(length(Zw),1); ones(length(pre_Zw),1)*1.0]);
            Atmp=(sqrt(Wtmp))'*Atmp; Btmp=sqrt(Wtmp)*Btmp;
            bc=pinv(Atmp)*Btmp;
            abc=[0; bc];
%             log_line_para(ii)=1;
            pre_line_type=1;
        end
    else %model is zeg zag line
        [Xw, Yw, Zw, ~]=equavalent_line(break_location, Xw, Zw);
        World=[Xw;Yw;Zw; ones(1,length(Xw))];
        del_Xw=pre_Xw(end)-Xw(end);
        pre_Xw=pre_Xw-2/3*del_Xw;
        Xw=Xw+1/3*del_Xw;
        World(1,:)=World(1,:)+1/3*del_Xw;
        Atmp=[[Zw pre_Zw]; ones(1,length([Zw pre_Zw]))]';
        Btmp=[Xw pre_Xw]';
        Wtmp=diag([ones(length(Zw),1); ones(length(pre_Zw),1)*1.0]);
        Atmp=(sqrt(Wtmp))'*Atmp; Btmp=sqrt(Wtmp)*Btmp;
        bc=pinv(Atmp)*Btmp;
        abc=[0; bc];
%         log_line_para(ii)=3;
        pre_line_type=3;
    end
% end
%     log_line_type(ii)=pre_line_type;
    [xc_m, d_theta_m, ~]=solve_xc_d_theta(abc,0,0,pi/2);   
    log_xc_m(ii)=xc_m;
    log_d_theta_m(ii)=d_theta_m;
% %     xc_m=median(log_xc_m(max([ite_s, ii-2]):ii));
% %     d_theta_m=median(log_d_theta_m(max([ite_s, ii-2]):ii));
% %     log_xc_m_f(ii)=xc_m;
% %     log_d_theta_m(ii)=d_theta_m;
    if num_in2>1.0*num_in
        lanelinechange=1;
    else lanelinechange=0;
    end
%%
    %     logWidth(ii)=f_width;
    if sum(ind_near)>6
        ind_near(1:(end-7))=0;
    end
    if mod(sum(ind_near),2)==0
        indtmp=find(ind_near==1,1);
        ind_near(indtmp)=0;
    end
    if sum(ind_near)>=5
        if leftrightlane==0
            y_for_tdx=sel_ytmpr(ind_near)';
            x_for_tdx=round(sel_xtmpr(ind_near)');
            Intensity=rightimg(-y_for_tdx,:);
        else
            y_for_tdx=sel_ytmpl(ind_near)';
            x_for_tdx=round(sel_xtmpl(ind_near)');
            Intensity=leftimg(-y_for_tdx,:);
        end
        y_for_tdx=y_for_tdx+cc_y; %convert to camera coordinate
        tdxtmp1=round((cos(Phai)/H*(D_pre-y_for_tdx)*0.10)/2);
        tdxtmp2=round((cos(Phai)/H*(D_pre-y_for_tdx)*0.15)/2);
        tdxtmp3=round((cos(Phai)/H*(D_pre-y_for_tdx)*0.20)/2);
        quater_tdxtmp3=round(1/4*tdxtmp3);
        x_for_tdx_lb=x_for_tdx-tdxtmp3-quater_tdxtmp3;
        x_for_tdx_rb=x_for_tdx+tdxtmp3+quater_tdxtmp3;
        x_for_tdx_lb(x_for_tdx_lb<1)=1;
        x_for_tdx_lb(x_for_tdx_lb>ImgSize2)=ImgSize2;
        x_for_tdx_rb(x_for_tdx_rb<1)=1;
        x_for_tdx_rb(x_for_tdx_rb>ImgSize2)=ImgSize2;
        marking_width_all=C_find_lane_marking_width(Intensity,x_for_tdx_lb,x_for_tdx_rb,tdxtmp1,tdxtmp2,tdxtmp3,x_for_tdx);
        marking_width=median(marking_width_all);
        if marking_width>0.15
            marking_width=0.15;
        end
        if leftrightlane==0
            log_marking_width_left(ii)=marking_width;
            marking_width=median(log_marking_width_left(max([ite_s, ii-2]):ii));
            log_marking_width_f_left(ii)=marking_width;
            log_marking_width_right(ii)=log_marking_width_right(ii-1);
            log_marking_width_f_right(ii)=log_marking_width_f_right(ii-1);
        else
            log_marking_width_right(ii)=marking_width;
            marking_width=median(log_marking_width_right(max([ite_s, ii-2]):ii));
            log_marking_width_f_right(ii)=marking_width;
            log_marking_width_left(ii)=log_marking_width_left(ii-1);
            log_marking_width_f_left(ii)=log_marking_width_f_left(ii-1);
        end
%         if marking_width~=marking_width_pre
            marking_width_pre=marking_width;
            if mod(floor(D_pre),2)==0
                D_pre1=floor(D_pre)-1;
            else D_pre1=floor(D_pre);
            end
            yy=min(floor(D_pre1),top_row):-1:btm_row;
            tdxtmp=(cos(Phai)/H*(D_pre-yy)*marking_width)/2; %0.10m is the lane marking width
            if length(tdxtmp)>=length(tdx)
                tdx=round(tdxtmp((end-length(tdx)+1):end));
            else
                tdx=round([0.5*ones(1,(length(tdx)-length(tdxtmp))) tdxtmp]);
            end
            tdx(tdx==0)=1;
            [~,ix,~]=unique(tdx,'stable');ix=ix';
            j=1;
            for i=ix
                weight3=exp((-0.5*(-tdx(i):tdx(i)).^2/(tdx(i))^2));
                weight3=weight3/sum(weight3);
                xfil2{j}=weight3;
                j=j+1;
            end
            ix(length(ix)+1)=ImgSize1-Offset+1;
            ix=round(ix/2)+Offset/2;
            
% % % % %                 if marking_width==0.1
% % % % %                     marking_width1=0.15;
% % % % %                 else marking_width1=0.1;
% % % % %                 end
% % % % %                 tdxtmp1=(cos(Phai)/H*(D_pre-yy)*marking_width1)/2; %0.10m is the lane marking width
% % % % %                 if length(tdxtmp1)>=length(tdx1)
% % % % %                     tdx1=round(tdxtmp1((end-length(tdx1)+1):end));
% % % % %                 else
% % % % %                     tdx1=round([0.5*ones(1,(length(tdx1)-length(tdxtmp1))) tdxtmp1]);
% % % % %                 end
% % % % %                 tdx1(tdx1==0)=1;
% % % % %                 [~,ix1,~]=unique(tdx1,'stable');ix1=ix1';
% % % % %                 j=1;
% % % % %                 for i=ix1
% % % % %                     weight3=exp((-0.5*(-tdx1(i):tdx1(i)).^2/(tdx1(i))^2));
% % % % %                     weight3=weight3/sum(weight3);
% % % % %                     xfil3{j}=weight3;
% % % % %                     j=j+1;
% % % % %                 end
% % % % %                 ix1(length(ix1)+1)=ImgSize1-Offset+1;
% % % % %                 ix1=round(ix1/2)+Offset/2;

            
%         end
    else
        log_marking_width_left(ii)=log_marking_width_left(ii-1);
        log_marking_width_f_left(ii)=log_marking_width_f_left(ii-1);
        log_marking_width_right(ii)=log_marking_width_right(ii-1);
        log_marking_width_f_right(ii)=log_marking_width_f_right(ii-1);
    end
%     log_tdx{ii}=tdx;
%%
    %generate weights based on measurement and prediction. then resample
    %particles, estimate location, transform other particles based on the
    %estimated location
%     var_w_xc=(2.5071*10^(-7)*num_in*num_in-0.00051078*num_in+0.26296)^2;
%     var_w_d_theta=(-3.4*10^(-5)*num_in+0.033).^2;
    var_w_xc=(450/min([num_in,450])*0.0914)^2; 
    %std 0.07m is based on comparsion between measurements and ground truth. 
    %450 corresponding to average inliers for the corresponding ground truth images
    %xc measurement error (m-gt) follows closely as a normal distribution (0,0.0914)
    var_w_d_theta=(450/min([450,450])*0.0334*2).^2; log_var(ii)=var_w_d_theta;
% %     var_w_d_theta=(5*156/329*abs(logC0(ii))+.0087*5).^2;
% %     var_w_d_theta=min([var_w_d_theta 0.035]);
% %     log_var(ii)=var_w_d_theta;
    %std 0.0261rad is based on comparison between measurements and ground
    %truth. 450 corresponding to average inliers for the corresponding
    %ground truth images. 
    %d_theta measurment error (m-gt) follws an offset normal distribution
    %(-0.0133, 0.0334)
%     PF_wt=exp(-0.5*((Predict_P(7,:)-v_m).^2/var_w_v+(Predict_P(8,:)-phai_m).^2/var_w_phai+ ...
%                 (Predict_Xc-xc_m).^2/var_w_xc+(Predict_d_theta-d_theta_m).^2/var_w_d_theta));
    if pre_leftrightlane~=leftrightlane
        if pre_leftrightlane==0
            if leftrightlane==1
                Predict_Xc=Predict_Xc-lane_width;
            else Predict_Xc=Predict_Xc-2*lane_width;
            end
        elseif pre_leftrightlane==1
            if leftrightlane==0
                Predict_Xc=Predict_Xc+lane_width;
            else Predict_Xc=Predict_Xc-lane_width;
            end
        else
            if leftrightlane==0
                Predict_Xc=Predict_Xc+lane_width*2;
            else Predict_Xc=Predict_Xc+lane_width;
            end
        end
    end
    PF_wt=exp(-0.5*(1.0*(xc_m-Predict_Xc).^2/var_w_xc+1.0*(d_theta_m-(-0.0045)-Predict_d_theta).^2/var_w_d_theta));
    if sum(PF_wt)==0 %meaning the measurement is far way off from the prediction, indicating wrong fitting for this cycle.
        update_w_missinfor;
        xtmpl=[]; xtmpr=[];
        continue;
    end
    PF_wt(1:50)=max(PF_wt)/max(PF_wt(1:50))*PF_wt(1:50);
    PF_wt=PF_wt./sum(PF_wt);
    cumsum_PF_wt=cumsum(PF_wt);
    particle_index=C_resample_PF(cumsum_PF_wt);
    particle_index(particle_index>P_No)=P_No; 
    Particle=Predict_P(:,particle_index);
    Estimate_x_mean=mean(Particle(1,:));
    Estimate_z_mean=mean(Particle(2,:));
    Estimate_theta_mean=mean(Particle(3,:));
    [Estimate_xc, Estimate_d_theta, phi_d]=solve_xc_d_theta(pre_abc1,Estimate_x_mean,Estimate_z_mean,Estimate_theta_mean);
    
    if pre_leftrightlane~=leftrightlane
        if pre_leftrightlane==0
            if leftrightlane==1
                Estimate_xc=Estimate_xc-lane_width;
%                 predi_xc=predi_xc-lane_width;
            else
                Estimate_xc=Estimate_xc-lane_width*2;
%                 predi_xc=predi_xc-lane_width*2;
            end
        elseif pre_leftrightlane==1
            if leftrightlane==0
                Estimate_xc=Estimate_xc+lane_width;
%                 predi_xc=predi_xc+lane_width;
            else
                Estimate_xc=Estimate_xc-lane_width;
%                 predi_xc=predi_xc-lane_width;
            end
        else
            if leftrightlane==0
                Estimate_xc=Estimate_xc+lane_width*2;
%                 predi_xc=predi_xc+lane_width*2;
            else
                Estimate_xc=Estimate_xc+lane_width;
%                 predi_xc=predi_xc+lane_width;
            end
        end
    end
    
    
    Rtmp=[cos(Estimate_theta_mean-0.5*pi) sin(Estimate_theta_mean-0.5*pi); ...
        -sin(Estimate_theta_mean-0.5*pi) cos(Estimate_theta_mean-0.5*pi)];
%     Particle(1:2,:)=[cos(Estimate_theta_mean-0.5*pi) sin(Estimate_theta_mean-0.5*pi) -Estimate_x_mean; ...
%         -sin(Estimate_theta_mean-0.5*pi) cos(Estimate_theta_mean-0.5*pi) -Estimate_z_mean;]*[Particle(1:2,:); ones(1,P_No)];
    Particle(1:2,:)=[Rtmp -Rtmp*[Estimate_x_mean;Estimate_z_mean]]*[Particle(1:2,:); ones(1,P_No)];
    Particle(3,:)=Particle(3,:)-(Estimate_theta_mean-0.5*pi);
    Particle(4:5,:)=Rtmp*Particle(4:5,:);
    log_Estimate_xc(ii)=Estimate_xc;
%     log_Estimate_d_theta(ii)=0.5*(Estimate_d_theta+log_Estimate_d_theta(ii-1));
    log_Estimate_d_theta(ii)=Estimate_d_theta;
    %Transform the previous abc and the current abc based on the newly
    %estimated locations. The one with more num_in should be used.
% % %     if num_in<0.5*lognum_in(ii-1) && (pre_leftrightlane==leftrightlane) && (continue_frame<5)
% % %         new_pre_World=[Rtmp -Rtmp*[Estimate_x_mean;Estimate_z_mean]]*pre_World([1,3,4],:);
% % %         new_pre_World=[new_pre_World(1,:); pre_World(2,:); new_pre_World(2,:); pre_World(4,:)];
% % %         new_pre_Xw=new_pre_World(1,:); new_pre_Yw=new_pre_World(2,:); new_pre_Zw=new_pre_World(3,:);
% % %         if sum(abs(pre_para(:,2)))==0 %model is hypobola
% % %             Atmp=[new_pre_Zw.^2; new_pre_Zw; ones(1,length(new_pre_Zw))]'; Btmp=new_pre_Xw';
% % %             pre_abc1=pinv(Atmp)*Btmp;
% % %         else %model is line
% % %             Atmp=[new_pre_Zw; ones(1,length(new_pre_Zw))]'; Btmp=new_pre_Xw';
% % %             pre_bc=pinv(Atmp)*Btmp;
% % %             pre_abc1=[0; pre_bc];
% % %         end
% % %         World=new_pre_World;
% % %         pre_World=World;
% % %         continue_frame=continue_frame+1;
% % %     else
        tan_x=Estimate_xc*cos(-Estimate_d_theta);
        tan_z=Estimate_xc*sin(-Estimate_d_theta);
%         Atmp=((Zw(round(length(Zw)/2))-tan_z).^2)';
%         Btmp=(Xw(round(length(Zw)/2))-tan_x-tan(Estimate_d_theta)*(Zw(round(length(Zw)/2))-tan_z))';
        Atmp=((Zw(1)-tan_z).^2)';
        Btmp=(Xw(1)-tan_x-tan(Estimate_d_theta)*(Zw(1)-tan_z))';
        pre_abc1=pinv(Atmp)*Btmp;
        pre_abc1=[pre_abc1;tan(Estimate_d_theta)-2*pre_abc1*tan_z; ...
            tan_x-pre_abc1*tan_z^2-(tan(Estimate_d_theta)-2*pre_abc1*tan_z)*tan_z];
        pre_World=World;
        pre_para=para;
        continue_frame=0;
% % %     end
    
    if leftrightlane==0
        log_xc_m(ii)=log_xc_m(ii)-lane_width;
        log_Estimate_xc(ii)=log_Estimate_xc(ii)-lane_width;
%         log_predi_xc(ii)=log_predi_xc(ii)-lane_width;
    elseif leftrightlane==2
        log_xc_m(ii)=log_xc_m(ii)+lane_width;
        log_Estimate_xc(ii)=log_Estimate_xc(ii)+lane_width;
%         log_predi_xc(ii)=log_predi_xc(ii)+lane_width;
    end

% %     if abs(log_Estimate_d_theta(ii)-log_Estimate_d_theta(ii-1))>0.07
% %     log_Estimate_d_theta_f(ii)=median(log_Estimate_d_theta(max([(ii-5) ite_s]):ii));
% %     else log_Estimate_d_theta_f(ii)=log_Estimate_d_theta(ii);
% %     end
    
    Particle(1,1:50)=0;
    Particle(2,1:50)=0;
    Particle(3,1:50)=pi/2;
if ~isempty(logloop_data{ii})
    loop_t=logloop_data{ii}{1};
    loop_phi=logloop_data{ii}{2};
    loop_v=logloop_data{ii}{3};
    dt=act_t(ii+1);
    Predict_P=C_Predict_P(Particle,loop_t,loop_phi,loop_v);
    Predict_P(1,:)=Predict_P(1,:)+0.25*dt/0.2*marking_width*randn(1,P_No);
    Predict_P(2,:)=Predict_P(2,:)+0.25*dt/0.2*marking_width*randn(1,P_No);
    Predict_P(3,:)=Predict_P(3,:)+0.01*dt/0.2*randn(1,P_No);
else
    dt=act_t(ii+1);
    if v_m~=0
        v0=v_m+sqrt(var_v).*randn(1,P_No);
    else
        v0=zeros(1,P_No);
    end
    phai0=phai_m+sqrt(var_phai).*randn(1,P_No);
    Particle(7,:)=v0;
    Particle(8,:)=phai0;
    Predict_P(8,:)=Particle(8,:);
    Predict_P(7,:)=Particle(7,:);
    Predict_P(4,:)=cos(Particle(3,:)).*Particle(7,:);
    Predict_P(5,:)=sin(Particle(3,:)).*Particle(7,:);
    Predict_P(6,:)=-tan(Particle(8,:)).*Particle(7,:)/L_wheels;
    Predict_P(1,:)=Particle(1,:)+Particle(4,:)*dt+0.25*dt/0.2*marking_width*randn(1,P_No);
    Predict_P(2,:)=Particle(2,:)+Particle(5,:)*dt+0.25*dt/0.2*marking_width*randn(1,P_No);
    Predict_P(3,:)=Particle(3,:)+Particle(6,:)*dt+0.01*dt/0.2*randn(1,P_No);
end
    [Predict_Xc, Predict_d_theta]=C_solve_xc_d_theta(pre_abc1, Predict_P(1:3,:));
    
    RT_abc=GetRotMat([0;0;pi/2], loop_t, loop_phi, loop_v);
    ZZ=0:0.5:7; XX=pre_abc1(1)*ZZ.^2+pre_abc1(2)*ZZ+pre_abc1(3);
    rot_World=RT_abc*[XX;ZZ;ones(1,length(ZZ))];
    
    pre_abc2=abc;
     pre_abc_right_lane1=conjugate_lane(pre_abc1,[0, max(pre_World(3,:))],leftrightlane,lane_width);
    pre_abc_right_lane2=conjugate_lane(pre_abc2,[max(pre_World(3,:)) 20],leftrightlane,lane_width);

    pre_leftrightlane=leftrightlane;
    logleftrightlane(ii)=leftrightlane;
% %     logxytmp{ii}={xtmpl, ytmpl, xtmpr, ytmpr};
    miss_infor_flag=0;
        endt(ii)=toc(start);
    endf(ii)=toc(in_start);
    plotimg;
    if lanelinechange==1
        if leftrightlane==0
            leftrightlane=1;
        elseif leftrightlane==1
%             if mean(xtmpl)>mean(xtmpl2)
                leftrightlane=0;
%             else leftrightlane=2;
%             end
        else leftrightlane=1;
        end
        xtmpl_dumy=xtmpl2; ytmpl_dumy=ytmpl2; xtmpr_dumy=xtmpr2; ytmpr_dumy=ytmpr2;
        xtmpl2=xtmpl; ytmpl2=ytmpl; xtmpr2=xtmpr; ytmpr2=ytmpr;
        xtmpl=xtmpl_dumy; ytmpl=ytmpl_dumy; xtmpr=xtmpr_dumy; ytmpr=ytmpr_dumy;
    end 
  

   
    
% %     logpre_abc{ii}={pre_abc_right_lane1,pre_abc_right_lane2,min(pre_World(3,:))};
    
end
catch err
    disp 'sth wrong'
    rethrow(err);
end
end
