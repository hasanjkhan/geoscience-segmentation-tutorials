clear; clc; clf

signal = [1500;550];
noise = [150;10];
allR = [];

figure(1)
for ii = 1:2 %noise
    for jj = 1:2 %signal
        img = ones(251,251)*500;
        img(100:150,100:150) = signal(jj);
        img = img + randi([-noise(ii),noise(ii)],size(img));
        subplot(2,2,(ii-1)*2+jj)
        imshow(img,[0,2500])
        str = ['n = ',num2str(noise(ii)),' | s = ',...
            num2str(signal(jj))];
        title(str)

        img = uint8(img / 2500 * 255);
        R = img(125,:);

        imwrite(img,['n',num2str(noise(ii)),'s',num2str(signal(jj)),...
            '.jpg']);
        allR = [allR,R'];
    end
end
%%
h = figure(2);
plot(allR,'linewidth',1.5)
axis([0 255 0 251])
set(gca,'XTick',[],'YTick',[])
legend({'High Contrast, High Noise','Low Contrast, High Noise',...
    'High Contrast, Low Noise','Low Contrast, Low Noise'},...
    'Location','north')
