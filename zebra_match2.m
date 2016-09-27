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
log_ite_s=[3 741 461 3];
log_ite_e=[378 741 857 911];

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
    load 'zebra_gt.mat';
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
    %     try
    %     KickOff_PF2;
    counter=2;
    log_abnorm=zeros(1,4);

    B=zeros(225,150);
    NFFT=2^nextpow2(size(B,2));
    fre_seq=size(B,2)/2*linspace(0,1,NFFT/2+1);
    for ii=[135:143, 284:287, 579:586, 733:740]
%     for ii=ite_s:ite_e
        counter=2;
        log_zebra(ii)=0;
        zebra_rows=[];
        if ii==138
            a=0;
        end
        in_start=tic;
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
        
        
        temp_p=0.3; temp_H=1.66; temp_td=230;
        tempimg=rightimg(1:2:end,:);
        [ipm_img,A]=C_ipm_no_rotate2(tempimg,temp_p,temp_H,focal,temp_td,cc_x_right,cc_y);

        z_t=tic;
        B=ipm_img(1:2:end,1:2:end); Bori=B;
        sum_B_row=sum(B,2);
        conv_t=tic;
        convB=conv2(B,ones(1,16)/16,'same');
        ridge_P=C_new_Ridge_zebra(convB,12,sum_B_row);
        ridge_N=C_new_Ridge_zebra(-convB,12,sum_B_row);
        ridge=ridge_P+ridge_N;
        ridge(ridge>1)=1;
        log_conv_t(ii)=toc(conv_t);
        sum_ridge=sum(ridge,2);
        startrow=1; endrow=1;
        loop_t=tic;
        for row_z=1:2:size(B,1)
            if row_z==55 || row_z==56
                aa=0;
            end
            if sum_ridge(row_z)>=3
            b=B(row_z,:);
            cum_b=cumsum(b);
            lead0_ind=find(cum_b~=0,1);
            cum_b=cumsum(flip(b));
            end0_ind=find(cum_b~=0,1);
            end0_ind=size(B,2)-end0_ind;
            if cum_b(end)~=0 && (end0_ind-lead0_ind>=25)
                a=convB(row_z,lead0_ind:end0_ind);
                a=a-mean(a);
% %                 [~,locs_t]=findpeaks(a,'MINPEAKDISTANCE',25);
% %                 [~,locs_b]=findpeaks(-a,'MINPEAKDISTANCE',25);
% %                 locs=sort([locs_t locs_b]);
                locs=find(ridge(row_z,lead0_ind:end0_ind)==1);
                locs(abs(a(locs)-mean(a))<=10)=[];
                if length(locs)>=2
                    locs_diff=locs(2:end)-locs(1:(end-1));
                    locs_diff_valid=(locs_diff>=11 & locs_diff<=20);
                    if (sum(locs_diff_valid)<3 && row_z<=127) || (sum(locs_diff_valid)<2 && row_z>127)
                        zebra_status=0;
                    else
                        dumy_counter=0;
                        if row_z<=127
                            for ij=1:length(locs_diff_valid)
                                if locs_diff_valid(ij)==1
                                    dumy_counter=dumy_counter+1;
                                else
                                    dumy_counter=0;
                                end
                                if dumy_counter>=3
                                    break;
                                end
                            end
                            if dumy_counter>=3
                                zebra_status=1;
                            else
                                zebra_status=0;
                            end
                        else
                            for ij=1:length(locs_diff_valid)
                                if locs_diff_valid(ij)==1
                                    dumy_counter=dumy_counter+1;
                                else
                                    dumy_counter=0;
                                end
                                if dumy_counter>=2
                                    break;
                                end
                            end
                            if dumy_counter>=2
                                zebra_status=1;
                            else
                                zebra_status=0;
                            end
                        end
                        
                    end
                else
                    zebra_status=0;
                end
                a=fft(a,NFFT)/length(a);
                a=a(1:(NFFT/2+1));
                ma=abs(a);
                
                [ma_max,ma_ind]=max(ma);
                ori_ma_max=ma_max;
                if (fre_seq(ma_ind)>=4 && fre_seq(ma_ind)<=6.5) && (ma_max>=7) && (zebra_status==1)
                    endrow=row_z;
                elseif ((end0_ind-(lead0_ind+30))>=25)
                    a=convB(row_z,(lead0_ind+30):end0_ind);
                    a=a-mean(a);
% % %                     [~,locs_t]=findpeaks(a,'MINPEAKDISTANCE',25);
% % %                     [~,locs_b]=findpeaks(-a,'MINPEAKDISTANCE',25);
% % %                     locs=sort([locs_t locs_b]);
                    locs=find(ridge(row_z,lead0_ind+30:end0_ind)==1);
                    locs(abs(a(locs)-mean(a))<=10)=[];
                    if length(locs)>=2
                        locs_diff=locs(2:end)-locs(1:(end-1));
                        locs_diff_valid=(locs_diff>=11 & locs_diff<=18.75);
                        if (sum(locs_diff_valid)<3 && row_z<=127) || (sum(locs_diff_valid)<2 && row_z>127)
                            zebra_status=0;
                        else
                            dumy_counter=0;
                            if row_z<=127
                                for ij=1:length(locs_diff_valid)
                                    if locs_diff_valid(ij)==1
                                        dumy_counter=dumy_counter+1;
                                    else
                                        dumy_counter=0;
                                    end
                                    if dumy_counter>=3
                                        break;
                                    end
                                end
                                if dumy_counter>=3
                                    zebra_status=1;
                                else
                                    zebra_status=0;
                                end
                            else
                                for ij=1:length(locs_diff_valid)
                                    if locs_diff_valid(ij)==1
                                        dumy_counter=dumy_counter+1;
                                    else
                                        dumy_counter=0;
                                    end
                                    if dumy_counter>=2
                                        break;
                                    end
                                end
                                if dumy_counter>=2
                                    zebra_status=1;
                                else
                                    zebra_status=0;
                                end
                            end
                        end
                    else
                        zebra_status=0;
                    end
                    a=fft(a,NFFT)/length(a);
                    a=a(1:(NFFT/2+1));
                    ma=abs(a);
                    [ma_max,ma_ind]=max(ma);
                    if (fre_seq(ma_ind)>=4 && fre_seq(ma_ind)<=6.5) && (ma_max>=7) && (zebra_status==1)
                        endrow=row_z;
%                         del=ma(2:end)-ma(1:(end-1));
%                         for j=ma_ind:length(del)
%                             if (del(j)<=0)
%                                 ma(j)=0;
%                             else break;
%                             end
%                         end
%                         if ma_ind>1
%                             for j=(ma_ind-1):-1:1
%                                 if (del(j)>=0)
%                                     ma(j)=0;
%                                 else break;
%                                 end
%                             end
%                         end
%                         [ma_max2,ma_ind2]=max(ma);
                    end
                end
            end
            end
            if (endrow-startrow)==2
                counter=counter+2;
                startrow=endrow;
            else
                if counter>=10
                    B((endrow-counter+1):endrow,:)=255;
                    log_zebra(ii)=1;
                    zebra_rows=[zebra_rows;(endrow-counter+1) endrow];
                end
                counter=1;
                startrow=row_z;
            end
        end
        
        if log_zebra(ii)==1
            ridge2=zeros(size(ridge));
            for i=1:size(zebra_rows,1)
                ridge2(zebra_rows(i,1):zebra_rows(i,2))=ridge(zebra_rows(i,1):zebra_rows(i,2));
            end
        end
            
        
        
        
        
        
        log_loopt(ii)=toc(loop_t);
        log_z_t(ii)=toc(z_t);
        % % %         rimgtmp3d=imread(strcat(rightimg_dir,int2str(ii),'.jpg'));
        % % %         rimgtmp1d=double(rimgtmp3d(:,:,1));
        % % %         rimgtmp1d=Retify(rimgtmp1d,a1_right,a2_right,a3_right,a4_right,ind_1_right,ind_2_right,ind_3_right,ind_4_right,ind_new_right);
        % % %         rimgtmp3d(:,:,1)=rimgtmp1d;
        % % %         rimgtmp1d=double(rimgtmp3d(:,:,2));
        % % %         rimgtmp1d=Retify(rimgtmp1d,a1_right,a2_right,a3_right,a4_right,ind_1_right,ind_2_right,ind_3_right,ind_4_right,ind_new_right);
        % % %         rimgtmp3d(:,:,2)=rimgtmp1d;
        % % %         rimgtmp1d=double(rimgtmp3d(:,:,3));
        % % %         rimgtmp1d=Retify(rimgtmp1d,a1_right,a2_right,a3_right,a4_right,ind_1_right,ind_2_right,ind_3_right,ind_4_right,ind_new_right);
        % % %         rimgtmp3d(:,:,3)=rimgtmp1d;
        % % %         rimgtmp3d=rimgtmp3d(1:2:ImgSize1,:,:);
        % % %         imshow(rimgtmp3d,[]);
        % % %
        imshow([Bori,B],[]);
        drawnow;
        frame=getframe(gcf);
        im=frame2im(frame);
        imwrite(im,strcat(save_dir,'\3DZebra',int2str(ii),'.jpg'),'jpg');
        % %         log_TP_counter(ii)=TP_counter;
        % %         log_FP_counter(ii)=FP_counter;
    end
    %     end
end