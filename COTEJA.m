%��в����%
%��ͼ����Ϊ15kmX15km%
%�龰1���ٶԶ�
clc
clear 
Jammers_pos=[2 6 5;2 9 5;4 12 5;7 12 5];%���Ż���վ
global M
M=size(Jammers_pos,1);
Radars_pos=[6 3 0;6 6 0;6 9 0;9 10 0;12 12 0];%�״ﲼվ
global N
N=size(Radars_pos,1);
for m=1:M
    for n=1:N
        R(m,n)=norm(Jammers_pos(m,:)-Radars_pos(n,:));%�������
    end
end

Jamming_range=30;%���ŷ�Χkm
Radars_range=[15 10 12 14 13];%�״ﷶΧkm
Weapons_range=[3 4 3 4 5];%����Χkm
for n=1:N
    P(:,n)=1-(R(:,n)-Weapons_range(n))/(Radars_range(n)-Weapons_range(n));
end
% scatter3(Jammers_pos(:,1),Jammers_pos(:,2),Jammers_pos(:,3),'b','filled');hold on;
% scatter3(Radars_pos(:,1),Radars_pos(:,2),Radars_pos(:,3),'r^','filled');
% axis([0 15 0 15 0 7])
show=1;
platform_illumination=0;
P(P<0)=0;P(P>1)=1;%��������%
Radar_stage=[0.2 0.5 0.8 1.0];%�״�׶ε÷֣����������񡢸��١�������
Radar_stage_Nt=[0.5 0.5 0.5 0.5 0.5];%����ʱ2/4         ---as same as noPL
Radars_stage=[1 1 1 1 1];%�״�׶�����
%------------------------------------PL------------------------------------
% Radar_stage_Nt=[1 0.5 0.5 0.5 1];%ת��ʱ��2 s��         ---as same as noPL 
% Radars_stage=[2 1 1 1 2];%�״�׶�����

% Radar_stage_Nt=[1 0.5 0.5 0.5 1];%ת��ʱ��2 s��         ---as same as noPL
% Radars_stage=[3 1 1 1 3];%�״�׶�����

% Radar_stage_Nt=[0 0.5 0.5 0.5 0];%ת��ʱ��1��           ---PL
% Radars_stage=[4 1 1 1 4];%�״�׶�����

% Radar_stage_Nt=[0.5 0.5 0.5 1 0];%ת��ʱ��1��           ---noPL
% Radars_stage=[1 1 1 2 4];%�״�׶�����

% Radar_stage_Nt=[0.5 1 0.5 1 0.5];%ת��ʱ��1��           ---PL
% Radars_stage=[1 2 1 2 1];%�״�׶�����

% Radar_stage_Nt=[1 0.5 0.5 0.5 0.5];%ת��ʱ��1��           ---noPL
% Radars_stage=[2 1 1 1 1];%�״�׶�����

% Radar_stage_Nt=[0.5 0.5 0.5 0.5 1];%ת��ʱ��1��         ---PL
% Radars_stage=[1 1 1 1 2];%�״�׶�����

% Radar_stage_Nt=[1 0.5 0.5 0.5 1];%ת��ʱ��1��             ---noPL
% Radars_stage=[3 1 1 1 2];%�״�׶�����

% Radar_stage_Nt=[1 0.5 0.5 0.5 1];%ת��ʱ��1��           ---PL
% Radars_stage=[2 1 1 1 3];%�״�׶�����

% Radar_stage_Nt=[0.5 0.5 0.5 1 1];%ת��ʱ��1��           ---noPL
% Radars_stage=[1 1 1 2 3];%�״�׶�����

Radars_adv=[0.4 0.6 0.8 0.4 0.2];%�״��Ƚ�������
W=[3 2];%��Ȩ����

% �����ʼDn  
Dn=zeros(1,N);
Dn=Dncal(P,W,Radars_adv,Radar_stage_Nt,Radars_stage,Radar_stage);
Dnp=Dsum(Dn,Radars_stage);%������

%��в��ͼ%
% Rd=0.1;
% x=0:Rd:15;
% y=0:Rd:15;
% z=0:Rd:15;
% I=numel(x);
% J=numel(y);%����ֱ���Ϊ100m
% K=numel(z);%����ֱ���Ϊ100m

%����Ч������%
%1.�׶���Ч�ԣ���4�׶ζ�Ӧ5����%
if platform_illumination == 1
    Se_factors=[ 0.8  0.9 1.0 -0.9 -0.9; 
                 0.9  0.9 1.0 -0.9 -0.9;
                -0.9 -0.9 0.0 0.9   0.8;
                -0.9 -0.9 0.0 0.8   0.9];
else
    Se_factors=[ 0.8  0.9 1.0 0.2  0.2; 
                 0.9  0.9 1.0 0.1  0.1;
                 0.5  0.5 0.0 0.9  0.8;
                 0.5  0.5 0.0 0.8  0.9];
end
        
R2=(1-R/Jamming_range).^2;
%�Ż��㷨%
MEC=100;
NP=20;
G=500;%����ݻ�����
tic
for mec=1:MEC
%��ʼ��
Dnp_Initialization=zeros(NP,N);
Dn_Test=zeros(NP,N);
En_final_Test=zeros(NP,N);
Code_son=zeros(M,N+3,NP);
Dn_father=zeros(NP,N);
Dn_son=zeros(NP,N);
D_total_Mean=zeros(1,G);
D_total_Best=zeros(1,G);

%�޸Ĺ�����ɢ��ֽ����㷨%

for np=1:NP
    %1-ȫ�������
    [Code_Initial(:,:,np),Emn_I,Tech_I]=Code_Initialization(R2,Radars_stage,Se_factors);
    %����En_final%
    En_final_Initialization=En_Final(Emn_I,Tech_I); 
    %����(��ʼ)
    Dnp_Initialization(np,:)=(1.-En_final_Initialization).*Dnp;%���ź�
    Radars_stage_0=Radars_stage;%���ų�
    Radar_stage_Nt_0=Radar_stage_Nt;
    Dn1=Dn;
    while 1
        %�����״�״̬�Ƿ�����
        [change,Radars_stage_1(np,:),Radar_stage_Nt_1(np,:)]=Stagechange(Dnp_Initialization(np,:),Dn1,Radars_stage_0,Radar_stage_Nt_0);%change=1��ʾ������
        if change==0
            break;%δ����
        end
        %3-�������%
        for m=1:M
            [Emn_I(m,:),Tech_I(m,:)]=Decoding(m,Code_Initial(m,:,np),R2,Radars_stage_1(np,:),Se_factors);
        end
        En_final_Initialization=En_Final(Emn_I,Tech_I); 
        Dn1=Dncal(P,W,Radars_adv,Radar_stage_Nt_1(np,:),Radars_stage_1(np,:),Radar_stage);
        Dnp1=Dsum(Dn1,Radars_stage_1(np,:));%������
        Dnp_Initialization(np,:)=(1.-En_final_Initialization).*Dnp1;%���ź�
        Radar_stage_Nt_0=Radar_stage_Nt_1(np,:);
        Radars_stage_0=Radars_stage_1(np,:);
    end   
end

for g=1:G
    Code_mutant=zeros(M,N+3,NP);
    Code_cross=zeros(M,N+3,NP);
    if g==1
        Code_father=Code_Initial;  
        Dn_father=Dnp_Initialization;
    else
        Code_father=Code_son;
        Dn_father=Dn_son;
    end
    for np=1:NP
        SQ=RM(np,NP);
        Code_mutant(:,:,np)=mutant(Code_father(:,:,SQ));
        for m=1:M
            if rand<=0.9
                Code_cross(m,:,np)=Code_mutant(m,:,np);
            else
                Code_cross(m,:,np)=Code_father(m,:,np);
            end
        end
        %3-�������%
        for m=1:M
            [Emn(m,:,np),Tech(m,:,np)]=Decoding(m,Code_cross(m,:,np),R2,Radars_stage,Se_factors);
        end
        %����En_final%
        [En_final_Test(np,:)]=En_Final(Emn(:,:,np),Tech(:,:,np)); 
        %����
        Dn_Test(np,:)=(1.-En_final_Test(np,:)).*Dnp;
        Radars_stage_0=Radars_stage;%���ų�
        Radar_stage_Nt_0=Radar_stage_Nt;
        Dn1=Dn;
        while 1
            %�����״�״̬�Ƿ�����
            [change,Radars_stage_1(np,:),Radar_stage_Nt_1(np,:)]=Stagechange(Dn_Test(np,:),Dn1,Radars_stage_0,Radar_stage_Nt_0);%change=1��ʾ������
            if change==0
                break;%δ����
            end
            %3-�������%
            for m=1:M
                [Emn(m,:,np),Tech(m,:,np)]=Decoding(m,Code_cross(m,:,np),R2,Radars_stage_1(np,:),Se_factors);
            end
            En_final_Test=En_Final(Emn(:,:,np),Tech(:,:,np)); 
            Dn1=Dncal(P,W,Radars_adv,Radar_stage_Nt_1(np,:),Radars_stage_1(np,:),Radar_stage);
            Dnp1=Dsum(Dn1,Radars_stage_1(np,:));%������
            Dn_Test(np,:)=(1.-En_final_Test).*Dnp1;%���ź�
            Radar_stage_Nt_0=Radar_stage_Nt_1(np,:);
            Radars_stage_0=Radars_stage_1(np,:);
        end  
        if sum(Dn_Test(np,:))<sum(Dn_father(np,:))%С�Ĳ��ֱ��滻
            Code_son(:,:,np)=Code_cross(:,:,np);
            Dn_son(np,:)=Dn_Test(np,:);
        else
            Code_son(:,:,np)=Code_father(:,:,np);
            Dn_son(np,:)=Dn_father(np,:);
        end
    end
    D_total_Mean(g)=mean(sum(Dn_son'));%ƽ��ֵ
    [D_total_Best(g),pos]=min(sum(Dn_son'));%���Ž�
    if  D_total_Mean(g)-D_total_Best(g)<1e-5
        break;
    end
end
    D_total_Mean_Best(mec)=D_total_Best(g);
    if mec==1
        Maxe=D_total_Mean_Best(mec);
        Code_Best=Code_son(:,:,pos);
        Dn_Best=Dn_son(pos,:);
        Radar_stage_Nt_Best=Radar_stage_Nt_1(pos,:);
        Radar_stage_Best=Radars_stage_1(pos,:);
    else
        if D_total_Mean_Best(mec)<Maxe
            Code_Best=Code_son(:,:,pos);
            Dn_Best=Dn_son(pos,:);
            Radar_stage_Nt_Best=Radar_stage_Nt_1(pos,:);
            Radar_stage_Best=Radars_stage_1(pos,:);
        end
    end
end
toc

[change,Radars_stage_next,Radar_stage_Nt_next]=Stagechange(Dn_Best,Dnp,Radars_stage,Radar_stage_Nt)

MEAN=mean(D_total_Mean_Best)
MIN=min(D_total_Mean_Best)
% sum(Dnp)
sum(Dn_Best)
(sum(Dnp)-MEAN)/(sum(Dnp)-MIN)

Code_Best

if show == 1
    figure
    hold on;
    plot(1:g,D_total_Mean(1:g),'r--','LineWidth',2);
    plot(1:g,D_total_Best(1:g),'b','LineWidth',2);
    xlabel('Number of iteration')
    ylabel('Total danger value')
    legend('ePDE: Mean value','ePDE: Best value')
    axis([1 500 0.5 4.5])
    grid on
end






