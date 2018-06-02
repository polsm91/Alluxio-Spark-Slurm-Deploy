#!/bin/bash
#SBATCH --job-name=alluxio
#SBATCH --output=job_%j.out
#SBATCH --error=job_%j.err
#SBATCH --nodes=3
#SBATCH --time=00:10:00
#BATCH --exclusive
#SBATCH --partition=short
#SBATCH --qos=short-award
#BATCH --ntasks-per-node=48

echo "SLURM_JOBID: "$SLURM_JOBID
echo "SLURM_NPROCS: "$SLURM_NPROCS
echo "SLURM_NNODES: "$SLURM_NNODES
echo "SLURM_NTASKS_PER_NODE: "$SLURM_NTASKS_PER_NODE
echo "SLURM_PROCID: "$SLURM_PROCID
echo "SLURM_NODEID: "$SLURM_NODEID
echo "SLURM_LOCALID: "$SLURM_LOCALID
echo "SLURMD_NODENAME: "$SLURMD_NODENAME
echo "SLURM_NODELIST: "$SLURM_NODELIST

#0 Requiered modules
# Alluxio works by doing ssh, therefore the java has been set in $HOME/.bashrc
# module load java/jdk1.8.0_162


#1 Configure nodes, pickup a master and leave all others as workers
LOCAL_PATH=/home/scratch
NODES=`scontrol show hostnames $SLURM_NODELIST`
NODE_ARR=(${NODES// / })
MASTER_NODE=${NODE_ARR[0]}
WORKER_NODES=${NODE_ARR[@]:1}
TMPFS=/dev/shm/$(whoami)

srun --ntasks-per-node=1 mkdir -p $TMPFS
echo "RESERVED NODES: "$NODES
echo "MASTER: "$MASTER_NODE
echo "WORKERS: "$WORKER_NODES

#2 Update configuration

sed $ALLUXIO_HOME/conf/masters.template -e "s+PLACEHOLDER+$MASTER_NODE+" > $ALLUXIO_HOME/conf/masters
sed $ALLUXIO_HOME/conf/workers.template -e "s+PLACEHOLDER+$WORKER_NODES+" > $ALLUXIO_HOME/conf/workers
sed $ALLUXIO_HOME/conf/alluxio-site.properties.template -e "s+PLACEHOLDER_MASTERHOSTNAME+$MASTER_NODE+" -e "s+PLACEHOLDER_UNDERFS+$LOCAL_PATH+" -e "s+PLACEHOLDER_RAMFS+$TMPFS+" > $ALLUXIO_HOME/conf/alluxio-site.properties

ALLUXIO_MASTER_HOSTNAME=$MASTER_NODE
ALLUXIO_WORKER_MEMORY_SIZE="1024MB"
ALLUXIO_RAM_FOLDER=$TMPFS
ALLUXIO_UNDERFS_ADDRESS=$LOCAL_PATH

#2 Format
$ALLUXIO_HOME/bin/alluxio format

#3 Launch
$ALLUXIO_HOME/bin/alluxio-start.sh all NoMount &

#3 When dying, kill all processes
sleep 180
$ALLUXIO_HOME/bin/alluxio-stop.sh all
sleep 60
