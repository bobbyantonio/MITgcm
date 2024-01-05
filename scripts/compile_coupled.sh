#!/usr/bin/bash
#SBATCH --nodes=6
#SBATCH --time=1-0:00:00
#SBATCH --mem=100gb
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name=makeMITgcm
#SBATCH --qos=np

module load python3/3.8.8-01 
module load prgenv/intel 
module load hpcx-openmpi/2.9.0
module load hdf5-parallel/1.10.6 
module load netcdf4-parallel/4.7.4 
module load ecmwf-toolbox/2021.08.3.0
# module load python3/3.8.8-01 
# module load prgenv/gnu  
# module load hpcx-openmpi/2.9.0
# module load hdf5-parallel/1.10.6 
# module load netcdf4-parallel/4.7.4 
# module load ecmwf-toolbox/2021.08.3.0

# export MPI_HOME=/usr/local/apps/hpcx-openmpi/2.9.0/GNU/8.5/ec-hpcx-ompi
export MPI_HOME=/usr/local/apps/hpcx-openmpi/2.9.0/INTEL/2021.4/ec-hpcx-ompi
export PATH=${MPI_HOME}/bin:${MPI_HOME}/include:$PATH


# cd /perm/ecme4254/repos/MITgcm/verification/cpl_aim+ocn/build_cpl
# rm /perm/ecme4254/repos/MITgcm/verification/cpl_aim+ocn/build_cpl/*

# ../../../tools/genmake2 -of ../../../tools/build_options/linux_amd64_ifort -mpi -devel -fc "mpif77" -cc "mpicc"
# # ../../../tools/genmake2 -mods ../code_cpl -fc "mpif77" -cc "mpicc" -of ../../../tools/build_options/linux_amd64_ifort
# make clean
# make depend
# make

# cp /perm/ecme4254/repos/MITgcm/verification/cpl_aim+ocn/input_cpl/* /perm/ecme4254/repos/MITgcm/verification/cpl_aim+ocn/build_cpl/
# cd 

export OMP_NUM_THREADS=2
export KMP_STACKSIZE="400m"

cd /perm/ecme4254/repos/MITgcm/verification/cpl_aim+ocn

../../tools/run_cpl_test 0
cp SIZE_atm.h.tmpl build_atm/SIZE.h
cp SIZE_ocn.h.tmpl build_ocn/SIZE.h
../../tools/run_cpl_test 1 -of ../../tools/build_options/linux_amd64_ifort
../../tools/run_cpl_test 2
../../tools/run_cpl_test 3
# ../../../tools/genmake2 -of /perm/ecme4254/repos/MITgcm/tools/build_options/linux_amd64_ifort -mpi -devel -fc mpif77 -cc mpicc
# ../../../tools/genmake2 -of /perm/ecme4254/repos/MITgcm/tools/build_options/linux_amd64_ifort+impi -mpi -devel -fc mpiifort -cc mpiicc
# ../../../tools/genmake2 -of /perm/ecme4254/repos/MITgcm/tools/build_options/linux_amd64_ifort -mpi -devel -fc mpif77 -cc mpicc
# ../../tools/genmake2 -of /perm/ecme4254/repos/MITgcm/tools/build_options/linux_amd64_ifort

# make depend
# make
# ./mitgcmuv

# ../../tools/run_cpl_test 1 -of ../../tools/build_options/linux_amd64_ifort

# ../../tools/run_cpl_test 2
# mpirun -np 1 ./build_atm/mitgcmuv