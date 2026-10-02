function run_ci_native_review
% CI entry only. Original ECGDeli source and BC5 harness are unchanged.
% This prepared wrapper has not yet been executed in genuine MATLAB.
if exist('OCTAVE_VERSION','builtin') ~= 0
    error('ECGCI:ActualMATLABRequired','Actual MATLAB is required.');
end
repository_root = fileparts(mfilename('fullpath'));
review_root = fullfile(repository_root,'MATLAB_review','official_matlab_review');
output_root = fullfile(review_root,'matlab_outputs');
return_file = fullfile(repository_root,'BC7_MATLAB_return.zip');
assert(~exist(output_root,'dir') && ~exist(return_file,'file'), ...
    'ECGCI:ExistingOutput','Previous output retained; use a fresh job checkout.');
diary(fullfile(repository_root,'MATLAB_native_review.log'));
diary_cleanup=onCleanup(@() diary('off')); %#ok<NASGU>
old_path=path; cleanup=onCleanup(@() path(old_path)); %#ok<NASGU>
old_directory=pwd; directory_cleanup=onCleanup(@() cd(old_directory)); %#ok<NASGU>
try
    assert(usejava('jvm'),'ECGCI:JavaRequired','MATLAB JVM is required for SHA-256 checks.');
    manifest=jsondecode(fileread(fullfile(repository_root,'payload_manifest.json')));
    checks=manifest.files;
    for j=1:numel(checks)
        name=fullfile(repository_root,'MATLAB_review',strrep(checks(j).path,'/',filesep));
        file=fopen(name,'rb'); assert(file>=0,'ECGCI:MissingInput','Missing input/source file.');
        bytes=fread(file,Inf,'*uint8'); fclose(file);
        md=java.security.MessageDigest.getInstance('SHA-256');
        md.update(bytes); digest=typecast(md.digest(),'uint8');
        actual=lower(reshape(dec2hex(digest,2).',1,[]));
        assert(strcmp(actual,checks(j).sha256),'ECGCI:ChecksumMismatch', ...
            'Changed native/source file: %s',checks(j).path);
    end
    needed={'swt','wextend','butter','filtfilt','findpeaks','pca','nanmean', ...
        'quantile','maxk','mink','zp2sos'};
    function_paths=cell(numel(needed),2);
    mathworks_root=[matlabroot filesep];
    for j=1:numel(needed)
        location=which(needed{j});
        assert(~isempty(location),'ECGCI:MissingToolboxFunction', ...
            'Missing required function: %s',needed{j});
        native_path=strncmpi(location,mathworks_root,numel(mathworks_root));
        builtin_path=strncmp(location,'built-in (',10) && ~isempty(strfind(location,matlabroot)); %#ok<STREMP>
        assert(native_path || builtin_path,'ECGCI:ShadowedFunction', ...
            'Non-MathWorks implementation: %s',needed{j});
        function_paths(j,:)={needed{j},location};
    end
    addpath(review_root,'-begin');
    cd(fullfile(review_root,'official_ecgdeli_v1_1','Example'));
    run_bc5_official_review(review_root);
    engine='MATLAB'; actual_matlab_executed=true;
    save(fullfile(output_root,'bc7_engine_and_function_provenance.mat'), ...
        'engine','actual_matlab_executed','function_paths','checks','-v7');
    zip(return_file,{'matlab_outputs'},review_root);
    fprintf('All planned attempts retained. Running this job does not pass Gate 1.\n');
catch err
    text=getReport(err,'extended','hyperlinks','off');
    file=fopen(fullfile(repository_root,'MATLAB_environment_error.txt'),'w');
    if file>=0, fprintf(file,'%s\n',text); fclose(file); end
    fprintf(2,'%s\n',text);
    rethrow(err);
end
end
