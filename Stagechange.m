function [change,Radars_stage_dt,Radars_stage_Nt_dt] =Stagechange(Dne,Dn,Radars_stage,Radar_stage_Nt)%���ú���    
    global N
    change=0;%��������
    Radars_stage_dt=Radars_stage;
    Radars_stage_Nt_dt=Radar_stage_Nt;
    for n=1:N
        if Radars_stage(n)==1&&Radar_stage_Nt(n)==1%Ϊ1���Ѿ�������ʱ
        else
            if Dne(n)/Dn(n)<=0.6
                change=1;
                Radars_stage_dt(n)=1;
                Radars_stage_Nt_dt(n)=1;
            end 
        end        
    end
end