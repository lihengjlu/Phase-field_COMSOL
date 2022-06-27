function out = random_circle

import com.comsol.model.*
import com.comsol.model.util.*
model = ModelUtil.create('Model');
model.component.create('comp1', true); % 生成组件1
model.component('comp1').geom.create('geom1', 2); % 生成2D几何
model.component('comp1').mesh.create('mesh1'); % 生成网格
model.component("comp1").geom("geom1").lengthUnit("mm");
Length = 1;
model.param.set('Length', num2str(Length)); % 参数名称，�??
model.param.descr('Length', 'The Length of a cube');% 参数描述
vf = 0.9;
model.param.set('vf', num2str(vf));
model.param.descr('vf', 'The volume fraction of fillers');%填料的体积分�?
Vsq = Length^2*0.5*0.6;
model.param.set('Vsq', num2str(Vsq));
miu = 0.04;
model.param.set('miu', num2str(miu)); % 用于控制circle大小的正态分布参�?
model.param.descr('miu', 'Average radius');
sigma = 0.005;
model.param.set('sigma', num2str(sigma));
model.param.descr('sigma', 'standard deviation');%标准�?
model.component('comp1').geom('geom1').create('r1', 'Rectangle');%生成�?个正方形
model.component('comp1').geom('geom1').feature('r1').set('size',{'Length' 'Length*0.5'});%尺寸1m
model.component('comp1').geom('geom1').feature('r1').set('pos', [0 0]); %基准位置�?0�?0�?
% 坐标原点为默认�?�，此句可以省略
model.component('comp1').geom('geom1').run('r1');
 mphgeom(model,'geom1');
n = 10000;
Vsum = 0;
Pos = zeros(n,2);
R = zeros(n,1);
idx = 1; % index for circle 
flag = 0;
while (Vsum < Vsq * vf)
    r = abs( normrnd(miu,sigma) ); % 随机生成cicle
    pos = [Length * rand(1,1) Length * rand(1,1)*0.5];%随机圆位�?
    for k = 1:idx %将随机生成的cicle与已存在的所有cicle进行距离判断
        Distance = sqrt((pos(1)-Pos(k,1))^2+(pos(2)-Pos(k,2))^2);
        rsum = r+R(k);
        if Distance < rsum
            flag = 1;
            break;
        end
    end
    
    if flag == 1 % 如果新生成cicle与任意一个已存在cicle重叠，则进入下一轮循环，放弃此次生成的cicle
        flag = 0;
        continue;
    end
    
    if (pos(1)-r < 0) || (pos(2)-r < 0) || (pos(1)+r > Length) || (pos(2)+r > Length*0.5)
        %判断是否在正方形�?
        continue;
    end
    
    V = Vsum + 2 * pi * r * r;
    if V > vf * Vsq %进行体积分率条件判断
        break;
    end
    
    % 至此，随机生成的cicle参数满足不重叠条件�?�正方形内条件与体积分率条件判断，将其正式生成几�?
    cl_name = ['cl',num2str(idx)]; % cicle序列�?
    model.component('comp1').geom('geom1').create(cl_name, 'Circle');
    model.geom('geom1').feature(cl_name).set('base', 'center');
    model.component('comp1').geom('geom1').feature(cl_name).set('r', num2str(r));
    model.component('comp1').geom('geom1').feature(cl_name).set('pos', pos);
    mphgeom(model,'geom1');
    
    Pos(idx,:) = pos;
    R(idx) = r;
    idx = idx +1;
    Vsum = Vsum + 2 * pi * r * r; 
    
end
mphsave(model,'random_circle'); % 保存mph文件至当前文件夹
out = model;                
