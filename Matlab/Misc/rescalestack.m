function rescalestack(inPathTag,outPathTag, factor)
% resize a stack by factor

    m = Mmap(inPathTag);

    fid = fopen([outPathTag '.bin'], 'wb');

    x = ceil(m.x*factor);
    y = ceil(m.y*factor);
    z = m.z;
    t = m.t;
    Z = m.Z;
    T = m.T;
    space = m.space;
    pixtype = m.pixtype;

    save([outPathTag '.mat'], 'x', 'y', 'z', 't', 'Z', 'T', 'space','pixtype');

    for it = T
        for iz = Z
            img = imresize(m(:,:,iz,it), [x y]);
            fwrite(fid, img, pixtype);
        end
        disp(it);
    end

    fclose(fid);

end
        