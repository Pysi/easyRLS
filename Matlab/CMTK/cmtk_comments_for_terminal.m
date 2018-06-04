%% go to gray stack directory where also a links to the referenc brain is saved
cd /home/ljp/Science/Projects/RLS/Data/2018-05-24/Run\ 08/Analysis/graystack.stack

% affine transformation
cmtk registration -i -v --coarsest 25.6 --sampling 3.2 --omit-original-data --exploration 25.6 --dofs 6 --dofs 12 --accuracy 3.2 -o ./Registration/affine_ZBrain zBrain_Elavl3-H2BRFP.nrrd graystack.nhdr

% warp transformation
cmtk warp -v --fast --grid-spacing 40 --refine 2 --jacobian-weight 0.001 --coarsest 6.4 --sampling 3.2 --accuracy 3.2 --omit-original-data  --energy-weight 1e-1 --initial ./Registration/affine_ZBrain -o ./Registration/warp_ZBrain zBrain_Elavl3-H2BRFP.nrrd graystack.nhdr

% reformat graystack warp
cmtk reformatx -o Registration/reformatted_ZBrain/GrayToZBrain_Elavl3-H2BRFP.nrrd --floating graystack.nhdr zBrain_Elavl3-H2BRFP.nrrd Registration/warp_ZBrain

% reformat graystack affine
cmtk reformatx -o Registration/reformatted_ZBrain/GrayToZBrain_Elavl3-H2BRFP.nrrd --floating graystack.nhdr zBrain_Elavl3-H2BRFP.nrrd Registration/affine_ZBrain
