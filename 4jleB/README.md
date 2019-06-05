# 4jieB monomer

A helix-swapped dimeric structure of the _P. falciparum_ PFI1780w PHIST domain was determined by
[Oberli, et al. (2018)](https://www.fasebj.org/doi/10.1096/fj.14-256057) in entry
[4jle](http://www.ebi.ac.uk/pdbe/entry/pdb/4jle/). The dimer is a crystallization artifact as
the solution structure is monomeric. A monomeric model was shown in the figures but no coordinate
data is provided. To facilitate direct classification of the protein against structual databases,
a monomeric structure is built.

## Material and Methods
A monomeric model of 4jle was created by only taking `A:117-167` and `B:1-110` from the file,
so that the &alpha;3-&alpha;4 loop is deleted and will be automatically remodeled.
This model was then used as a template in Swiss-model to model against the SEQRES to form a
complete structure for the remodeled protein.

The model was compared against CATH-db using CATHEDRAL and SCOP 1.73 using PDBeFOLD.

## Results 
Modelling logs indicate that a fragment match was successfully found for `A.LEU110-(NGKLCE)-A.ARG117`.
The model is apparently of high quality (QMEAN Z-score = 1.13).

The structual similarity search did not yield any interesting results.
* [CATHDB result](http://www.cathdb.info/search/grid_submission/12201)
* [PDBeFold result](https://github.com/Artoria2e5/misc/blob/master/4jleB/sse.txt)

## Retrieving the data
The Swiss-Prot report for job `VR9UPz` is attached as `pdb4jle_monomer.zip` in this directory. The
template file is included.

![model](https://i.imgur.com/wlI31kt.png)
