# Fixed native ECG review in genuine MATLAB

This repository is an implementation review, not a completed clinical study.
It runs the previously fixed 15 native public PTB-XL ECGs
through unchanged official ECGDeli v1.1 source and the existing BC5 harness.
Raw and example-filtered diagnostic modes form 30 planned attempts.
The filtered mode is a diagnostic example; it is not the clinical matched-resampling arm.

The job uses genuine MATLAB R2021b on an Ubuntu 22.04 GitHub-hosted runner.
The actual MATLAB update level and toolbox versions are captured at execution.
This version is an explicit execution choice, not an assertion about the
unavailable PTB-XL+ publishing environment. No MATLAB version sweep is planned.
All GitHub actions are pinned to resolved commit SHAs.

Official licensing: for public projects, MathWorks MATLAB run actions provide
product licenses automatically, except transformation products not used here:
https://github.com/matlab-actions/setup-matlab#licensing

The committed payload contains only 15 fixed native waveform MAT files, 29
unchanged upstream source/README/license files, the unchanged diagnostic harness
and its contract. No ECG images, patient free text, manuscript, 300-ECG manifest,
Python measurement outputs or private comparison evidence is committed.
The contract retains reference-evidence hashes, not the underlying reference files.

Native waveform source and license:
https://physionet.org/content/ptb-xl/1.0.3/ (CC BY 4.0)
Dataset credit: Wagner et al., PTB-XL v1.0.3, PhysioNet,
https://doi.org/10.13026/kfzx-aw45
License: https://creativecommons.org/licenses/by/4.0/
Storage change: native WFDB values were decoded to double-precision mV MAT
arrays with the fixed lead order saved in `lead_names`; no waveform processing
was added during CI preparation.
Published reference to be compared privately after job completion:
https://physionet.org/content/ptb-xl-plus/1.0.1/
Official ECGDeli v1.1 source commit: 3c13b1b2ff55152360f3cee992c1d1d66099aa14
https://github.com/KIT-IBT/ECGdeli/tree/v1.1 (GNU GPL v3; license preserved)
The repository harness, wrappers and extraction script are also supplied under GNU GPL v3.

Publishing and running this public workflow exposes the native/source package,
workflow logs and resulting native diagnostic artifacts to GitHub users.
No publication or actual MATLAB run has occurred during preparation.
Artifacts retain successes, failures, runtime provenance and partial outputs.
The BC7 collector uses the private fixed comparison evidence after retrieval.
A completed run does not automatically pass Gate 1 or unlock digitization.

To run after publication, use the `ecg-native-matlab-review` branch. A push to
that branch triggers the job. Later runs may use the Actions workflow dispatch.
