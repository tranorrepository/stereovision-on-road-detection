clear all;pause(0.01);
warning off;
f='D:\StereoLaptop_new\Image Collection(new Cam)8';
save_dir=f;
% f='D:\StereoLaptop_new\RealRun_Laptop_new_Cam\RealRunImg\test166';
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
%for Image Collection(new Cam)1
log_ite_s=[2 206 461 1490];
log_ite_e=[378 207 857 1540];

%for Image Collection(new Cam)2,3,4
% log_ite_s=[1    170 318 459 622 770]; 
% log_ite_e=[113  250 381 541 710 860];

for outloop=1:1
ite_s=log_ite_s(outloop);
ite_e=log_ite_e(outloop);
global_varibles;
InitializationGlobalVariable;
load 'cali3.mat'; %'cali3_old2.mat' is for img collection 6. The original webcam calibration results
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
load 'pca_temp3_arrow_tip.mat';
win_r=16; win_c=30;
conv_win=ones(win_r,win_c);
ratio=(((1:(win_r/2))+win_r/2)/win_r)';
ratio_top=repmat(ratio,1,150/2);
ratio=((((win_r/2):-1:1)+win_r/2)/win_r)';
ratio_btm=repmat(ratio,1,150/2);


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
try
KickOff_PF2;
log_p_tip(ii)=0;
% intesnity_td_min=230;
% intesnity_td_max=255;
for ii=(ite_s+1):ite_e
% for ii=(93):ite_e
    if ii==264
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
    template_matching;
    
    ImgSmooth=zeros(size(img));
    for i=1:(length(ix)-1)
        ImgSmooth(ix(i):(ix(i+1)-1),:)=conv2(img(ix(i):(ix(i+1)-1),:),xfil2{i},'same');
    end
    
    maxconvimg=C_new_Ridge(ImgSmooth,tdx,Offset);
    maxconvimg=maxconvimg.*mask;
    log_total_num(ii)=sum(maxconvimg(:));
%     ImgSmooth=conv2(ImgSmooth,yfil2,'same');
%     [kcsditmp,th]=C_Ridge(ImgSmooth,306400);
%     for i=1:8
%         convimg(:,:,i)=conv2(kcsditmp,wd(:,:,i),'same');
%     end
%     maxconvimg=max(convimg,[],3);
%     maxconvimg=maxconvimg.*mask;
    C_refine_Ridge(maxconvimg,Offset);
    dumy3=maxconvimg(1:end,1:end); %after ridge detection
    
    if (isempty(ximg) && ~isempty(log_xyimg{ii-1}))
        if max(log_xyimg{ii-1}(2,:))>300
            letter_y_down_l=(log_xyimg{ii-1}(2,1)+log_xyimg{ii-1}(2,4))*0.5;
            letter_y_down_r=(log_xyimg{ii-1}(2,2)+log_xyimg{ii-1}(2,3))*0.5;
            letter_x_l=(log_xyimg{ii-1}(1,1)+log_xyimg{ii-1}(1,4))*0.5;
            letter_x_r=(log_xyimg{ii-1}(1,2)+log_xyimg{ii-1}(1,3))*0.5;
            esti_ximg(1)=letter_x_l;
            esti_ximg(2)=letter_x_r;
            esti_yimg(1)=letter_y_down_l;
            esti_yimg(2)=letter_y_down_r;
            esti_yimg(3)=max([log_xyimg{ii-1}(2,3)+letter_y_down_l-log_xyimg{ii-1}(2,1) 480]);
            esti_yimg(4)=max([log_xyimg{ii-1}(2,4)+letter_y_down_r-log_xyimg{ii-1}(2,2) 480]);
            esti_yimg(5)=esti_yimg(1);
            esti_ximg(3)=(esti_yimg(3)-log_xyimg{ii-1}(2,3))/(log_xyimg{ii-1}(2,3)-log_xyimg{ii-1}(2,2)) ...
                *(log_xyimg{ii-1}(1,3)-log_xyimg{ii-1}(1,2))+log_xyimg{ii-1}(1,3);
            esti_ximg(4)=(esti_yimg(4)-log_xyimg{ii-1}(2,4))/(log_xyimg{ii-1}(2,4)-log_xyimg{ii-1}(2,1)) ...
                *(log_xyimg{ii-1}(1,4)-log_xyimg{ii-1}(1,1))+log_xyimg{ii-1}(1,4);
            esti_ximg(5)=esti_ximg(1);
            ximg=esti_ximg; yimg=esti_yimg;
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
    end
%     dumy2=zeros(size(maxconvimg));
    dumy2=maxconvimg(1:end,1:end); %after letter detection
%     dumy1(dumy1<connected_pixel*th)=0; dumy1(dumy1>=connected_pixel*th)=1;
    arrow_recognition;
    if ~isempty(rr)
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
    elseif isempty(rr) && ~isempty(rr_tip)
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
    end
    dumy5=maxconvimg(1:end,1:end);

    % tic;
    hump_row=[]; hump_counter=0;
    if isempty(ximg)
    fft_t=tic;
    ub=640*H*cos(Estimate_d_theta-1*pi/8)/0.35./(sin(Phai)*focal-cos(Phai)*(-(2*(41:3:237)-1)+cc_y));
    lb=640*H*cos(Estimate_d_theta-3*pi/8)/0.35./(sin(Phai)*focal-cos(Phai)*(-(2*(41:3:237)-1)+cc_y));
    row_counter=1; 
    leftimgtmp=leftimg(1:2:ImgSize1,:);
    for row=41:3:237
        a=leftimgtmp(row,:);
        a=fft(a,NFFT)/ImgSize2;
        a=a(1:(NFFT/2+1));
        ma=abs(a);
        del=ma(2:end)-ma(1:(end-1));
        del_ind=find(del>0,1);
        ma(1:del_ind)=0;
%         [~,ma_ind_tmp]=sort(ma);
        [ma_max,ma_ind]=max(ma);
        if (fre_seq(ma_ind)>=lb(row_counter) && fre_seq(ma_ind)<=ub(row_counter)) && (ma_max>=18.75)
            maxconvimg(row:(row+3),1:ImgSize2)=0;
            hump_counter=hump_counter+1;
%             imwrite([dumy1(:,1:ImgSize2);dumy3],strcat(save_dir,'\humpRidge',int2str(ii),'.jpg'),'jpg');
        end
        row_counter=row_counter+1;
    end
    row_counter=1;
    rightimgtmp=rightimg(1:2:ImgSize1,:);
    hump_counter=0;
    for row=41:3:237
        a=rightimgtmp(row,:);
        a=fft(a,NFFT)/ImgSize2;
        a=a(1:(NFFT/2+1));
        ma=abs(a);
        del=ma(2:end)-ma(1:(end-1));
        del_ind=find(del>0,1);
        ma(1:del_ind)=0;
%         [~,ma_ind_tmp]=sort(ma);
%         ma_ind=ma_ind_tmp(ImgSize2/2-1);
        [ma_max,ma_ind]=max(ma);
        if (fre_seq(ma_ind)>=lb(row_counter) && fre_seq(ma_ind)<=ub(row_counter)) && (ma_max>=18.75)
            maxconvimg(row:(row+3),(ImgSize2+30):end)=0;
            hump_counter=hump_counter+1;
            hump_row=[hump_row row:(row+3)];
%             imwrite([dumy1(:,1:ImgSize2);dumy3],strcat(save_dir,'\humpRidge',int2str(ii),'.jpg'),'jpg');
        end
        row_counter=row_counter+1;
    end
    log_fft_t(ii)=toc(fft_t);
    log_hump_counter(ii)=hump_counter;
    end
    
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
    end
    dumy4=maxconvimg; %after removing lane center pixels based on pre reseults, then combine with pre dumys
    
    
    
    % toc
%     dumy2(dumy2<connected_pixel*th)=0;dumy2(dumy2>=connected_pixel*th)=1;
    dumy=[dumy1;dumy2];
    % dumy(:,ImgSize2/2:ImgSize2)=0;
    % dumy(:,end-320:end)=0;
    imwrite([dumy3;dumy2;dumy5;dumy1;dumy4],strcat(save_dir,'\oriRidge',int2str(ii),'.jpg'),'jpg');
% % % %     dumy3=dumy1(:,1:ImgSize2); 
% % % %     dumy3(1:65,:)=0;
% % % %     log_inliner_index{ii}=Hump_Detection(dumy3,Phai,H,num_ite,focal,Estimate_d_theta,cc_y,cc_x_left);
% % % %     if (sum(log_inliner_index{ii}~=14)>200)
% % % %         indtmp3=find(log_inliner_index{ii}~=14);
% % % % %         dumy3=dumy1(:,1:ImgSize2);
% % % %         indtmp4=find(dumy3==1);
% % % %         dumy3(indtmp4(indtmp3))=0;
% % % %         imwrite([dumy1(:,1:ImgSize2);dumy3],strcat(save_dir,'\humpRidge',int2str(ii),'.jpg'),'jpg');
% % % %     end
    
        
        
    [sel_xtmpl,sel_ytmpl, xtmpl, ytmpl,sel_xtmpr,sel_ytmpr, xtmpr, ytmpr, num_in, para, inlier_xy_r, paraz,break_location, log_dumy(ii,:)]= ...
        linefitting_simu2(maxconvimg(:,1:ImgSize2),maxconvimg(:,end-ImgSize2+1:end), D_pre, H, num_ite,pre_line_type);
    lognum_in(ii)=num_in;
    
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
        num_ite=960;
        [sel_xtmpl,sel_ytmpl, xtmpl, ytmpl,sel_xtmpr,sel_ytmpr, xtmpr, ytmpr, num_in, para, inlier_xy_r, paraz,break_location,log_dumy(ii,:)]= ...
            linefitting_simu2(maxconvimg(:,1:ImgSize2),maxconvimg(:,end-ImgSize2+1:end), D_pre, H, num_ite,pre_line_type);
        log_miss(ii)=1;
        miss_infor_flag=1;
        if num_in<60
            update_w_missinfor;
            continue;
        end
%         logC0(ii)=4*para(1,1)*cos(Phai)^3/H/focal;
    end
    if sum(paraz(:))==0
    logC0(ii)=4*para(1,1)*cos(Phai)^3/H/focal^2;
    else logC0(ii)=0;
    end
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
    if miss_infor_flag==1
% % % % %         for miss_check=1:3
% % % % %             yy=(-est_ytmpl(:,miss_check)*2-1-cc_y)*-1;
% % % % %             if sum(abs(para(:,2)))==0
% % % % %                 xx=para(1,1)./(yy-D_pre)+para(2,1)*yy+para(3,1);
% % % % %             else
% % % % %                 xx=-(para(2,2)*yy+para(3,2)/2.0)/para(1,2);
% % % % %             end
% % % % %             xx=-(xx-cc_x_left);
% % % % %             yy=est_ytmpl(:,miss_check);
% % % % %             del(miss_check)=mean(abs(xx(1:round(length(xx)/2))-est_xtmpl(1:round(length(xx)/2),miss_check)));
% % % % %         end
% % % % %         [~,i_min]=min(del);
% % % % %         if i_min==1
% % % % %             leftrightlane=0;
% % % % %         elseif i_min==2
% % % % %             leftrightlane=1;
% % % % %         else leftrightlane=2;
% % % % %         end
        Detection_left_right_lane;
    end
    %sel_xtmp/sel_ytmp is essential for double while line on one side
% % % % %     if leftrightlane==0 %left lane
% % % % %         ir=intersectAB(ytmpl,sel_ytmpr);
% % % % %         il=intersectAB(sel_ytmpr,ytmpl);
% % % % %         % toc(start)
% % % % %         sel_ytmpr=sel_ytmpr(ir==1);
% % % % %         sel_xtmpr=sel_xtmpr(ir==1);
% % % % %         Corespx=xtmpl(il==1);
% % % % % %         delta_x=round(0.308*(-sel_ytmpr)+7.385);
% % % % %         sel_ytmpr=2*sel_ytmpr-1; %convert back to -480x640 coordinate
% % % % %         ind1=-sel_ytmpr-Offset;
% % % % %         ind1(ind1==0)=1;
% % % % %         delta_x=4*tdx(ind1);
% % % % %         ri_lb=round(sel_xtmpr-delta_x); %right image left boundary
% % % % %         ri_rb=round(sel_xtmpr+delta_x); %right image right boundary
% % % % %         ri_lb(ri_lb<=1)=1;
% % % % %         ri_rb(ri_rb>=(ImgSize2-2))=ImgSize2-2;
% % % % %         li_lb=round(Corespx-2*delta_x);
% % % % %         li_rb=round(Corespx+2*delta_x);
% % % % %         li_lb(li_lb<=1)=1;
% % % % %         li_rb(li_rb>=(ImgSize2-2))=ImgSize2-2;
% % % % %         ri_lb=ri_lb-1;
% % % % %         ri_rb=ri_rb-1;
% % % % %         li_lb=li_lb-1;
% % % % %         li_rb=li_rb-1;
% % % % %         
% % % % %         IntensityR=rightimg(-sel_ytmpr,:);
% % % % %         CorespL=leftimg(-sel_ytmpr,:);
% % % % %         % toc(start)
% % % % %         disparitytmp=ZNCC(ri_lb', ri_rb', li_lb', li_rb', IntensityR, CorespL);
% % % % %         % toc(start)
% % % % %         li_lb=li_lb+1;
% % % % %         ri_lb=ri_lb+1;
% % % % %         % Refer to the sign convention in 3D Vision notes
% % % % %         % Convert to left and right camera coordinates respectively
% % % % %         CorepxL=-(li_lb+disparitytmp'+(round(sel_xtmpr)-ri_lb)-cc_x_left);
% % % % %         CorepxR=-(round(sel_xtmpr)-cc_x_right);
% % % % %     else %right lane
% % % % %         il=intersectAB(ytmpr,sel_ytmpl);
% % % % %         ir=intersectAB(sel_ytmpl,ytmpr);
% % % % %         % toc(start)
% % % % %         sel_ytmpl=sel_ytmpl(il==1);
% % % % %         sel_xtmpl=sel_xtmpl(il==1);
% % % % %         Corespx=xtmpr(ir==1);
% % % % % %         delta_x=round(0.308*(-sel_ytmpl)+7.385);
% % % % %         sel_ytmpl=2*sel_ytmpl-1; %convert back to -480x640 coordinate
% % % % %         ind1=-sel_ytmpl-Offset;
% % % % %         ind1(ind1==0)=1;
% % % % %         delta_x=4*tdx(ind1);
% % % % %         li_lb=round(sel_xtmpl-2*delta_x); %right image left boundary
% % % % %         li_rb=round(sel_xtmpl+2*delta_x); %right image right boundary
% % % % %         li_lb(li_lb<=1)=1;
% % % % %         li_rb(li_rb>=(ImgSize2-2))=ImgSize2-2;
% % % % %         ri_lb=round(Corespx-1*delta_x);
% % % % %         ri_rb=round(Corespx+1*delta_x);
% % % % %         ri_lb(ri_lb<=1)=1;
% % % % %         ri_rb(ri_rb>=(ImgSize2-2))=ImgSize2-2;
% % % % %         li_lb=li_lb-1;
% % % % %         li_rb=li_rb-1;
% % % % %         ri_lb=ri_lb-1;
% % % % %         ri_rb=ri_rb-1;
% % % % %         
% % % % %         CorespL=leftimg(-sel_ytmpl,:);
% % % % %         IntensityR=rightimg(-sel_ytmpl,:);
% % % % %         % toc(start)
% % % % %         disparitytmp=ZNCC(ri_lb', ri_rb', li_lb', li_rb', IntensityR, CorespL);
% % % % %         % toc(start)
% % % % %         li_lb=li_lb+1;
% % % % %         ri_lb=ri_lb+1;
% % % % %         % Refer to the sign convention in 3D Vision notes
% % % % %         % Convert to left and right camera coordinates respectively
% % % % %         CorepxL=-(li_lb+disparitytmp'+(round(sel_xtmpr)-ri_lb)-cc_x_left);
% % % % %         CorepxR=-(round(sel_xtmpr)-cc_x_right);
% % % % %     end
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
    %     if length(Yc)>5
    %         Yc_near=Yc(end-5:end); Zc_near=Zc(end-5:end);
    %     else
    %         Yc_near=Yc; Zc_near=Zc;
    %     end
    if sum(ind_near)>5
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
    refine_para=para;
% % % % %     [xtmpl, ytmpl, xtmpr, ytmpr, refine_para]=refine_model(leftrightlane,para,sel_ytmpr,sel_ytmpl,D_pre,CorepxR,CorepxL);
% % % % %     if numel(ytmpl)==0 || numel(ytmpr)==0
% % % % %         update_w_missinfor;
% % % % %         continue;
% % % % %     end
    [~,il,ir]=intersect(ytmpl,ytmpr,'stable');
    CorL=-(xtmpl(il)-cc_x_left);
    CorR=-(xtmpr(ir)-cc_x_right);
    dis=CorR-CorL;
    indtmp=(dis>0);
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
    Xc=Xc(indtmp); Yc=Yc(indtmp); Zc=Zc(indtmp);
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
    log_expos_box{ii}=expos_box;
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
        log_lane_width_cal(ii)=lane_width;
% %         lane_width=2.95; %fixed for demo
        if lane_width==0
            lane_width=log_lane_width_f(ii-1);
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
    inf_ind=(isinf(Xw) | isinf(Yw) | isinf(Zw)) | (isnan(Xw) | isnan(Yw) | isnan(Zw)) | (Zw>30);
    Xw(inf_ind)=[];Yw(inf_ind)=[];Zw(inf_ind)=[];
    World(:,inf_ind)=[];
%     logZw_min(ii)=min(Zw);
%     logZw_max(ii)=max(Zw);
%     log_Yw_mean(ii)=mean(Yw);
    if sum(paraz(:)==0)
        if sum(abs(para(:,2)))==0 %model is hypobola
            Atmp=[Zw.^2; Zw; ones(1,length(Zw))]';
            Btmp=Xw';
            abc=pinv(Atmp)*Btmp;
            if (leftrightlane==0 && abc(1)<0) || ...
                (leftrightlane~=0 && abc(1)>0)
             Zwtmp=[Zw(end):-(Zw(end)/length(Zw)):0];
              d_Xw=2*abc(1)*Zw(end)+abc(2);
                const_line=Xw(end)-d_Xw*Zw(end);
                Xwtmp=d_Xw*Zwtmp+const_line;
                Xw=[Xw Xwtmp]; Zw=[Zw Zwtmp];
                Atmp=[Zw.^2; Zw; ones(1,length(Zw))]';
                Btmp=Xw';
                World=[Xw;[Yw zeros(1,length(Xwtmp))];Zw; ones(1,length(Xw))];
                abc=pinv(Atmp)*Btmp;
                Xw=Xw(1:length(Yw));Zw=Zw(1:length(Yw));
                World=World(:,1:length(Yw));
            end
            log_line_para(ii)=2;
            pre_line_type=2;
        else %model is line
            Atmp=[Zw; ones(1,length(Zw))]';
            Btmp=Xw';
            bc=pinv(Atmp)*Btmp;
            abc=[0; bc];
            log_line_para(ii)=1;
            pre_line_type=1;
        end
    else %model is zeg zag line
       [Xw, Yw, Zw, abc]=equavalent_line(break_location, Xw, Zw);
       World=[Xw;Yw;Zw; ones(1,length(Xw))];
       log_line_para(ii)=3;
       pre_line_type=3;
    end
    [xc_m, d_theta_m, log_k(ii)]=solve_xc_d_theta(abc,0,0,pi/2);   
    log_xc_m(ii)=xc_m;
    log_d_theta_m(ii)=d_theta_m;
    if num_in2>num_in
        lanelinechange=1;
    else lanelinechange=0;
    end
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
%         end
    else
        log_marking_width_left(ii)=log_marking_width_left(ii-1);
        log_marking_width_f_left(ii)=log_marking_width_f_left(ii-1);
        log_marking_width_right(ii)=log_marking_width_right(ii-1);
        log_marking_width_f_right(ii)=log_marking_width_f_right(ii-1);
    end
    log_tdx{ii}=tdx;
    %generate weights based on measurement and prediction. then resample
    %particles, estimate location, transform other particles based on the
    %estimated location
%     var_w_xc=(2.5071*10^(-7)*num_in*num_in-0.00051078*num_in+0.26296)^2;
%     var_w_d_theta=(-3.4*10^(-5)*num_in+0.033).^2;
    var_w_xc=(450/min([num_in,450])*0.0914)^2; 
    %std 0.07m is based on comparsion between measurements and ground truth. 
    %450 corresponding to average inliers for the corresponding ground truth images
    %xc measurement error (m-gt) follows closely as a normal distribution (0,0.0914)
    var_w_d_theta=(450/min([num_in,450])*0.0334).^2;
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
    PF_wt=exp(-0.5*(1.0*(xc_m-Predict_Xc).^2/var_w_xc+1.0*(d_theta_m-(-0.0133)-Predict_d_theta).^2/var_w_d_theta));
    if sum(PF_wt)==0 || isempty(Zw) %meaning the measurement is far way off from the prediction, indicating wrong fitting for this cycle.
        update_w_missinfor;
        xtmpl=[]; xtmpr=[];
        continue;
    end
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
    log_Estimate_d_theta(ii)=0.5*(Estimate_d_theta+log_Estimate_d_theta(ii-1));
    %Transform the previous abc and the current abc based on the newly
    %estimated locations. The one with more num_in should be used.
    if num_in<0.5*lognum_in(ii-1) && (pre_leftrightlane==leftrightlane) && (continue_frame<5)
        new_pre_World=[Rtmp -Rtmp*[Estimate_x_mean;Estimate_z_mean]]*pre_World([1,3,4],:);
        new_pre_World=[new_pre_World(1,:); pre_World(2,:); new_pre_World(2,:); pre_World(4,:)];
        new_pre_Xw=new_pre_World(1,:); new_pre_Yw=new_pre_World(2,:); new_pre_Zw=new_pre_World(3,:);
        if sum(abs(pre_para(:,2)))==0 %model is hypobola
            Atmp=[new_pre_Zw.^2; new_pre_Zw; ones(1,length(new_pre_Zw))]'; Btmp=new_pre_Xw';
            pre_abc1=pinv(Atmp)*Btmp;
        else %model is line
            Atmp=[new_pre_Zw; ones(1,length(new_pre_Zw))]'; Btmp=new_pre_Xw';
            pre_bc=pinv(Atmp)*Btmp;
            pre_abc1=[0; pre_bc];
        end
        World=new_pre_World;
        pre_World=World;
        continue_frame=continue_frame+1;
    else
% % % % %         new_Estimate_theta_mean=Estimate_d_theta+0.5*pi-d_theta_m;
% % % % %         new_Estimate_x_mean=-(Estimate_xc-xc_m)*cos(d_theta_m);
% % % % %         new_Estimate_z_mean=(Estimate_xc-xc_m)*sin(d_theta_m);
% % % % %         Rtmp1=[cos(new_Estimate_theta_mean-0.5*pi) sin(new_Estimate_theta_mean-0.5*pi); ...
% % % % %         -sin(new_Estimate_theta_mean-0.5*pi) cos(new_Estimate_theta_mean-0.5*pi)];
% % % % %         new_World=[Rtmp1 -Rtmp1*[new_Estimate_x_mean;new_Estimate_z_mean]]*World([1,3,4],:);
% % % % %         new_World=[new_World(1,:); World(2,:); new_World(2,:); World(4,:)];
% % % % %         new_Xw=new_World(1,:); new_Yw=new_World(2,:); new_Zw=new_World(3,:);
% % % % %         if sum(abs(para(:,2)))==0 %model is hypobola
% % % % %             Atmp=[new_Zw.^2; new_Zw; ones(1,length(new_Zw))]'; Btmp=new_Xw';
% % % % %             pre_abc=pinv(Atmp)*Btmp;
% % % % %         else
% % % % %             Atmp=[new_Zw; ones(1,length(new_Zw))]'; Btmp=new_Xw';
% % % % %             pre_bc=pinv(Atmp)*Btmp;
% % % % %             pre_abc=[0; pre_bc];
% % % % %         end
% % % % %         World=new_World;
% % % % %         pre_World=World;
% % % % %         pre_para=para;
% % % % %         continue_frame=0;
        tan_x=Estimate_xc*cos(-Estimate_d_theta);
        tan_z=Estimate_xc*sin(-Estimate_d_theta);
        Atmp=((Zw(end)-tan_z).^2)';
        Btmp=(Xw(end)-tan_x-tan(Estimate_d_theta)*(Zw(end)-tan_z))';
        pre_abc1=pinv(Atmp)*Btmp;
        pre_abc1=[pre_abc1;tan(Estimate_d_theta)-2*pre_abc1*tan_z; ...
            tan_x-pre_abc1*tan_z^2-(tan(Estimate_d_theta)-2*pre_abc1*tan_z)*tan_z];
        pre_World=World;
        pre_para=para;
        continue_frame=0;
    end
    
    if leftrightlane==0
        log_xc_m(ii)=log_xc_m(ii)-lane_width;
        log_Estimate_xc(ii)=log_Estimate_xc(ii)-lane_width;
%         log_predi_xc(ii)=log_predi_xc(ii)-lane_width;
    elseif leftrightlane==2
        log_xc_m(ii)=log_xc_m(ii)+lane_width;
        log_Estimate_xc(ii)=log_Estimate_xc(ii)+lane_width;
%         log_predi_xc(ii)=log_predi_xc(ii)+lane_width;
    end
    
    %Predict current location based on the v, phai and dt. Predict xc,
    %d_theta
% % % % %     dt=act_t(ii+1);
% % % % %     if v_m~=0
% % % % %         v0=v_m+sqrt(var_v).*randn(1,P_No);
% % % % %     else
% % % % %         v0=zeros(1,P_No);
% % % % %     end
% % % % %     phai0=phai_m+sqrt(var_phai).*randn(1,P_No);
% % % % %     Particle(7,:)=v0;
% % % % %     Particle(8,:)=phai0;
% % % % %     Predict_P(8,:)=Particle(8,:);
% % % % %     Predict_P(7,:)=Particle(7,:);
% % % % %     Predict_P(4,:)=cos(Particle(3,:)).*Particle(7,:);
% % % % %     Predict_P(5,:)=sin(Particle(3,:)).*Particle(7,:);
% % % % %     Predict_P(6,:)=-tan(Particle(8,:)).*Particle(7,:)/L_wheels;
% % % % %     Predict_P(1,:)=Particle(1,:)+Particle(4,:)*dt+0.25*dt/0.2*marking_width*randn(1,P_No);
% % % % %     Predict_P(2,:)=Particle(2,:)+Particle(5,:)*dt+0.25*dt/0.2*marking_width*randn(1,P_No);
% % % % %     Predict_P(3,:)=Particle(3,:)+Particle(6,:)*dt+0.01*dt/0.2*randn(1,P_No);
%     [loop_t, loop_phi, loop_v]=getloop_t_phi_v;
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
    
    pre_abc2=abc;
     pre_abc_right_lane1=conjugate_lane(pre_abc1,[0, min(pre_World(3,:))],leftrightlane,lane_width);
    pre_abc_right_lane2=conjugate_lane(pre_abc2,[min(pre_World(3,:)) max(pre_World(3,:))],leftrightlane,lane_width);
%     if Estimate_xc>=0
%         leftrightlane=0;
%     else
%         leftrightlane=1;
%     end
plotimg;
    pre_leftrightlane=leftrightlane;
    logleftrightlane(ii)=leftrightlane;
    logxytmp{ii}={xtmpr, ytmpr, xtmpr2, ytmpr2};
    miss_infor_flag=0;
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
%     pre_leftrightlane=leftrightlane;
%     logleftrightlane(ii)=leftrightlane;
%     plotimg;
    
%     if lanelinechange==1
%         xtmpl=xtmpl2; ytmpl=ytmpl2; xtmpr=xtmpr2; ytmpr=ytmpr2;
%         leftrightlane=abs(leftrightlane-1);
%     end    
    endt(ii)=toc(start);
    endf(ii)=toc(in_start);
   
    
    logpre_abc{ii}={pre_abc_right_lane1,pre_abc_right_lane2,min(pre_World(3,:))};
% % % % %     Predict_x_mean=mean(Predict_P(1,:));
% % % % %     Predict_z_mean=mean(Predict_P(2,:));
% % % % %     Predict_theta_mean=mean(Predict_P(3,:));
    
% % % % %     Rtmp2=[cos(Predict_theta_mean-0.5*pi) sin(Predict_theta_mean-0.5*pi); ...
% % % % %         -sin(Predict_theta_mean-0.5*pi) cos(Predict_theta_mean-0.5*pi)];
% % % % %     newWorld=[Rtmp2 -Rtmp2*[Predict_x_mean;Predict_z_mean]]*World([1,3,4],:);
% % % % %     newWorld=[newWorld(1,:); World(2,:); newWorld(2,:); World(4,:)];
% % % % %     newXYZc=([R T;0 0 0 1])\newWorld;
% % % % %     newXc=newXYZc(1,:); newYc=newXYZc(2,:); newZc=newXYZc(3,:);
% % % % %     yimg=focal*newYc./newZc; %[cc_y (cc_y-480)]*640
% % % % %     ximgl=(newXc-dist_left_right/2)*focal./newZc;
% % % % %     ximgr=(newXc+dist_left_right/2)*focal./newZc;
% % % % %     if sum(abs(para(:,1)))==0
% % % % %         Atmp=-[yimg' ones(length(yimg),1)]; Btmp=ximgl';
% % % % %         ef_l=pinv(Atmp)*Btmp;
% % % % %         Btmp=ximgr';
% % % % %         ef_r=pinv(Atmp)*Btmp;
% % % % %         ytmpl=top_row:-2:btm_row;
% % % % %         xtmpl=-(-ef_l(1)*ytmpl-ef_l(2))+cc_x_left;
% % % % %         ytmpr=top_row:-2:btm_row;
% % % % %         xtmpr=-(-ef_r(1)*ytmpr-ef_r(2))+cc_x_right;
% % % % %     else
% % % % %         Atmp=[1./(yimg'-D_pre) yimg' ones(length(yimg),1)]; Btmp=ximgl';
% % % % %         ABC_l=pinv(Atmp)*Btmp;
% % % % %         Btmp=ximgr';
% % % % %         ABC_r=pinv(Atmp)*Btmp;
% % % % %         ytmpl=min(floor(D_pre),top_row):-2:btm_row;
% % % % %         xtmpl=-(ABC_l(1)./(ytmpl-D_pre)+ABC_l(2)*ytmpl+ABC_l(3))+cc_x_left;
% % % % %         ytmpr=min(floor(D_pre),top_row):-2:btm_row;
% % % % %         xtmpr=-(ABC_r(1)./(ytmpr-D_pre)+ABC_r(2)*ytmpr+ABC_r(3))+cc_x_right;
% % % % %     end
% % % % %     ytmpl=-(-ytmpl+cc_y+1)/2; %[-1 -240]x640
% % % % %     ytmpr=-(-ytmpr+cc_y+1)/2;
% % % % %     
% % % % %     ytmpl(round(xtmpl)<=0)=[];
% % % % %     xtmpl(round(xtmpl)<=0)=[];
% % % % %     ytmpl(round(xtmpl)>ImgSize2)=[];
% % % % %     xtmpl(round(xtmpl)>ImgSize2)=[];
% % % % %     
% % % % %     ytmpr(round(xtmpr)<=0)=[];
% % % % %     xtmpr(round(xtmpr)<=0)=[];
% % % % %     ytmpr(round(xtmpr)>ImgSize2)=[];
% % % % %     xtmpr(round(xtmpr)>ImgSize2)=[];
    
end
catch err
    disp 'sth wrong'
    rethrow(err);
end
end