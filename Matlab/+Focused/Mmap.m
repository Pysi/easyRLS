F, tag

TODO
{'4.1', '4.2'} 


            self.tag = tag;
            self.binFile = [tag '.bin'];
            
binFile = fullfile(F.dir.files, self.binFile); % TODO know automatically location thanks to tag 
            inputInfo = fullfile(F.dir.files, [tag '.mat']); % TODO know automatically location thanks to tag
