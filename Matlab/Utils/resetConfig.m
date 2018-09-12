function resetConfig(F)
% reset repertory to zero
    rmdir(F.dir('Analysis'))
    if strcmp(F.extra.Source, 'dcimg')
        delete([F.tag('dcimg') '.mat'])
    end
    delete(F.tag('Config'))
end