%         TestTags are useful for identifying what kind of test you're coding, as you might only want to run certain tests that are related. 
classdef (TestTags = {'T1', 'Demo', 'Integration'}) fitT1_IR_Test < matlab.unittest.TestCase % It's convention to name the test file (filename being tested)_Test.m
    
    properties % Test class variabes; useful for common parameters between tests.
        IRdata
        Mask
        TI
    end
    
    methods (TestClassSetup) % Usually used to setup common testing variables, or loading data.
        function load_test_data(testCase)

            here = pwd;
            goBack = onCleanup(@() cd(here));

            Model = inversion_recovery();
            baseDir = tempdir();
            demoDir = fullfile(baseDir, [Model.ModelName '_demo']);

            if ~isfolder(demoDir)
                downloadData(Model, tempdir());
            end
            cd(demoDir);
            
            % Set class properties
            testCase.IRdata = load('inversion_recovery_data/IRdata.mat').IRData;
            testCase.Mask = load('inversion_recovery_data/Mask.mat').Mask;
            testCase.TI = load('FitResults/FitResults.mat').Protocol.IRData.Mat;
        end
    end
    
    methods (TestClassTeardown) % This could be used to delete any files created during the test execution.
    end
    
    methods (Test) % Each test is it's own method function, and takes testCase as an argument.

        function test_IRfun_returns_near_expected_median_of_test_data(testCase) % Use very descriptive test method names
            
            method='Magnitude';
            
            %% Fit (masked) voxels
            [xx, yy] = find(testCase.Mask);
            [maskedT1, ~, ~, ~] = arrayfun(@(x, y) fitT1_IR(testCase.IRdata(x, y, :), testCase.TI, method), xx, yy);
            
            %% Check the fit
            expectedMedian = 748; % in s, Value was identified under stable working conditions.
            actualMedian = median(maskedT1(:));
            
            % Assert functions are the core of unit tests; if it fails,
            % test log will return failed tests and details.
            assertTrue(testCase, abs(actualMedian-expectedMedian) < 50); % This will alert us if a code change ever produces a fit 
                                                                         % with a median lower than 700 or greater than 800, signaling
                                                                         % a potential bug.
        end
    end
    
end
