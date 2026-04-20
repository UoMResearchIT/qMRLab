function [passed, report] = runTestFolder(folder, opt)
% [PASSED, REPORT] = runTestFolder(FOLDER, recursive=true)
% PASSED = runTestFolder(..., report='coverage_FOLDER.xml')
%
%   Runs unit tests in './Test/FOLDER' and generates an XML coverage report
%   for './src'. This is a convenience wrapper around MATLAB's <a href="matlab: doc runtests">runtests</a>
%   meant to be used in CI workflows. For interactive tests you might 
%   want to tag your unit tests and use <a href="matlab: help('runTestSuite')">runTestSuite</a>.
%
% See also: runtests, runTestSuite
    
arguments
    folder (1,:) char {mustBeTestSubfolder}
    opt.report (1,:) char {mustBeNonempty} = ['coverage_' folder '.xml']
    opt.recursive (1,1) logical = true
end

qMRLabVer;
testDir = fullfile('Test', folder);
[testResults, coverageResults] = runtests(testDir, 'ReportCoverageFor', 'src', 'IncludeSubfolders', opt.recursive);
coverageResults.generateCoberturaReport(opt.report);

report = opt.report;
passed = all([testResults.assertSuccess().Passed]);

end

function mustBeTestSubfolder(folder)
    mustBeFolder(fullfile('Test', folder))
end