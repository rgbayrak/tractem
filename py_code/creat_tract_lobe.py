import subprocess
import os
import glob
import numpy as np
import nibabel as nib
from threading import Timer

def skip_timeout(args, timeout):
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE,shell=True)
    timer = Timer(timeout, lambda process: process.kill(), [p])
    try:
        timer.start()
        stdout, stderr = p.communicate()
        return_code = p.returncode
        return (stdout, stderr, return_code)
    finally:
        timer.cancel()



def merge_roa(roa_list,out_path):
    x=np.zeros((157,189,156))
    y=np.zeros((157,189,156))
    if not roa_list==[]:
        image_affine=nib.load(roa_list[0]).affine
        for roa in roa_list:
            image_data = nib.load(roa).get_data()
            x += image_data
        new_loc=x>=1
        y[:,:,:]=new_loc[0:157,0:189,0:156]
        new_roa = nib.Nifti1Image(y, image_affine)
        nib.save(new_roa, out_path)



def create_tract(dire,in_path,out_path,txtfile,file_name,short_name,tract_number,number_roi):
    
    with open(txtfile, 'a') as fileobject:
        #for file in os.listdir(in_path):
            #dire.append(os.path.join(in_path, file))
            #print(dire)
        for basename_folder in dire:
            folder=os.path.join(in_path,basename_folder)
            #print(folder)
            #basename_folder = os.path.basename(folder)
            #print(basename_folder)
            path=os.path.join(out_path, basename_folder)
            #print(path)
            if not os.path.exists(path):
                os.mkdir(path)
            number = basename_folder[0:4]
            
            for tractfolder in os.listdir(folder):
                #print(tractfolder)
                
                if not tractfolder in file_name:
                    R1 = '\n'+'Misnaming ' + os.path.join(folder, tractfolder)
                    fileobject.write(R1)
                    continue
                region_list = glob.glob(os.path.expanduser(os.path.join(folder, tractfolder, '*.nii.gz')))
                program = '/home-local/wangx41/dsistudio/build/dsi_studio --action=trk --source=/%s/%s_tal_fib.gz  --fiber_count=100000 --threshold_index=nqa --fa_threshold=0.1' % (folder,number)
                program1='/home-local/wangx41/dsistudio/build/dsi_studio --action=trk --source=/%s/%s_tal_fib.gz  --fiber_count=100000 --threshold_index=nqa --fa_threshold=0.1' % (folder,number)
               
              
            
                path1=os.path.join(out_path, basename_folder, tractfolder)
                if not os.path.exists(path1):
                    os.mkdir(path1)
                if not region_list == []:
                      roa_list = []
                      if short_name[file_name.index(tractfolder)] == 'fx':
                          il = i = j = k = 0
                          #print(region_list)
                          for region in region_list:
                              basename = os.path.basename(region)
                              #print(basename)
                              
                              
                              if 'L_seed' in basename:
                                  il += 1
                                  if il == 1:
                                      program += ' --seed=%s' % region
                                      #print(program)
                                  else:
                                      program += ' --seed%d=%s' % (il, region)
                              if 'ROI' in basename:
                                  j += 1
                                  if j == 1:
                                      program1 += ' --roi=%s' % region
                                      program += ' --roi=%s' % region
                                  else:
                                      program1 += ' --roi%d=%s' % (j, region)
                                      program += ' --roi%d=%s' % (j, region)

                              if 'ROA' in basename:
                                  roa_list.append(region)
                              if 'R_seed' in basename:
                                  i += 1
                                  if i == 1:
                                      program1 += ' --seed=%s' % region
                                  else:
                                      program1 += ' --seed%d=%s' % (i, region)
                          out_path1 = os.path.join(path1, 'fx_ROA1.nii.gz')
                          merge_roa(roa_list, out_path1)
                          program1 += ' --roa=%s' % out_path1
                          program += ' --roa=%s' % out_path1
                          program += ' --output=%s/fx_L_tract.trk.gz --export=tdi' % os.path.join(out_path, basename_folder, tractfolder)
                        
                          program1 += ' --output=%s/fx_R_tract.trk.gz --export=tdi' % os.path.join(out_path, basename_folder, tractfolder)
                          
                          #fileobject.write(program1)
                          #fileobject.write(program)
                          print(program)
                          print(program1)
                          skip_timeout(program,1800)
                          skip_timeout(program1,1800)
                      else:
                          if tract_number[file_name.index(tractfolder)] == 1:
                              i = k = j = 0
                              for region in region_list:
                                  basename = os.path.basename(region)
                                  
                                  if 'seed' in basename:
                                      i += 1
                                      if i == 1:
                                          program += ' --seed=%s' % region
                                      else:
                                          program += ' --seed%d=%s' % (i, region)
                                  if 'ROI' in basename:
                                      j += 1
                                      if j == 1:
                                          program += ' --roi=%s' % region
                                      else:
                                          program += ' --roi%d=%s' % (j, region)
                                  if 'ROA' in basename:
                                      roa_list.append(region)
                              out_path2 = os.path.join(path1, short_name[file_name.index(tractfolder)]+'_ROA1.nii.gz')
                              merge_roa(roa_list, out_path2)
                              program += ' --roa=%s' % out_path2
                              program += ' --output=%s' % path1
                              program += '/%s_tract.trk.gz --export=tdi' %short_name[file_name.index(tractfolder)]
                              print(program)
                              
                              #fileobject.write(program)

                              skip_timeout(program,1800)
                          else:
                              il = k = jl = i = j = 0
                              for region in region_list:
                                  basename = os.path.basename(region)
                                  
                                  
                                  if 'L_seed' in basename:
                                      il += 1
                                      if il == 1:
                                          program += ' --seed=%s' % region
                                      else:
                                          program += ' --seed%d=%s' % (il, region)
                                  if 'L_ROI' in basename:
                                      jl += 1
                                      if jl== 1:
                                          program += ' --roi=%s' % region
                                      else:
                                          program += ' --roi%d=%s' % (jl, region)
                                  if 'ROA' in basename:
                                      roa_list.append(region)


                                  if 'R_seed' in basename:
                                      i += 1
                                      if i == 1:
                                          program1 += ' --seed=%s' % region
                                      else:
                                          program1 += ' --seed%d=%s' % (i, region)
                                  if 'R_ROI' in basename:
                                      j += 1
                                      if j == 1:
                                          program1 += ' --roi=%s' % region
                                      else:
                                          program1 += ' --roi%d=%s' % (j, region)
                              out_path2 = os.path.join(path1, short_name[file_name.index(tractfolder)] + '_ROA1.nii.gz')
                              merge_roa(roa_list, out_path2)
                              program += ' --roa=%s' % out_path2
                              program1 += ' --roa=%s' % out_path2
                              program += ' --output=%s' % os.path.join(out_path, basename_folder, tractfolder)
                              program += '/%s_L_tract.trk.gz  --export=tdi' %short_name[file_name.index(tractfolder)]
                              program1 += ' --output=%s' % os.path.join(out_path, basename_folder, tractfolder)
                              program1 += '/%s_R_tract.trk.gz --export=tdi' % short_name[file_name.index(tractfolder)]
                              print(program)
                              print(program1)
                              #fileobject.write(program1)
                              #fileobject.write(program)

                              skip_timeout(program,1800)
                              skip_timeout(program1,1800)
                      #tract_list = glob.glob(os.path.expanduser(os.path.join(folder, tractfolder, '*.trk.gz')))
                      #if not tract_list == []:
                              #for tract in tract_list:
                                  #program2='/home-local/wangx41/dsistudio/build/dsi_studio --action=ana --source=/%s/%s_tal_fib.gz ' % (folder,number)
                                  #tract_basename = os.path.basename(tract)
                                  #program2 += '--tract=%s --export=tdi --output=%s' % (
                                  #tract, os.path.join(path1, tract_basename.split('.')[0].replace('tract', 'density')))
                                  #subprocess.call(program2,shell=True)
                      #density_list = glob.glob(
                              #os.path.expanduser(os.path.join(folder, tractfolder, '*.tdi.nii.gz')))
                          # print(density_list)
                      #if not density_list == []:
                             # for density in density_list:
                                # density_basename = os.path.basename(density)
                                 # os.rename(density, os.path.join(path1, density_basename.replace('.tdi', '')))


file_name=['anterior_commissure','anterior_corona_radiata','anterior_limb_internal_capsule','body_corpus_callosum','cerebral_peduncle',
           'cingulum_cingulate_gyrus', 'cingulum_hippocampal', 'corticospinal_tract', 'fornix','genu_corpus_callosum', 'inferior_cerebellar_peduncle', 'inferior_longitudinal_fasciculus',
           'medial_lemniscus', 'midbrain', 'middle_cerebellar_peduncle', 'olfactory_radiation', 'optic_tract', 'pontine_crossing_tract',
           'posterior_corona_radiata', 'posterior_limb_internal_capsule', 'sagittal_stratum', 'splenium_corpus_callosum', 'superior_corona_radiata', 'superior_fronto_occipital_fasciculus','superior_longitudinal_fasciculus',
           'tapetum_corpus_callosum', 'uncinate_fasciculus','inferior_fronto_occipital_fasciculus','fornix_stria_terminalis','superior_cerebellar_peduncle']
short_name=['ac','acr','aic','bcc','cp','cgc','cgh','cst','fx','gcc','icp','ilf','ml','m','mcp','olfr','opt','pct','pcr','pic','ss','scc','scr','sfo','slf','tap','unc','ifo','fxst','scp']
tract_number=[1,2,2,1,2,2,2,2,2,1,2,2,2,1,1,2,1,1,2,2,2,1,2,2,2,1,2,2,2,2]
number_roi=[0,2,0,0,0,0,4,2,1,0,2,4,0,0,0,0,0,2,0,0,0,0,0,2,0,0,0,4,2,2]
dire=['1134_Bruce'] 
txtfile='/nfs/masi/wangx41/misnamed_record.txt'
in_path='/nfs/masi/bayrakrg/tractem_data/original/complete_BLSA_subjects'
out_path='/nfs/masi/wangx41/original_tract/BLSA'
create_tract(dire,in_path,out_path,txtfile,file_name,short_name,tract_number,number_roi)
