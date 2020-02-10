# Alluxio and Spark deploy with Slurm

Scripts used to run some simple performance benchmarks in Standalone mode on HPC clusters.

Alluxio and Spark configuration files are created after the templates by querying Slurm.


Scripts used to prove that by performing approximate queries and relaxing consistency in an Alluxio-Spark use case, we obtain a 10x throughput gain compared to using GPFS as Alluxio's storage. Most important, a 3x improvement compared to using only Alluxio memory layer, thanks to relaxing the strong consistency to eventual, and a constant usage of DRAM.
 

## Performance results

Storage setup | Mean time to process update | Alluxio memory usage | Throughput (queries completed / s)
|---|---|---|---|
|GPFS|29.70±2,65s|NA | 0,0336 queries/s
|Alluxio MEM+GPFS|5.39±0,21s| Linear growth at 4GB/s| 0,1325 queries/s before evictions start, 0,0464 queries/s after
|Alluxio MEM+NVMe|2,10±0,20s| Linear growth at 4GB/s| 0,1331 queries/s
|Alluxio MEM only|2.11±0,25s| Linear growth at 4GB/s| 0,1334 queries/s
|Alluxio In-memory staging with updates|2.12±0,37s| Stable at the size of dataset (8.4GB total)| **0,4717 queries/s**

## References

[A staging area for in-memory computing, *Santamaria Mateu, Pol*](https://hdl.handle.net/10609/83667 "A staging area for in-memory computing")

