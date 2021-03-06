function createGrayStack(F)
%createGrayStack creates a gray stack (mean along t all 77 frames)

    m = Focused.Mmap(F, 'corrected');

    Focused.mkdir(F, 'graystack');
    output = [F.tag('graystack') '.bin'];
    outputInfo = [F.tag('graystack') '.mat'];

    fid = fopen(output, 'wb');

    for z = m.Z
        fwrite(fid, mean(m(:,:,z,1:77:m.t), 4), 'uint16');
    end

    fclose(fid);
    
    % data
    x = m.x;
    y = m.y;
    z = m.z;
    t = 1; %#ok<NASGU>
    Z = m.Z;
    T = 1; %#ok<NASGU>
    space = 'RAS'; % (not m.space because mmap always returns RAS)
    pixtype = m.pixtype;

    % create corresponding info
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space','pixtype');
    
    writeNHDR(F,'graystack');

end
